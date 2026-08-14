import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sinking_fund/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:sinking_fund/presentation/providers/dependencies.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/application/use_cases/onboarding/complete_initial_onboarding_use_case.dart';
import 'package:sinking_fund/application/use_cases/fund/calculate_fund_preview_use_case.dart';
import 'package:sinking_fund/application/models/fund_preview.dart';
import 'package:sinking_fund/domain/fund_calculator.dart';
import 'package:sinking_fund/application/ports/clock.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/trajectory.dart';
import 'package:sinking_fund/domain/money.dart';

class MockCompleteInitialOnboardingUseCase
    implements CompleteInitialOnboardingUseCase {
  bool called = false;
  bool shouldFail = false;

  @override
  Future<FundPreview> execute({
    required String name,
    required Money targetAmount,
    required CalendarDate targetDate,
    required ContributionFrequency frequency,
    required Money initialSavings,
  }) async {
    if (shouldFail) throw Exception('Atomic failure');
    called = true;
    return FundPreview(
      calculationResult: FundCalculationResult(
        currentBalance: initialSavings,
        remainingAmount: Money.zero(targetAmount.currency),
        totalPeriods: 1,
        elapsedPeriods: 0,
        remainingPeriods: 1,
        requiredContribution: Money.zero(targetAmount.currency),
        expectedBalance: initialSavings,
        progress: 0.5,
        status: FundStatus.onTrack,
      ),
      trajectory: Trajectory(historicalPoints: [], futurePoints: []),
    );
  }
}

class MockClock implements Clock {
  @override
  CalendarDate today() => CalendarDate(2025, 1, 1);
}

void main() {
  group('OnboardingScreen', () {
    late MockCompleteInitialOnboardingUseCase mockCompleteUseCase;

    Widget createTestableWidget() {
      final router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Text('Dashboard')),
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          completeInitialOnboardingUseCaseProvider.overrideWithValue(
            mockCompleteUseCase,
          ),
          clockProvider.overrideWithValue(MockClock()),
          calculateFundPreviewUseCaseProvider.overrideWithValue(
            const CalculateFundPreviewUseCase(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    setUp(() {
      mockCompleteUseCase = MockCompleteInitialOnboardingUseCase();
    });

    testWidgets('completes onboarding flow', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());

      // Step 0: Welcome
      expect(find.text('Welcome to Sinking Fund!'), findsOneWidget);
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Step 1: Inputs
      expect(find.text('Fund Name'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'My Fund');
      await tester.enterText(find.byType(TextField).at(1), '1000.00');

      // Need to open date picker
      await tester.tap(find.text('Select a date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(2), '100.00');

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      // Step 2: Preview
      expect(find.text('My Fund'), findsOneWidget);
      expect(find.text('Looks Good'), findsOneWidget);

      await tester.tap(find.text('Looks Good'));
      await tester.pumpAndSettle();

      // Step 3: Confirmation
      expect(find.text('Ready to start?'), findsOneWidget);
      await tester.tap(find.text('Create Fund'));
      await tester.pumpAndSettle();

      // Navigates to Dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(mockCompleteUseCase.called, isTrue);
    });

    testWidgets('back navigation retains state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Test Name');
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Sinking Fund!'), findsOneWidget);

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // State is retained
      expect(find.text('Test Name'), findsOneWidget);
    });

    testWidgets('failure keeps draft state', (WidgetTester tester) async {
      mockCompleteUseCase.shouldFail = true;

      await tester.pumpWidget(createTestableWidget());

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), 'Test Name');
      await tester.enterText(find.byType(TextField).at(1), '1000.00');

      // Date
      await tester.tap(find.text('Select a date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Looks Good'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Fund'));
      await tester.pumpAndSettle();

      // Should show error but stay on confirmation step
      expect(find.text('Exception: Atomic failure'), findsOneWidget);
      expect(find.text('Ready to start?'), findsOneWidget);
    });
  });
}
