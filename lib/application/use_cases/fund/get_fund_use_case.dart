import '../../../domain/repositories/fund_repository.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/fund_calculator.dart';
import '../../../data/exceptions.dart';
import '../../models/fund_state.dart';
import '../../errors/application_error.dart';

class GetFundUseCase {
  final FundRepository _repository;

  const GetFundUseCase(this._repository);

  Future<FundState> execute(String id, CalendarDate currentDate) async {
    try {
      final fund = await _repository.getFund(id);
      if (fund == null) {
        throw const FundNotFoundError();
      }

      final transactions = await _repository.getTransactionsForFund(id);

      final calcResult = FundCalculator.calculate(
        fund: fund,
        currentDate: currentDate,
        transactions: transactions,
      );

      return FundState(
        fund: fund,
        transactions: transactions,
        calculationResult: calcResult,
      );
    } on RecordNotFoundException {
      throw const FundNotFoundError();
    }
  }
}
