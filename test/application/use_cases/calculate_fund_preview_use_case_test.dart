import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/application/use_cases/fund/calculate_fund_preview_use_case.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';

void main() {
  final usd = Currency('USD');
  final useCase = const CalculateFundPreviewUseCase();

  test('Calculates required contribution with no initial savings', () {
    final result = useCase.execute(
      targetAmount: Money(minorUnits: 12000, currency: usd),
      startDate: CalendarDate(2025, 1, 1),
      targetDate: CalendarDate(2025, 12, 1),
      contributionFrequency: ContributionFrequency.monthly,
      initialSavings: Money.zero(usd),
      currentDate: CalendarDate(2025, 1, 1),
    );

    expect(
      result.calculationResult.requiredContribution.minorUnits,
      1000,
    ); // 12000 / 12 periods
    expect(result.calculationResult.currentBalance.minorUnits, 0);
  });

  test('Calculates required contribution with initial savings', () {
    final result = useCase.execute(
      targetAmount: Money(minorUnits: 12000, currency: usd),
      startDate: CalendarDate(2025, 1, 1),
      targetDate: CalendarDate(2025, 12, 1),
      contributionFrequency: ContributionFrequency.monthly,
      initialSavings: Money(minorUnits: 6000, currency: usd),
      currentDate: CalendarDate(2025, 1, 1),
    );

    expect(
      result.calculationResult.requiredContribution.minorUnits,
      500,
    ); // (12000 - 6000) / 12
    expect(result.calculationResult.currentBalance.minorUnits, 6000);
  });

  test('Target reached with initial savings', () {
    final result = useCase.execute(
      targetAmount: Money(minorUnits: 12000, currency: usd),
      startDate: CalendarDate(2025, 1, 1),
      targetDate: CalendarDate(2025, 12, 1),
      contributionFrequency: ContributionFrequency.monthly,
      initialSavings: Money(minorUnits: 12000, currency: usd),
      currentDate: CalendarDate(2025, 1, 1),
    );

    expect(result.calculationResult.requiredContribution.minorUnits, 0);
  });
}
