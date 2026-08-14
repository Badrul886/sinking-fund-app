import '../../ports/onboarding_settings_repository.dart';

class GetOnboardingStatusUseCase {
  final OnboardingSettingsRepository _repository;

  const GetOnboardingStatusUseCase(this._repository);

  Future<bool> execute() async {
    return await _repository.hasCompletedOnboarding();
  }
}
