import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/application/models/fund_preview.dart';
import 'package:sinking_fund/application/use_cases/fund/create_fund_use_case.dart';
import 'package:sinking_fund/application/use_cases/fund/calculate_fund_preview_use_case.dart';
import 'package:sinking_fund/presentation/screens/fund/create_fund_screen.dart';
import 'package:sinking_fund/presentation/providers/dependencies.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/fund_calculator.dart';
import 'package:sinking_fund/domain/trajectory.dart';
import 'package:sinking_fund/presentation/widgets/buttons/primary_action_button.dart';

// Mocks
class MockCreateFundUseCase implements CreateFundUseCase {
  bool wasCalled = false;
  Money? passedInitialSavings;

  @override
  Future<Fund> execute({
    String? id,
    required String name,
    required Money targetAmount,
    required CalendarDate startDate,
    required CalendarDate targetDate,
    required ContributionFrequency contributionFrequency,
    Money? initialSavings,
  }) async {
    wasCalled = true;
    passedInitialSavings = initialSavings;
    return Fund(
      id: 'mock-id',
      name: name,
      targetAmount: targetAmount,
      startDate: startDate,
      targetDate: targetDate,
      contributionFrequency: contributionFrequency,
    );
  }
}

class MockCalculateFundPreviewUseCase implements CalculateFundPreviewUseCase {
  @override
  FundPreview execute({
    required Money targetAmount,
    required CalendarDate startDate,
    required CalendarDate targetDate,
    required ContributionFrequency contributionFrequency,
    required Money initialSavings,
    required CalendarDate currentDate,
  }) {
    final status = initialSavings.minorUnits > targetAmount.minorUnits
        ? FundStatus.overfunded
        : FundStatus.onTrack;

    return FundPreview(
      calculationResult: FundCalculationResult(
        currentBalance: initialSavings,
        remainingAmount: Money(
          minorUnits: targetAmount.minorUnits - initialSavings.minorUnits,
          currency: targetAmount.currency,
        ),
        totalPeriods: 10,
        elapsedPeriods: 0,
        remainingPeriods: 10,
        requiredContribution: const Money(
          minorUnits: 1000,
          currency: Currency('USD'),
        ),
        expectedBalance: initialSavings,
        progress: initialSavings.minorUnits / targetAmount.minorUnits,
        status: status,
      ),
      trajectory: Trajectory(historicalPoints: [], futurePoints: []),
    );
  }
}

void main() {
  Widget createTestWidget(ProviderContainer container, {GoRouter? router}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig:
            router ??
            GoRouter(
              initialLocation: '/fund/create',
              routes: [
                GoRoute(
                  path: '/fund/create',
                  builder: (context, state) => const CreateFundScreen(),
                ),
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Dashboard')),
                ),
              ],
            ),
      ),
    );
  }

  testWidgets('CreateFundScreen allows input and shows preview', (
    tester,
  ) async {
    final mockCalculate = MockCalculateFundPreviewUseCase();
    final mockCreate = MockCreateFundUseCase();

    final container = ProviderContainer(
      overrides: [
        calculateFundPreviewUseCaseProvider.overrideWithValue(mockCalculate),
        createFundUseCaseProvider.overrideWithValue(mockCreate),
      ],
    );

    await tester.pumpWidget(createTestWidget(container));
    await tester.pumpAndSettle();

    // Find inputs
    final nameField = find.widgetWithText(TextField, 'Fund Name');
    final targetField = find.widgetWithText(TextField, 'Target Amount');
    final initialField = find.widgetWithText(
      TextField,
      'Initial Savings (Optional)',
    );

    // Preview shouldn't be visible initially
    expect(find.text('Preview'), findsNothing);

    // Enter name
    await tester.enterText(nameField, 'My Fund');
    // Enter target
    await tester.enterText(targetField, '1000.00');
    // Select date
    await tester.tap(find.text('Select a date'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('OK'),
    ); // Picks default date (usually today + 30)
    await tester.pumpAndSettle();

    // Now preview should be visible
    expect(find.text('Preview'), findsOneWidget);

    // Initial savings is 0, status is onTrack
    expect(find.text('This fund is overfunded!'), findsNothing);

    // Enter large initial savings
    await tester.enterText(initialField, '2000.00');
    await tester.pumpAndSettle();

    // Should show overfunded status
    expect(find.text('This fund is overfunded!'), findsOneWidget);

    // Tap create
    final createButton = find.widgetWithText(
      PrimaryActionButton,
      'Create Fund',
    );
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(mockCreate.wasCalled, isTrue);
    expect(mockCreate.passedInitialSavings!.minorUnits, 200000);

    // Navigated to Dashboard
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
