import 'money.dart';
import 'calendar_date.dart';

/// Represents a precise trajectory point in the past based on actual transactions.
class HistoricalPoint {
  /// The exact source date of the transaction(s).
  final CalendarDate date;

  /// The exact accumulated balance at the end of this date.
  final Money balance;

  HistoricalPoint({required this.date, required this.balance});
}

/// Represents a projected trajectory point in the future based on scheduled contributions.
class FuturePoint {
  /// The exact scheduled date for the projected contribution.
  final CalendarDate date;

  /// The projected balance after the simulated contribution is made.
  final Money projectedBalance;

  /// The dynamically recalculated required contribution for this specific date.
  final Money requiredContribution;

  FuturePoint({
    required this.date,
    required this.projectedBalance,
    required this.requiredContribution,
  });
}

/// The exact Domain trajectory contract.
///
/// **Contract explicitly defining behavior:**
/// - **Historical points**:
///   - Mapped from the provided list of actual transactions.
///   - Grouped by `date`.
///   - Balance is the running total at the end of that date.
/// - **Future points**:
///   - Generated using the fund's `ContributionSchedule` up to `targetDate`.
///   - For each scheduled date strictly after `currentDate`, the balance is projected
///     by dynamically computing the `requiredContribution` (using `FundCalculator` semantics)
///     and simulating a contribution of that amount.
///   - This ensures residual rounding behaves identically to the authoritative calculator.
/// - **Edge cases**:
///   - **Target reached / Overfunded**: Future `requiredContribution` becomes zero. Future points
///     will reflect a flat projected balance (remaining flat up to `targetDate`).
///   - **Deadline passed**: If `currentDate > targetDate`, the schedule produces no future points.
///   - **Zero target**: Target is 0, so target is reached immediately. Future points remain flat at 0.
///   - **Same-day target**: Handled correctly as the schedule generates dates including the target date if applicable.
///   - **Target-date endpoint**: The future points will always include the `targetDate` if the schedule lands on it,
///     or we explicitly cap the schedule generation at `targetDate`.
class Trajectory {
  final List<HistoricalPoint> historicalPoints;
  final List<FuturePoint> futurePoints;

  Trajectory({required this.historicalPoints, required this.futurePoints});
}
