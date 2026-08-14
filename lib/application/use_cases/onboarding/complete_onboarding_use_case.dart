import '../../ports/onboarding_settings_repository.dart';

class CompleteOnboardingUseCase {
  final OnboardingSettingsRepository _repository;

  const CompleteOnboardingUseCase(this._repository);

  Future<void> execute() async {
    await _repository.setOnboardingCompleted();
  }
}
