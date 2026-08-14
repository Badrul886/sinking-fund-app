import '../../../domain/fund.dart';
import '../../../domain/money.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/schedule.dart';
import '../../../domain/repositories/fund_repository.dart';
import '../../../domain/exceptions.dart';
import '../../../data/exceptions.dart';
import '../../errors/application_error.dart';

class UpdateFundUseCase {
  final FundRepository _repository;

  const UpdateFundUseCase(this._repository);

  Future<Fund> execute({
    required String id,
    String? name,
    Money? targetAmount,
    CalendarDate? targetDate,
    ContributionFrequency? contributionFrequency,
  }) async {
    try {
      final currentFund = await _repository.getFund(id);
      if (currentFund == null) {
        throw FundNotFoundError(id);
      }

      if (targetAmount != null &&
          targetAmount.currency.code !=
              currentFund.targetAmount.currency.code) {
        throw InvalidFundDataError(
          'Cannot change the currency of an existing fund.',
        );
      }

      final updatedFund = currentFund.copyWith(
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
        contributionFrequency: contributionFrequency,
      );

      await _repository.updateFund(updatedFund);
      return updatedFund;
    } on ValidationException catch (e) {
      throw InvalidFundDataError(e.message);
    } on ConstraintViolationException catch (e) {
      throw PersistenceConstraintError(e.message);
    }
  }
}
