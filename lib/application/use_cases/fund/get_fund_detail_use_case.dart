import '../../../domain/repositories/fund_repository.dart';
import '../../../domain/fund_calculator.dart';
import '../../../domain/trajectory_calculator.dart';
import '../../../data/exceptions.dart';
import '../../models/fund_state.dart';
import '../../models/fund_detail_state.dart';
import '../../errors/application_error.dart';
import '../../ports/clock.dart';

class GetFundDetailUseCase {
  final FundRepository _repository;
  final Clock _clock;

  const GetFundDetailUseCase(this._repository, this._clock);

  Future<FundDetailState> execute(String id) async {
    try {
      final fund = await _repository.getFund(id);
      if (fund == null) {
        throw const FundNotFoundError();
      }

      final transactions = await _repository.getTransactionsForFund(id);
      final currentDate = _clock.today();

      final calcResult = FundCalculator.calculate(
        fund: fund,
        currentDate: currentDate,
        transactions: transactions,
      );

      final trajectory = TrajectoryCalculator.calculate(
        fund: fund,
        transactions: transactions,
        currentDate: currentDate,
      );

      return FundDetailState(
        fundState: FundState(
          fund: fund,
          transactions: transactions,
          calculationResult: calcResult,
        ),
        trajectory: trajectory,
      );
    } on RecordNotFoundException {
      throw const FundNotFoundError();
    }
  }
}
