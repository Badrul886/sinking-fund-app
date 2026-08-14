import '../../../domain/money.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/transaction.dart';
import '../../../domain/exceptions.dart';
import '../../../data/exceptions.dart';
import '../../models/fund_state.dart';
import '../../errors/application_error.dart';
import '../../ports/identifier_generator.dart';
import '../fund/get_fund_use_case.dart';
import '../../../domain/repositories/fund_repository.dart';

class AddContributionUseCase {
  final FundRepository _repository;
  final GetFundUseCase _getFundUseCase;
  final IdentifierGenerator _identifierGenerator;

  const AddContributionUseCase(
    this._repository,
    this._getFundUseCase,
    this._identifierGenerator,
  );

  Future<FundState> execute({
    required String fundId,
    required Money amount,
    required CalendarDate date,
    required CalendarDate currentDate,
  }) async {
    try {
      // 1. Retrieve the target Fund state.
      final fundState = await _getFundUseCase.execute(fundId, currentDate);
      final fund = fundState.fund;

      // 2. Enforce currency consistency before persistence.
      if (fund.targetAmount.currency != amount.currency) {
        throw InvalidFundDataError(
          'Currency mismatch: Fund is ${fund.targetAmount.currency.code}, '
          'but contribution is ${amount.currency.code}',
        );
      }

      // 3. Construct domain Contribution.
      final transaction = Contribution(
        id: _identifierGenerator.generate(),
        amount: amount,
        date: date,
      );

      // 4. Persist transaction.
      await _repository.saveTransaction(fundId, transaction);

      // 5. Re-evaluate and return updated state.
      return await _getFundUseCase.execute(fundId, currentDate);
    } on RecordNotFoundException {
      throw const FundNotFoundError();
    } on ConstraintViolationException catch (e) {
      throw PersistenceConstraintError(e.message);
    } on ValidationException catch (e) {
      throw InvalidFundDataError(e.message);
    }
  }
}
