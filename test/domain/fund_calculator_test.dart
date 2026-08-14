import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/transaction.dart';
import 'package:sinking_fund/domain/fund_calculator.dart';
import 'package:sinking_fund/domain/exceptions.dart';

void main() {
  const usd = Currency('USD');

  Fund createFund(
    CalendarDate start,
    CalendarDate target,
    int targetMinorUnits,
  ) {
    return Fund(
      id: '1',
      name: 'Test',
      targetAmount: Money(minorUnits: targetMinorUnits, currency: usd),
      startDate: start,
      targetDate: target,
      contributionFrequency: ContributionFrequency.monthly,
    );
  }

  group('FundCalculator', () {
    test('First period NOT_STARTED', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 3, 1);
      final fund = createFund(start, target, 10000);

      final result = FundCalculator.calculate(
        fund: fund,
        currentDate: start,
        transactions: [],
      );

      expect(result.status, FundStatus.notStarted);
      expect(result.elapsedPeriods, 0);
      expect(result.totalPeriods, 3);
      expect(result.remainingPeriods, 3);
      expect(result.expectedBalance.minorUnits, 0);
      expect(result.requiredContribution.minorUnits, 3333); // 10000 / 3
    });

    test('Residual rounding absorption 100.00 / 3', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 3, 1);
      final fund = createFund(start, target, 10000); // 100.00

      // Month 1
      final r1 = FundCalculator.calculate(
        fund: fund,
        currentDate: start,
        transactions: [],
      );
      expect(r1.requiredContribution.minorUnits, 3333);

      // Pay month 1
      final t1 = Contribution(
        id: 't1',
        amount: r1.requiredContribution,
        date: start,
      );

      // Month 2
      final d2 = CalendarDate(2023, 2, 1);
      final r2 = FundCalculator.calculate(
        fund: fund,
        currentDate: d2,
        transactions: [t1],
      );
      expect(r2.remainingAmount.minorUnits, 6667);
      expect(r2.remainingPeriods, 2);
      expect(
        r2.requiredContribution.minorUnits,
        3334,
      ); // 6667 / 2 = 3333.5 -> 3334

      // Pay month 2
      final t2 = Contribution(
        id: 't2',
        amount: r2.requiredContribution,
        date: d2,
      );

      // Month 3
      final d3 = CalendarDate(2023, 3, 1);
      final r3 = FundCalculator.calculate(
        fund: fund,
        currentDate: d3,
        transactions: [t1, t2],
      );
      expect(r3.remainingAmount.minorUnits, 3333);
      expect(r3.remainingPeriods, 1);
      expect(r3.requiredContribution.minorUnits, 3333); // 3333 / 1
    });

    test('Expected balance precision', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 3, 1);
      final fund = createFund(start, target, 10000); // 100.00

      // 1 period elapsed
      final r1 = FundCalculator.calculate(
        fund: fund,
        currentDate: CalendarDate(2023, 2, 1),
        transactions: [],
      );
      expect(r1.expectedBalance.minorUnits, 3333);

      // 2 periods elapsed
      final r2 = FundCalculator.calculate(
        fund: fund,
        currentDate: CalendarDate(2023, 3, 1),
        transactions: [],
      );
      expect(r2.expectedBalance.minorUnits, 6667); // not 6666
    });

    test('Precedence: OVERFUNDED > DEADLINE_PASSED', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 1, 1);
      final fund = createFund(start, target, 10000);

      final t = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 11000, currency: usd),
        date: start,
      );
      final result = FundCalculator.calculate(
        fund: fund,
        currentDate: CalendarDate(2023, 1, 2),
        transactions: [t],
      );

      expect(result.status, FundStatus.overfunded);
    });

    test('Precedence: COMPLETE > DEADLINE_PASSED', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 1, 1);
      final fund = createFund(start, target, 10000);

      final t = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 10000, currency: usd),
        date: start,
      );
      final result = FundCalculator.calculate(
        fund: fund,
        currentDate: CalendarDate(2023, 1, 2),
        transactions: [t],
      );

      expect(result.status, FundStatus.complete);
    });

    test('Missed contribution is BEHIND', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 3, 1);
      final fund = createFund(start, target, 10000);

      final result = FundCalculator.calculate(
        fund: fund,
        currentDate: CalendarDate(2023, 2, 1), // 1 period elapsed
        transactions: [], // missed
      );

      expect(result.status, FundStatus.behind);
    });

    test('Withdrawal exceeding balance throws', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 3, 1);
      final fund = createFund(start, target, 10000);

      final t1 = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 100, currency: usd),
        date: start,
      );
      final t2 = Withdrawal(
        id: 't2',
        amount: const Money(minorUnits: 200, currency: usd),
        date: start,
      );

      expect(
        () => FundCalculator.calculate(
          fund: fund,
          currentDate: start,
          transactions: [t1, t2],
        ),
        throwsA(isA<InsufficientFundsException>()),
      );
    });

    test(
      'Zero remaining periods, but amount > 0 means required is remaining',
      () {
        final start = CalendarDate(2023, 1, 1);
        final target = CalendarDate(2023, 1, 1);
        final fund = createFund(start, target, 10000);

        final result = FundCalculator.calculate(
          fund: fund,
          currentDate: CalendarDate(2023, 1, 2), // past target
          transactions: [],
        );

        expect(result.remainingPeriods, 0);
        expect(result.remainingAmount.minorUnits, 10000);
        expect(
          result.requiredContribution.minorUnits,
          10000,
        ); // due immediately
      },
    );

    test('ON_TRACK status for exact expected balance', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 3, 1);
      final fund = createFund(start, target, 10000); // 100.00

      // 1 period elapsed
      final t1 = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 3333, currency: usd),
        date: start,
      );
      final result = FundCalculator.calculate(
        fund: fund,
        currentDate: CalendarDate(2023, 2, 1),
        transactions: [t1],
      );

      expect(result.status, FundStatus.onTrack);
    });

    test('AHEAD status for > expected balance but < target', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 3, 1);
      final fund = createFund(start, target, 10000); // 100.00

      // 1 period elapsed, 3333 expected, but user contributed 5000
      final t1 = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 5000, currency: usd),
        date: start,
      );
      final result = FundCalculator.calculate(
        fund: fund,
        currentDate: CalendarDate(2023, 2, 1),
        transactions: [t1],
      );

      expect(result.status, FundStatus.ahead);
    });

    test('DEADLINE_PASSED status when underfunded and past deadline', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 3, 1);
      final fund = createFund(start, target, 10000);

      final t1 = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 5000, currency: usd),
        date: start,
      );
      final result = FundCalculator.calculate(
        fund: fund,
        currentDate: CalendarDate(2023, 3, 2), // Past target date
        transactions: [t1], // Underfunded (5000 < 10000)
      );

      expect(result.status, FundStatus.deadlinePassed);
    });

    test('Target = 0 behaves correctly as open pool', () {
      final start = CalendarDate(2023, 1, 1);
      final target = CalendarDate(2023, 3, 1);
      final fund = createFund(start, target, 0); // target=0

      final t1 = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 1000, currency: usd),
        date: start,
      );
      final result = FundCalculator.calculate(
        fund: fund,
        currentDate: CalendarDate(2023, 2, 1),
        transactions: [t1],
      );

      // balance > target (1000 > 0) -> Overfunded!
      // Because open pools with 0 target are technically instantly 'overfunded' if they have money,
      // or 'complete' if they have 0. Let's see the spec logic:
      expect(result.status, FundStatus.overfunded);
      expect(result.progress, 0.0);
    });
  });
}
