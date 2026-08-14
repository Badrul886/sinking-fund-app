import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/application/use_cases/fund/calculate_fund_preview_use_case.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/fund_calculator.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/trajectory_calculator.dart';
import 'package:sinking_fund/domain/transaction.dart';

void main() {
  late CalculateFundPreviewUseCase useCase;

  setUp(() {
    useCase = const CalculateFundPreviewUseCase();
  });

  group('CalculateFundPreviewUseCase', () {
    test(
      'Normal preview: calculationResult is correct and trajectory is present',
      () {
        final targetAmount = Money(
          minorUnits: 100000,
          currency: Currency('USD'),
        );
        final initialSavings = Money.zero(Currency('USD'));
        final startDate = CalendarDate(2026, 8, 1);
        final targetDate = CalendarDate(2026, 12, 1);
        final currentDate = CalendarDate(2026, 8, 14);

        final result = useCase.execute(
          targetAmount: targetAmount,
          startDate: startDate,
          targetDate: targetDate,
          contributionFrequency: ContributionFrequency.monthly,
          initialSavings: initialSavings,
          currentDate: currentDate,
        );

        expect(
          result.calculationResult.status,
          FundStatus.behind,
        ); // Because no initial savings and 1 period elapsed
        expect(
          result.calculationResult.requiredContribution.minorUnits,
          25000,
        ); // 100000 / 4 months
        expect(
          result.trajectory.historicalPoints.isEmpty,
          isTrue,
        ); // No initial savings
        expect(result.trajectory.futurePoints.length, 4); // Aug, Sep, Oct, Nov
      },
    );

    group('Initial savings', () {
      test('0 initial savings', () {
        final result = useCase.execute(
          targetAmount: Money(minorUnits: 50000, currency: Currency('USD')),
          startDate: CalendarDate(2026, 8, 1),
          targetDate: CalendarDate(2026, 10, 1),
          contributionFrequency: ContributionFrequency.monthly,
          initialSavings: Money.zero(Currency('USD')),
          currentDate: CalendarDate(2026, 8, 1),
        );

        expect(result.calculationResult.currentBalance.minorUnits, 0);
        expect(result.trajectory.historicalPoints.isEmpty, isTrue);
      });

      test('non-zero initial savings', () {
        final result = useCase.execute(
          targetAmount: Money(minorUnits: 50000, currency: Currency('USD')),
          startDate: CalendarDate(2026, 8, 1),
          targetDate: CalendarDate(2026, 10, 1),
          contributionFrequency: ContributionFrequency.monthly,
          initialSavings: Money(minorUnits: 10000, currency: Currency('USD')),
          currentDate: CalendarDate(2026, 8, 1),
        );

        expect(result.calculationResult.currentBalance.minorUnits, 10000);
        expect(
          result.trajectory.historicalPoints.length,
          1,
        ); // Contains initial savings point
        expect(
          result.trajectory.historicalPoints.first.balance.minorUnits,
          10000,
        );
      });
    });

    group('Multi-currency', () {
      test('JPY (0 decimals)', () {
        final result = useCase.execute(
          targetAmount: Money(minorUnits: 10000, currency: Currency('JPY')),
          startDate: CalendarDate(2026, 8, 1),
          targetDate: CalendarDate(2026, 9, 1),
          contributionFrequency: ContributionFrequency.monthly,
          initialSavings: Money.zero(Currency('JPY')),
          currentDate: CalendarDate(2026, 8, 1),
        );

        expect(
          result.calculationResult.requiredContribution.currency.code,
          'JPY',
        );
        expect(result.calculationResult.requiredContribution.minorUnits, 5000);
      });

      test('USD/BDT (2 decimals)', () {
        final result = useCase.execute(
          targetAmount: Money(minorUnits: 100000, currency: Currency('BDT')),
          startDate: CalendarDate(2026, 8, 1),
          targetDate: CalendarDate(2026, 9, 1),
          contributionFrequency: ContributionFrequency.monthly,
          initialSavings: Money(minorUnits: 50000, currency: Currency('BDT')),
          currentDate: CalendarDate(2026, 8, 1),
        );

        expect(
          result.calculationResult.requiredContribution.currency.code,
          'BDT',
        );
        expect(result.calculationResult.requiredContribution.minorUnits, 25000);
      });

      test('BHD (3 decimals)', () {
        final result = useCase.execute(
          targetAmount: Money(minorUnits: 1000000, currency: Currency('BHD')),
          startDate: CalendarDate(2026, 8, 1),
          targetDate: CalendarDate(2026, 9, 1),
          contributionFrequency: ContributionFrequency.monthly,
          initialSavings: Money(minorUnits: 500000, currency: Currency('BHD')),
          currentDate: CalendarDate(2026, 8, 1),
        );

        expect(
          result.calculationResult.requiredContribution.currency.code,
          'BHD',
        );
        expect(
          result.calculationResult.requiredContribution.minorUnits,
          250000,
        );
      });
    });

    group('Edge cases', () {
      test('target = 0', () {
        final result = useCase.execute(
          targetAmount: Money.zero(Currency('USD')),
          startDate: CalendarDate(2026, 8, 1),
          targetDate: CalendarDate(2026, 9, 1),
          contributionFrequency: ContributionFrequency.monthly,
          initialSavings: Money(minorUnits: 1000, currency: Currency('USD')),
          currentDate: CalendarDate(2026, 8, 1),
        );

        expect(result.calculationResult.status, FundStatus.overfunded);
        expect(result.calculationResult.requiredContribution.minorUnits, 0);
      });

      test('same-day target', () {
        final date = CalendarDate(2026, 8, 14);
        final result = useCase.execute(
          targetAmount: Money(minorUnits: 10000, currency: Currency('USD')),
          startDate: date,
          targetDate: date,
          contributionFrequency: ContributionFrequency.monthly,
          initialSavings: Money.zero(Currency('USD')),
          currentDate: date,
        );

        expect(result.calculationResult.requiredContribution.minorUnits, 10000);
      });

      test('deadline passed', () {
        final result = useCase.execute(
          targetAmount: Money(minorUnits: 10000, currency: Currency('USD')),
          startDate: CalendarDate(2026, 7, 1),
          targetDate: CalendarDate(2026, 8, 1),
          contributionFrequency: ContributionFrequency.monthly,
          initialSavings: Money.zero(Currency('USD')),
          currentDate: CalendarDate(2026, 8, 14),
        );

        expect(result.calculationResult.status, FundStatus.deadlinePassed);
        expect(result.calculationResult.requiredContribution.minorUnits, 10000);
      });

      test('overfunded state where applicable', () {
        final result = useCase.execute(
          targetAmount: Money(minorUnits: 10000, currency: Currency('USD')),
          startDate: CalendarDate(2026, 8, 1),
          targetDate: CalendarDate(2026, 9, 1),
          contributionFrequency: ContributionFrequency.monthly,
          initialSavings: Money(minorUnits: 15000, currency: Currency('USD')),
          currentDate: CalendarDate(2026, 8, 1),
        );

        expect(result.calculationResult.status, FundStatus.overfunded);
        expect(result.calculationResult.requiredContribution.minorUnits, 0);
      });
    });

    test('Consistency: matches Domain semantics for a persisted Fund', () {
      final targetAmount = Money(minorUnits: 100000, currency: Currency('USD'));
      final startDate = CalendarDate(2026, 8, 1);
      final targetDate = CalendarDate(2026, 12, 1);
      final contributionFrequency = ContributionFrequency.monthly;
      final initialSavings = Money(
        minorUnits: 25000,
        currency: Currency('USD'),
      );
      final currentDate = CalendarDate(2026, 9, 1);

      final previewResult = useCase.execute(
        targetAmount: targetAmount,
        startDate: startDate,
        targetDate: targetDate,
        contributionFrequency: contributionFrequency,
        initialSavings: initialSavings,
        currentDate: currentDate,
      );

      // We assert that the preview generates identical trajectory as Domain logic
      // However, note that initial savings in preview is set to currentDate by the usecase
      // if initialSavings is provided. Wait, in usecase:
      // Contribution(amount: initialSavings, date: currentDate)
      // For consistency test, we must align the dates.

      final previewFund = Fund(
        id: 'preview-fund',
        name: 'Preview',
        targetAmount: targetAmount,
        startDate: startDate,
        targetDate: targetDate,
        contributionFrequency: contributionFrequency,
      );

      final txForPreview = <Transaction>[
        Contribution(
          id: 'preview-initial-savings',
          amount: initialSavings,
          date: currentDate,
        ),
      ];

      final expectedTraj = TrajectoryCalculator.calculate(
        fund: previewFund,
        transactions: txForPreview,
        currentDate: currentDate,
      );

      expect(
        previewResult.trajectory.historicalPoints.length,
        expectedTraj.historicalPoints.length,
      );
      expect(
        previewResult.trajectory.futurePoints.length,
        expectedTraj.futurePoints.length,
      );
      expect(
        previewResult.calculationResult.status,
        FundCalculator.calculate(
          fund: previewFund,
          currentDate: currentDate,
          transactions: txForPreview,
        ).status,
      );
    });
  });
}
