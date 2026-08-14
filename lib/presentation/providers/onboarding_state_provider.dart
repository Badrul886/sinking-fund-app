import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dependencies.dart';

// Provides the current onboarding status (true if complete, false if incomplete).
// The GoRouter will listen to this provider to determine if it should redirect to /onboarding.
final onboardingStateProvider = FutureProvider<bool>((ref) async {
  final getOnboardingStatus = ref.watch(getOnboardingStatusUseCaseProvider);
  return getOnboardingStatus.execute();
});
