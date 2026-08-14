import 'fund.dart';
import 'transaction.dart';
import 'calendar_date.dart';
import 'money.dart';
import 'trajectory.dart';
import 'fund_calculator.dart';

class TrajectoryCalculator {
  static Trajectory calculate({
    required Fund fund,
    required List<Transaction> transactions,
    required CalendarDate currentDate,
  }) {
    // 1. Calculate Historical Points
    final historicalPoints = <HistoricalPoint>[];
    Money runningBalance = Money.zero(fund.targetAmount.currency);

    // Group transactions by date
    final transactionsByDate = <CalendarDate, List<Transaction>>{};
    for (final tx in transactions) {
      if (!transactionsByDate.containsKey(tx.date)) {
        transactionsByDate[tx.date] = [];
      }
      transactionsByDate[tx.date]!.add(tx);
    }

    // Sort dates
    final sortedDates = transactionsByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    for (final date in sortedDates) {
      final txsOnDate = transactionsByDate[date]!;
      for (final tx in txsOnDate) {
        if (tx is Contribution) {
          runningBalance += tx.amount;
        } else if (tx is Withdrawal) {
          runningBalance -= tx.amount;
        }
      }
      historicalPoints.add(
        HistoricalPoint(date: date, balance: runningBalance),
      );
    }

    // 2. Calculate Future Points
    final futurePoints = <FuturePoint>[];

    if (currentDate <= fund.targetDate) {
      final scheduleDates = fund.schedule.generateDates(fund.targetDate);
      final simulatedTransactions = List<Transaction>.from(transactions);

      for (final date in scheduleDates) {
        if (date > currentDate) {
          // Calculate required contribution at this point in time
          final result = FundCalculator.calculate(
            fund: fund,
            currentDate: date,
            transactions: simulatedTransactions,
          );

          final requiredContrib = result.requiredContribution;

          if (requiredContrib.minorUnits > 0) {
            simulatedTransactions.add(
              Contribution(
                id: 'simulated-${date.toString()}',
                amount: requiredContrib,
                date: date,
              ),
            );
          }

          final projectedBalance = result.currentBalance + requiredContrib;

          futurePoints.add(
            FuturePoint(
              date: date,
              projectedBalance: projectedBalance,
              requiredContribution: requiredContrib,
            ),
          );
        }
      }
    }

    return Trajectory(
      historicalPoints: historicalPoints,
      futurePoints: futurePoints,
    );
  }
}
