import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/trajectory_calculator.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/transaction.dart';

void main() {
  final usd = Currency('USD');

  Fund createFund({
    int target = 120000,
    CalendarDate? start,
    CalendarDate? targetDate,
  }) {
    return Fund(
      id: 'test-fund',
      name: 'Test Fund',
      targetAmount: Money(minorUnits: target, currency: usd),
      startDate: start ?? CalendarDate(2025, 1, 1),
      targetDate: targetDate ?? CalendarDate(2025, 12, 1),
      contributionFrequency: ContributionFrequency.monthly,
    );
  }

  test('Calculates historical points grouped by date correctly', () {
    final fund = createFund();
    final transactions = [
      Contribution(
        id: '1',
        amount: Money(minorUnits: 10000, currency: usd),
        date: CalendarDate(2025, 1, 1),
      ),
      Contribution(
        id: '2',
        amount: Money(minorUnits: 5000, currency: usd),
        date: CalendarDate(2025, 1, 1),
      ),
      Withdrawal(
        id: '3',
        amount: Money(minorUnits: 2000, currency: usd),
        date: CalendarDate(2025, 2, 1),
      ),
    ];

    final trajectory = TrajectoryCalculator.calculate(
      fund: fund,
      transactions: transactions,
      currentDate: CalendarDate(2025, 3, 1),
    );

    expect(trajectory.historicalPoints.length, 2);
    expect(trajectory.historicalPoints[0].date, CalendarDate(2025, 1, 1));
    expect(trajectory.historicalPoints[0].balance.minorUnits, 15000);

    expect(trajectory.historicalPoints[1].date, CalendarDate(2025, 2, 1));
    expect(trajectory.historicalPoints[1].balance.minorUnits, 13000);
  });

  test(
    'Calculates future points iteratively based on required contribution',
    () {
      final fund =
          createFund(); // Target: 120000, Monthly 12 months. 10000 per month.

      final trajectory = TrajectoryCalculator.calculate(
        fund: fund,
        transactions: [],
        currentDate: CalendarDate(2025, 10, 1),
      );

      // Remaining periods: Oct 1, Nov 1, Dec 1 = 3.
      // Target = 120000. Required = 40000.

      expect(trajectory.futurePoints.length, 2); // Nov 1, Dec 1

      expect(trajectory.futurePoints[0].date, CalendarDate(2025, 11, 1));
      expect(trajectory.futurePoints[0].requiredContribution.minorUnits, 60000);
      expect(
        trajectory.futurePoints[0].projectedBalance.minorUnits,
        60000,
      ); // Because current balance is 0.

      expect(trajectory.futurePoints[1].date, CalendarDate(2025, 12, 1));
      expect(trajectory.futurePoints[1].requiredContribution.minorUnits, 60000);
      expect(trajectory.futurePoints[1].projectedBalance.minorUnits, 120000);
    },
  );

  test('Handles edge cases: Target reached', () {
    final fund = createFund();
    final transactions = [
      Contribution(
        id: '1',
        amount: Money(minorUnits: 120000, currency: usd),
        date: CalendarDate(2025, 1, 1),
      ),
    ];

    final trajectory = TrajectoryCalculator.calculate(
      fund: fund,
      transactions: transactions,
      currentDate: CalendarDate(2025, 1, 1),
    );

    for (final point in trajectory.futurePoints) {
      expect(point.requiredContribution.minorUnits, 0);
      expect(point.projectedBalance.minorUnits, 120000);
    }
  });

  test('Handles edge cases: Deadline passed', () {
    final fund = createFund(
      start: CalendarDate(2024, 1, 1),
      targetDate: CalendarDate(2024, 12, 1),
    );

    final trajectory = TrajectoryCalculator.calculate(
      fund: fund,
      transactions: [],
      currentDate: CalendarDate(2025, 1, 1), // Past deadline
    );

    expect(trajectory.futurePoints.isEmpty, isTrue);
  });
}
