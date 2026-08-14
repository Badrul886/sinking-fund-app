import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/application/use_cases/onboarding/get_onboarding_status_use_case.dart';
import 'package:sinking_fund/presentation/providers/dependencies.dart';
import 'package:sinking_fund/presentation/routing/router.dart';

class MockGetOnboardingStatusUseCase implements GetOnboardingStatusUseCase {
  bool isComplete;
  MockGetOnboardingStatusUseCase(this.isComplete);

  @override
  Future<bool> execute() async => isComplete;
}

void main() {
  group('Router Configuration', () {
    testWidgets('Redirects to /onboarding when onboarding is incomplete', (tester) async {
      final mockUseCase = MockGetOnboardingStatusUseCase(false);
      
      final container = ProviderContainer(
        overrides: [
          getOnboardingStatusUseCaseProvider.overrideWithValue(mockUseCase),
        ],
      );

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Wait for future provider to resolve
      await tester.pumpAndSettle();

      expect(find.text('Onboarding'), findsWidgets);
      expect(find.text('Dashboard'), findsNothing);
    });

    testWidgets('Redirects to / when onboarding is complete', (tester) async {
      final mockUseCase = MockGetOnboardingStatusUseCase(true);
      
      final container = ProviderContainer(
        overrides: [
          getOnboardingStatusUseCaseProvider.overrideWithValue(mockUseCase),
        ],
      );

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Onboarding'), findsNothing);
    });
  });
}
