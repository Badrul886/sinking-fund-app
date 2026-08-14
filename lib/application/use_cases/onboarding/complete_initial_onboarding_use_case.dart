import '../../../domain/fund.dart';
import '../../../domain/transaction.dart';
import '../../../domain/money.dart';
import '../../../domain/calendar_date.dart';
import '../../../domain/schedule.dart';
import '../../ports/clock.dart';
import '../../ports/identifier_generator.dart';
import '../../ports/onboarding_repository.dart';
import '../../models/fund_preview.dart';
import '../../../domain/fund_calculator.dart';
import '../../../domain/trajectory_calculator.dart';

class CompleteInitialOnboardingUseCase {
  final Clock _clock;
  final OnboardingRepository _onboardingRepository;
  final IdentifierGenerator _identifierGenerator;

  const CompleteInitialOnboardingUseCase(
    this._clock,
    this._onboardingRepository,
    this._identifierGenerator,
  );

  Future<FundPreview> execute({
    required String name,
    required Money targetAmount,
    required CalendarDate targetDate,
    required ContributionFrequency frequency,
    required Money initialSavings,
  }) async {
    final startDate = _clock.today();
    final fundId = _identifierGenerator.generate();

    final fund = Fund(
      id: fundId,
      name: name,
      targetAmount: targetAmount,
      startDate: startDate,
      targetDate: targetDate,
      contributionFrequency: frequency,
    );

    Contribution? initialContribution;
    if (initialSavings.minorUnits > 0) {
      initialContribution = Contribution(
        id: _identifierGenerator.generate(),
        amount: initialSavings,
        date: startDate,
        note: 'Initial savings',
      );
    }

    // Atomic persistence
    await _onboardingRepository.completeOnboarding(fund, initialContribution);

    // After persistence, calculate the final authoritative state to return
    final transactions = initialContribution != null ? [initialContribution] : <Transaction>[];
    
    final calculationResult = FundCalculator.calculate(
      fund: fund, 
      currentDate: startDate,
      transactions: transactions
    );
    
    final trajectory = TrajectoryCalculator.calculate(
      fund: fund, 
      transactions: transactions, 
      currentDate: startDate
    );

    return FundPreview(
      calculationResult: calculationResult,
      trajectory: trajectory,
    );
  }
}
