abstract class OnboardingSettingsRepository {
  Future<bool> hasCompletedOnboarding();
  Future<void> setOnboardingCompleted();
}
