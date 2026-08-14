import '../../../domain/fund.dart';
import '../../../domain/money.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/schedule.dart';
import '../../../domain/transaction.dart';
import '../../../domain/fund_calculator.dart';

class CalculateFundPreviewUseCase {
  const CalculateFundPreviewUseCase();

  FundCalculationResult execute({
    required Money targetAmount,
    required CalendarDate startDate,
    required CalendarDate targetDate,
    required ContributionFrequency contributionFrequency,
    required Money initialSavings,
    required CalendarDate currentDate,
  }) {
    // Construct in-memory domain objects strictly for preview calculations.
    // They are not persisted.
    final previewFund = Fund(
      id: 'preview-fund',
      name: 'Preview',
      targetAmount: targetAmount,
      startDate: startDate,
      targetDate: targetDate,
      contributionFrequency: contributionFrequency,
    );

    final transactions = <Transaction>[];

    if (initialSavings.minorUnits > 0) {
      if (initialSavings.currency.code != targetAmount.currency.code) {
        throw ArgumentError(
          'initialSavings currency must match targetAmount currency',
        );
      }

      transactions.add(
        Contribution(
          id: 'preview-initial-savings',
          amount: initialSavings,
          date: currentDate,
        ),
      );
    }

    return FundCalculator.calculate(
      fund: previewFund,
      currentDate: currentDate,
      transactions: transactions,
    );
  }
}
