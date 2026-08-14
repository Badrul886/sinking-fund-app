import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/application/use_cases/transaction/add_contribution_use_case.dart';
import 'package:sinking_fund/application/use_cases/transaction/add_withdrawal_use_case.dart';
import 'package:sinking_fund/application/use_cases/fund/create_fund_use_case.dart';
import 'package:sinking_fund/application/use_cases/fund/get_fund_use_case.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/application/errors/application_error.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';


import 'fakes.dart';

void main() {
  late FakeFundRepository repository;
  late FakeIdentifierGenerator idGen;
  late CreateFundUseCase createFundUseCase;
  late GetFundUseCase getFundUseCase;
  late AddContributionUseCase addContributionUseCase;
  late AddWithdrawalUseCase addWithdrawalUseCase;

  setUp(() {
    repository = FakeFundRepository();
    idGen = FakeIdentifierGenerator();
    createFundUseCase = CreateFundUseCase(repository, idGen);
    getFundUseCase = GetFundUseCase(repository);
    addContributionUseCase = AddContributionUseCase(
      repository,
      getFundUseCase,
      idGen,
    );
    addWithdrawalUseCase = AddWithdrawalUseCase(
      repository,
      getFundUseCase,
      idGen,
    );
  });

  Future<String> setupFund({Currency currency = const Currency('USD')}) async {
    final fund = await createFundUseCase.execute(
      name: 'Test Fund',
      targetAmount: Money(minorUnits: 10000, currency: currency),
      startDate: CalendarDate(2026, 1, 1),
      targetDate: CalendarDate(2026, 12, 31),
      contributionFrequency: ContributionFrequency.monthly,
    );
    return fund.id;
  }

  group('AddContributionUseCase', () {
    test('successfully adds contribution and returns updated state', () async {
      final fundId = await setupFund();
      final date = CalendarDate(2026, 2, 1);
      final amount = Money(minorUnits: 5000, currency: Currency('USD'));

      final state = await addContributionUseCase.execute(
        fundId: fundId,
        amount: amount,
        date: date,
        currentDate: date,
      );

      expect(state.transactions.length, 1);
      expect(state.transactions.first.amount, amount);
      expect(state.calculationResult.currentBalance, amount);
      expect(
        state.calculationResult.status,
        FundStatus.ahead,
      ); // 50.00 > expected 8.33
    });

    test('throws InvalidFundDataError on currency mismatch', () async {
      final fundId = await setupFund(currency: Currency('BDT'));
      final amount = Money(minorUnits: 5000, currency: Currency('USD'));

      expect(
        () => addContributionUseCase.execute(
          fundId: fundId,
          amount: amount,
          date: CalendarDate(2026, 2, 1),
          currentDate: CalendarDate(2026, 2, 1),
        ),
        throwsA(isA<InvalidFundDataError>()),
      );
    });

    test('throws FundNotFoundError for unknown fund', () async {
      expect(
        () => addContributionUseCase.execute(
          fundId: 'unknown',
          amount: Money(minorUnits: 100, currency: Currency('USD')),
          date: CalendarDate(2026, 2, 1),
          currentDate: CalendarDate(2026, 2, 1),
        ),
        throwsA(isA<FundNotFoundError>()),
      );
    });
  });

  group('AddWithdrawalUseCase', () {
    test('successfully adds withdrawal when funds are sufficient', () async {
      final fundId = await setupFund();
      final date = CalendarDate(2026, 2, 1);

      // Add initial contribution
      await addContributionUseCase.execute(
        fundId: fundId,
        amount: Money(minorUnits: 8000, currency: Currency('USD')),
        date: date,
        currentDate: date,
      );

      // Withdraw
      final state = await addWithdrawalUseCase.execute(
        fundId: fundId,
        amount: Money(minorUnits: 3000, currency: Currency('USD')),
        date: CalendarDate(2026, 2, 2),
        currentDate: CalendarDate(2026, 2, 2),
      );

      expect(state.transactions.length, 2);
      expect(
        state.calculationResult.currentBalance,
        Money(minorUnits: 5000, currency: Currency('USD')),
      );
    });

    test(
      'throws InsufficientFundsError safely when withdrawal exceeds balance',
      () async {
        final fundId = await setupFund();
        final date = CalendarDate(2026, 2, 1);

        // Add initial contribution
        await addContributionUseCase.execute(
          fundId: fundId,
          amount: Money(minorUnits: 2000, currency: Currency('USD')),
          date: date,
          currentDate: date,
        );

        // Withdraw too much
        expect(
          () => addWithdrawalUseCase.execute(
            fundId: fundId,
            amount: Money(minorUnits: 3000, currency: Currency('USD')),
            date: CalendarDate(2026, 2, 2),
            currentDate: CalendarDate(2026, 2, 2),
          ),
          throwsA(isA<InsufficientFundsError>()),
        );

        // Verify no withdrawal was persisted
        final state = await getFundUseCase.execute(fundId, date);
        expect(state.transactions.length, 1);
        expect(
          state.calculationResult.currentBalance,
          Money(minorUnits: 2000, currency: Currency('USD')),
        );
      },
    );

    test('throws InvalidFundDataError on currency mismatch', () async {
      final fundId = await setupFund(currency: Currency('BDT'));

      // Bypass AddContributionUseCase currency check for test setup by directly calling repository?
      // No, we can just try to withdraw USD from an empty BDT fund, it should fail on currency before balance check,
      // actually, the code checks currency mismatch FIRST.
      final amount = Money(minorUnits: 5000, currency: Currency('USD'));

      expect(
        () => addWithdrawalUseCase.execute(
          fundId: fundId,
          amount: amount,
          date: CalendarDate(2026, 2, 1),
          currentDate: CalendarDate(2026, 2, 1),
        ),
        throwsA(isA<InvalidFundDataError>()),
      );
    });

    test('unexpected errors bubble naturally', () async {
      final fundId = await setupFund();

      await addContributionUseCase.execute(
        fundId: fundId,
        amount: Money(minorUnits: 2000, currency: Currency('USD')),
        date: CalendarDate(2026, 2, 1),
        currentDate: CalendarDate(2026, 2, 1),
      );

      // Force a generic exception in repository during save
      repository.throwOnSave = true;

      expect(
        () => addWithdrawalUseCase.execute(
          fundId: fundId,
          amount: Money(minorUnits: 1000, currency: Currency('USD')),
          date: CalendarDate(2026, 2, 2),
          currentDate: CalendarDate(2026, 2, 2),
        ),
        throwsA(
          isA<PersistenceConstraintError>(),
        ), // Not completely generic since we mock constraint error, but proves mapping.
      );
    });
  });
}
