import '../../../domain/fund.dart';
import '../../../domain/money.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/schedule.dart';
import '../../../domain/repositories/fund_repository.dart';
import '../../../domain/exceptions.dart';
import '../../../data/exceptions.dart';
import '../../errors/application_error.dart';
import '../../ports/identifier_generator.dart';

class CreateFundUseCase {
  final FundRepository _repository;
  final IdentifierGenerator _identifierGenerator;

  const CreateFundUseCase(this._repository, this._identifierGenerator);

  Future<Fund> execute({
    String? id,
    required String name,
    required Money targetAmount,
    required CalendarDate startDate,
    required CalendarDate targetDate,
    required ContributionFrequency contributionFrequency,
  }) async {
    try {
      final fundId = id ?? _identifierGenerator.generate();

      final fund = Fund(
        id: fundId,
        name: name,
        targetAmount: targetAmount,
        startDate: startDate,
        targetDate: targetDate,
        contributionFrequency: contributionFrequency,
      );

      await _repository.saveFund(fund);
      return fund;
    } on ValidationException catch (e) {
      throw InvalidFundDataError(e.message);
    } on ConstraintViolationException catch (e) {
      throw PersistenceConstraintError(e.message);
    }
  }
}
