import 'fund.dart';
import 'money.dart';
import 'calendar_date.dart';
import 'transaction.dart';
import 'exceptions.dart';

class FundCalculationResult {
  final Money currentBalance;
  final Money remainingAmount;
  final int totalPeriods;
  final int elapsedPeriods;
  final int remainingPeriods;
  final Money requiredContribution;
  final Money expectedBalance;
  final double progress;
  final FundStatus status;

  FundCalculationResult({
    required this.currentBalance,
    required this.remainingAmount,
    required this.totalPeriods,
    required this.elapsedPeriods,
    required this.remainingPeriods,
    required this.requiredContribution,
    required this.expectedBalance,
    required this.progress,
    required this.status,
  });
}

class FundCalculator {
  static FundCalculationResult calculate({
    required Fund fund,
    required CalendarDate currentDate,
    required List<Transaction> transactions,
  }) {
    Money balance = Money.zero(fund.targetAmount.currency);
    int contributionCount = 0;

    for (final tx in transactions) {
      if (tx is Contribution) {
        balance += tx.amount;
        contributionCount++;
      } else if (tx is Withdrawal) {
        if (balance < tx.amount) {
          throw InsufficientFundsException();
        }
        balance -= tx.amount;
      }
    }

    Money remainingAmount = balance >= fund.targetAmount
        ? Money.zero(fund.targetAmount.currency)
        : fund.targetAmount - balance;

    CalendarDate maxDate = fund.targetDate > currentDate
        ? fund.targetDate
        : currentDate;
    final scheduleDates = fund.schedule.generateDates(maxDate);

    int totalPeriods = 0;
    int elapsedPeriods = 0;
    int remainingPeriods = 0;

    for (final d in scheduleDates) {
      if (d >= fund.startDate && d <= fund.targetDate) {
        totalPeriods++;
      }
      if (d >= fund.startDate && d < currentDate) {
        elapsedPeriods++;
      }
      if (d >= currentDate && d <= fund.targetDate) {
        remainingPeriods++;
      }
    }

    Money requiredContrib = Money.zero(fund.targetAmount.currency);
    if (remainingAmount > Money.zero(fund.targetAmount.currency)) {
      if (remainingPeriods == 0) {
        requiredContrib = remainingAmount;
      } else {
        requiredContrib = remainingAmount.divide(remainingPeriods);
      }
    }

    int expectedMinorUnits = 0;
    if (totalPeriods > 0) {
      expectedMinorUnits = Money.multiplyAndDivide(
        fund.targetAmount.minorUnits,
        elapsedPeriods,
        totalPeriods,
      );
    } else if (elapsedPeriods > 0) {
      expectedMinorUnits = fund.targetAmount.minorUnits;
    }
    Money expectedBalance = Money(
      minorUnits: expectedMinorUnits,
      currency: fund.targetAmount.currency,
    );

    double progress = fund.targetAmount.minorUnits == 0
        ? 0.0
        : balance.minorUnits / fund.targetAmount.minorUnits;

    FundStatus status;
    if (balance > fund.targetAmount) {
      status = FundStatus.overfunded;
    } else if (balance == fund.targetAmount) {
      status = FundStatus.complete;
    } else if (currentDate > fund.targetDate) {
      status = FundStatus.deadlinePassed;
    } else if (contributionCount == 0 && elapsedPeriods == 0) {
      status = FundStatus.notStarted;
    } else if (balance > expectedBalance) {
      status = FundStatus.ahead;
    } else if (balance == expectedBalance) {
      status = FundStatus.onTrack;
    } else {
      status = FundStatus.behind;
    }

    return FundCalculationResult(
      currentBalance: balance,
      remainingAmount: remainingAmount,
      totalPeriods: totalPeriods,
      elapsedPeriods: elapsedPeriods,
      remainingPeriods: remainingPeriods,
      requiredContribution: requiredContrib,
      expectedBalance: expectedBalance,
      progress: progress,
      status: status,
    );
  }
}
