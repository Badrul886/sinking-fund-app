import '../../../domain/repositories/fund_repository.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/fund_calculator.dart';
import '../../models/fund_state.dart';

class GetAllFundsUseCase {
  final FundRepository _repository;

  const GetAllFundsUseCase(this._repository);

  Future<List<FundState>> execute(CalendarDate currentDate) async {
    final funds = await _repository.getAllFunds();
    final results = <FundState>[];

    for (final fund in funds) {
      final transactions = await _repository.getTransactionsForFund(fund.id);
      final calcResult = FundCalculator.calculate(
        fund: fund,
        currentDate: currentDate,
        transactions: transactions,
      );

      results.add(
        FundState(
          fund: fund,
          transactions: transactions,
          calculationResult: calcResult,
        ),
      );
    }

    return results;
  }
}
