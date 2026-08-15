import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/application/use_cases/fund/create_fund_use_case.dart';
import 'package:sinking_fund/application/use_cases/fund/get_fund_use_case.dart';
import 'package:sinking_fund/application/use_cases/fund/get_all_funds_use_case.dart';
import 'package:sinking_fund/application/use_cases/fund/update_fund_use_case.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/application/errors/application_error.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/transaction.dart';
import 'package:sinking_fund/domain/fund_calculator.dart';

import 'fakes.dart';

void main() {
  late FakeFundRepository repository;
  late FakeIdentifierGenerator idGen;
  late CreateFundUseCase createFundUseCase;
  late GetFundUseCase getFundUseCase;
  late GetAllFundsUseCase getAllFundsUseCase;
  late UpdateFundUseCase updateFundUseCase;

  setUp(() {
    repository = FakeFundRepository();
    idGen = FakeIdentifierGenerator();
    createFundUseCase = CreateFundUseCase(repository, idGen);
    getFundUseCase = GetFundUseCase(repository);
    getAllFundsUseCase = GetAllFundsUseCase(repository);
    updateFundUseCase = UpdateFundUseCase(repository);
  });

  group('CreateFundUseCase', () {
    test('successfully creates a fund with generated ID', () async {
      idGen.idToGenerate = 'generated-id-1';
      final target = Money(minorUnits: 100000, currency: Currency('USD'));
      final start = CalendarDate(2026, 1, 1);
      final end = CalendarDate(2026, 12, 31);
      final schedule = ContributionFrequency.monthly;

      final fund = await createFundUseCase.execute(
        name: 'Vacation',
        targetAmount: target,
        startDate: start,
        targetDate: end,
        contributionFrequency: schedule,
      );

      expect(fund.id, 'generated-id-1');
      expect(fund.name, 'Vacation');
      expect(fund.targetAmount, target);
      expect(fund.startDate, start);
      expect(fund.targetDate, end);

      final savedFund = await repository.getFund('generated-id-1');
      expect(savedFund, isNotNull);

      final txs = await repository.getTransactionsForFund('generated-id-1');
      expect(txs, isEmpty); // initialSavings = 0 (omitted) -> no transaction
    });

    test(
      'successfully creates a fund with initialSavings > 0 (creates Contribution)',
      () async {
        idGen.idToGenerate = 'generated-id-2';
        final target = Money(minorUnits: 100000, currency: Currency('USD'));
        final start = CalendarDate(2026, 1, 1);
        final end = CalendarDate(2026, 12, 31);
        final schedule = ContributionFrequency.monthly;
        final initialSavings = Money(
          minorUnits: 50000,
          currency: Currency('USD'),
        );

        final fund = await createFundUseCase.execute(
          name: 'Car',
          targetAmount: target,
          startDate: start,
          targetDate: end,
          contributionFrequency: schedule,
          initialSavings: initialSavings,
        );

        expect(fund.id, 'generated-id-2');
        final savedFund = await repository.getFund('generated-id-2');
        expect(savedFund, isNotNull);

        final txs = await repository.getTransactionsForFund('generated-id-2');
        expect(txs.length, 1);
        expect(txs.first, isA<Contribution>());
        expect(txs.first.amount, initialSavings);
      },
    );

    test(
      'successfully creates a fund with initialSavings > target (OVERFUNDED)',
      () async {
        idGen.idToGenerate = 'generated-id-3';
        final target = Money(minorUnits: 100000, currency: Currency('USD'));
        final start = CalendarDate(2026, 1, 1);
        final end = CalendarDate(2026, 12, 31);
        final schedule = ContributionFrequency.monthly;
        final initialSavings = Money(
          minorUnits: 150000,
          currency: Currency('USD'),
        );

        await createFundUseCase.execute(
          name: 'Overfunded',
          targetAmount: target,
          startDate: start,
          targetDate: end,
          contributionFrequency: schedule,
          initialSavings: initialSavings,
        );

        final txs = await repository.getTransactionsForFund('generated-id-3');
        expect(txs.length, 1);
        expect(txs.first.amount, initialSavings);

        final state = await getFundUseCase.execute(
          'generated-id-3',
          CalendarDate(2026, 1, 1),
        );
        expect(state.calculationResult.status, FundStatus.overfunded);
      },
    );

    test('preserves supplied ID', () async {
      final target = Money(minorUnits: 100000, currency: Currency('USD'));
      final fund = await createFundUseCase.execute(
        id: 'explicit-id-1',
        name: 'Vacation',
        targetAmount: target,
        startDate: CalendarDate(2026, 1, 1),
        targetDate: CalendarDate(2026, 12, 31),
        contributionFrequency: ContributionFrequency.monthly,
      );

      expect(fund.id, 'explicit-id-1');
      final savedFund = await repository.getFund('explicit-id-1');
      expect(savedFund, isNotNull);
    });

    test(
      'throws InvalidFundDataError on invalid domain construction',
      () async {
        final target = Money(
          minorUnits: -100,
          currency: Currency('USD'),
        ); // Invalid negative target

        expect(
          () => createFundUseCase.execute(
            name: 'Invalid',
            targetAmount: target,
            startDate: CalendarDate(2026, 1, 1),
            targetDate: CalendarDate(2026, 12, 31),
            contributionFrequency: ContributionFrequency.monthly,
          ),
          throwsA(isA<InvalidFundDataError>()),
        );
      },
    );

    test('maps repository constraint error', () async {
      repository.throwOnSave = true;
      final target = Money(minorUnits: 100, currency: Currency('USD'));

      expect(
        () => createFundUseCase.execute(
          name: 'Test',
          targetAmount: target,
          startDate: CalendarDate(2026, 1, 1),
          targetDate: CalendarDate(2026, 12, 31),
          contributionFrequency: ContributionFrequency.monthly,
        ),
        throwsA(isA<PersistenceConstraintError>()),
      );
    });
  });

  group('GetFundUseCase & GetAllFundsUseCase', () {
    test('GetFundUseCase correctly builds FundState', () async {
      final target = Money(minorUnits: 100000, currency: Currency('USD'));
      final fund = await createFundUseCase.execute(
        id: 'fund-1',
        name: 'Test Fund',
        targetAmount: target,
        startDate: CalendarDate(2026, 1, 1),
        targetDate: CalendarDate(2026, 12, 31),
        contributionFrequency: ContributionFrequency.monthly,
      );

      final state = await getFundUseCase.execute(
        'fund-1',
        CalendarDate(2026, 6, 15),
      );
      expect(state.fund, fund);
      expect(state.transactions, isEmpty);
      expect(state.calculationResult, isA<FundCalculationResult>());
      expect(state.calculationResult.status, FundStatus.behind);
    });

    test('GetFundUseCase throws FundNotFoundError', () async {
      expect(
        () => getFundUseCase.execute('non-existent', CalendarDate(2026, 1, 1)),
        throwsA(isA<FundNotFoundError>()),
      );
    });

    test('GetAllFundsUseCase returns multiple FundStates', () async {
      final target = Money(minorUnits: 100, currency: Currency('USD'));
      await createFundUseCase.execute(
        id: 'fund-1',
        name: 'Fund 1',
        targetAmount: target,
        startDate: CalendarDate(2026, 1, 1),
        targetDate: CalendarDate(2026, 12, 31),
        contributionFrequency: ContributionFrequency.monthly,
      );
      await createFundUseCase.execute(
        id: 'fund-2',
        name: 'Fund 2',
        targetAmount: target,
        startDate: CalendarDate(2026, 1, 1),
        targetDate: CalendarDate(2026, 12, 31),
        contributionFrequency: ContributionFrequency.monthly,
      );

      final all = await getAllFundsUseCase.execute(CalendarDate(2026, 2, 1));
      expect(all.length, 2);
      expect(all[0].calculationResult, isNotNull);
      expect(all[1].calculationResult, isNotNull);
    });
  });

  group('UpdateFundUseCase', () {
    test(
      'REQUIRED PERSISTENCE TEST: preserves exactly all transactions',
      () async {
        final target = Money(minorUnits: 100000, currency: Currency('USD'));
        final start = CalendarDate(2026, 1, 1);
        await createFundUseCase.execute(
          id: 'fund-edit',
          name: 'Original',
          targetAmount: target,
          startDate: start,
          targetDate: CalendarDate(2026, 12, 31),
          contributionFrequency: ContributionFrequency.monthly,
        );

        final t1 = Contribution(
          id: 't1',
          amount: Money(minorUnits: 10000, currency: Currency('USD')),
          date: CalendarDate(2026, 1, 15),
          note: 'note 1',
        );
        final t2 = Withdrawal(
          id: 't2',
          amount: Money(minorUnits: 5000, currency: Currency('USD')),
          date: CalendarDate(2026, 2, 15),
          note: 'note 2',
        );

        await repository.saveTransaction('fund-edit', t1);
        await repository.saveTransaction('fund-edit', t2);

        final beforeTxs = await repository.getTransactionsForFund('fund-edit');
        expect(beforeTxs.length, 2);

        await updateFundUseCase.execute(
          id: 'fund-edit',
          name: 'Updated',
          targetAmount: Money(minorUnits: 120000, currency: Currency('USD')),
        );

        final afterTxs = await repository.getTransactionsForFund('fund-edit');
        expect(afterTxs.length, 2);

        expect(afterTxs[0].id, t1.id);
        expect(afterTxs[0].amount, t1.amount);
        expect(afterTxs[0].amount.currency, t1.amount.currency);
        expect(afterTxs[0].date, t1.date);
        expect(afterTxs[0], isA<Contribution>());
        expect(afterTxs[0].note, t1.note);

        expect(afterTxs[1].id, t2.id);
        expect(afterTxs[1].amount, t2.amount);
        expect(afterTxs[1].amount.currency, t2.amount.currency);
        expect(afterTxs[1].date, t2.date);
        expect(afterTxs[1], isA<Withdrawal>());
        expect(afterTxs[1].note, t2.note);
      },
    );

    test(
      'REQUIRED RECALCULATION TEST: recalculates FundState and Trajectory properly',
      () async {
        final target = Money(minorUnits: 100000, currency: Currency('USD'));
        final start = CalendarDate(2026, 1, 1);
        await createFundUseCase.execute(
          id: 'fund-recalc',
          name: 'Original',
          targetAmount: target,
          startDate: start,
          targetDate: CalendarDate(2026, 12, 31),
          contributionFrequency: ContributionFrequency.monthly,
        );

        final t1 = Contribution(
          id: 't1',
          amount: Money(minorUnits: 50000, currency: Currency('USD')),
          date: CalendarDate(2026, 6, 1),
        );
        await repository.saveTransaction('fund-recalc', t1);

        final stateBefore = await getFundUseCase.execute(
          'fund-recalc',
          CalendarDate(2026, 6, 15),
        );
        expect(stateBefore.calculationResult.status, FundStatus.onTrack);
        expect(
          stateBefore.calculationResult.requiredContribution.minorUnits,
          8333,
        );

        await updateFundUseCase.execute(
          id: 'fund-recalc',
          targetAmount: Money(minorUnits: 50000, currency: Currency('USD')),
        );

        final stateAfter = await getFundUseCase.execute(
          'fund-recalc',
          CalendarDate(2026, 6, 15),
        );
        expect(stateAfter.calculationResult.status, FundStatus.complete);
        expect(stateAfter.calculationResult.requiredContribution.minorUnits, 0);
      },
    );

    test('throws InvalidFundDataError if currency is changed', () async {
      await createFundUseCase.execute(
        id: 'fund-curr',
        name: 'Currency',
        targetAmount: Money(minorUnits: 100000, currency: Currency('USD')),
        startDate: CalendarDate(2026, 1, 1),
        targetDate: CalendarDate(2026, 12, 31),
        contributionFrequency: ContributionFrequency.monthly,
      );

      expect(
        () => updateFundUseCase.execute(
          id: 'fund-curr',
          targetAmount: Money(minorUnits: 100000, currency: Currency('EUR')),
        ),
        throwsA(isA<InvalidFundDataError>()),
      );
    });

    test('throws InvalidFundDataError if invalid target date', () async {
      await createFundUseCase.execute(
        id: 'fund-date',
        name: 'Date',
        targetAmount: Money(minorUnits: 100000, currency: Currency('USD')),
        startDate: CalendarDate(2026, 6, 1),
        targetDate: CalendarDate(2026, 12, 31),
        contributionFrequency: ContributionFrequency.monthly,
      );

      expect(
        () => updateFundUseCase.execute(
          id: 'fund-date',
          targetDate: CalendarDate(2026, 5, 1), // Before start date
        ),
        throwsA(isA<InvalidFundDataError>()),
      );
    });
  });
}
