import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/application/models/fund_detail_state.dart';
import 'package:sinking_fund/application/models/fund_state.dart';
import 'package:sinking_fund/domain/fund_calculator.dart';
import 'package:sinking_fund/domain/trajectory.dart';
import 'package:sinking_fund/presentation/screens/fund/edit_fund_screen.dart';
import 'package:sinking_fund/presentation/state/fund_detail_notifier.dart';
import 'package:sinking_fund/application/errors/application_error.dart';
import 'package:sinking_fund/presentation/widgets/buttons/primary_action_button.dart';
import 'package:sinking_fund/application/use_cases/fund/update_fund_use_case.dart';
import 'package:sinking_fund/presentation/providers/dependencies.dart';

// A mock use case that we can intercept
class MockUpdateFundUseCase implements UpdateFundUseCase {
  bool throwError = false;
  ApplicationError? errorToThrow;
  int callCount = 0;
  Completer<void>? delayCompleter;

  String? lastId;
  String? lastName;
  Money? lastTargetAmount;
  CalendarDate? lastTargetDate;
  ContributionFrequency? lastFrequency;

  @override
  Future<Fund> execute({
    required String id,
    String? name,
    Money? targetAmount,
    CalendarDate? targetDate,
    ContributionFrequency? contributionFrequency,
  }) async {
    callCount++;
    if (throwError) {
      if (errorToThrow != null) throw errorToThrow!;
      throw InvalidFundDataError('Mock error');
    }

    lastId = id;
    lastName = name;
    lastTargetAmount = targetAmount;
    lastTargetDate = targetDate;
    lastFrequency = contributionFrequency;

    // Simulate delay if requested
    if (delayCompleter != null) {
      await delayCompleter!.future;
    }

    return Fund(
      id: id,
      name: name ?? 'Mock',
      targetAmount: targetAmount ?? Money.zero(Currency('USD')),
      startDate: CalendarDate(2026, 1, 1),
      targetDate: targetDate ?? CalendarDate(2026, 12, 31),
      contributionFrequency:
          contributionFrequency ?? ContributionFrequency.monthly,
    );
  }
}

void main() {
  late MockUpdateFundUseCase mockUseCase;
  late Fund mockFund;
  late FundDetailState mockState;

  setUp(() {
    mockUseCase = MockUpdateFundUseCase();
    mockFund = Fund(
      id: 'test-fund',
      name: 'Initial Name',
      targetAmount: Money(minorUnits: 100000, currency: Currency('USD')),
      startDate: CalendarDate(2026, 1, 1),
      targetDate: CalendarDate(2026, 12, 31),
      contributionFrequency: ContributionFrequency.monthly,
    );

    mockState = FundDetailState(
      fundState: FundState(
        fund: mockFund,
        transactions: [],
        calculationResult: FundCalculationResult(
          currentBalance: Money(minorUnits: 0, currency: Currency('USD')),
          progress: 0.0,
          requiredContribution: Money(
            minorUnits: 10000,
            currency: Currency('USD'),
          ),
          status: FundStatus.onTrack,
          remainingAmount: Money(minorUnits: 100000, currency: Currency('USD')),
          remainingPeriods: 10,
          totalPeriods: 10,
          elapsedPeriods: 0,
          expectedBalance: Money(minorUnits: 0, currency: Currency('USD')),
        ),
      ),
      trajectory: Trajectory(historicalPoints: [], futurePoints: []),
    );
  });

  Widget createSubject() {
    final router = GoRouter(
      initialLocation: '/fund/test-fund/edit',
      routes: [
        GoRoute(
          path: '/fund/:id/edit',
          builder: (context, state) =>
              EditFundScreen(fundId: state.pathParameters['id']!),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        updateFundUseCaseProvider.overrideWithValue(mockUseCase),
        fundDetailProvider(
          'test-fund',
        ).overrideWith(() => _MockFundDetailNotifier(mockState)),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('EditFundScreen', () {
    testWidgets('displays current fund values', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Initial Name'), findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
      expect(find.text('USD '), findsOneWidget); // Prefix
      expect(find.text('2026-12-31'), findsOneWidget);
    });

    testWidgets('allows editing name, amount, date, frequency and saves', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('name_input')),
        'Updated Name',
      );
      await tester.enterText(find.byKey(const Key('amount_input')), '2000');

      // Select Date
      await tester.tap(find.byKey(const Key('date_picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Change frequency
      await tester.tap(find.byKey(const Key('frequency_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('WEEKLY').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle(); // Finish loading

      expect(mockUseCase.callCount, 1);
      expect(mockUseCase.lastName, 'Updated Name');
      expect(mockUseCase.lastTargetAmount?.minorUnits, 200000);
      expect(mockUseCase.lastFrequency, ContributionFrequency.weekly);
    });

    testWidgets('allows zero target amount', (tester) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('amount_input')), '0');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle(); // Finish loading

      expect(mockUseCase.callCount, 1);
      expect(mockUseCase.lastTargetAmount?.minorUnits, 0);
    });

    testWidgets('rejects negative target amount without calling use case', (
      tester,
    ) async {
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('amount_input')), '-500');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pump(); // Try submit

      // Verify use case was not called because MoneyParser throws
      expect(mockUseCase.callCount, 0);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('save failure shows error and keeps screen open', (
      tester,
    ) async {
      mockUseCase.throwError = true;
      mockUseCase.errorToThrow = InvalidFundDataError(
        'Target date must be after start date',
      );

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle(); // finish

      expect(mockUseCase.callCount, 1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Target date must be after start date'), findsWidgets);

      // Screen should still be open (app bar title Edit Fund is still there)
      expect(find.text('Edit Fund'), findsOneWidget);
    });

    testWidgets('duplicate submit prevention via loading state', (
      tester,
    ) async {
      mockUseCase.delayCompleter = Completer<void>();
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Tap first time
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pump(); // Begin loading

      // The button should be replaced by CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('save_button')), findsNothing);

      mockUseCase.delayCompleter!.complete();
      await tester.pumpAndSettle(); // Finish load
      expect(mockUseCase.callCount, 1);
    });

    testWidgets('accessibility and 48x48 tap targets', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Button tap target
      final buttonFinder = find.byType(PrimaryActionButton);
      expect(buttonFinder, findsOneWidget);
      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));

      // Semantic checks
      final datePickerFinder = find.byKey(const Key('date_picker'));
      expect(datePickerFinder, findsOneWidget);
      handle.dispose();
    });
  });
}

// A mock notifier just for testing the UI
class _MockFundDetailNotifier extends AsyncNotifier<FundDetailState>
    implements FundDetailNotifier {
  final FundDetailState initialState;
  _MockFundDetailNotifier(this.initialState);

  @override
  Future<FundDetailState> build() async => initialState;

  @override
  String get fundId => initialState.fundState.fund.id;

  @override
  Future<void> addContribution({
    required Money amount,
    required CalendarDate date,
    String? note,
  }) async {}

  @override
  Future<void> addWithdrawal({
    required Money amount,
    required CalendarDate date,
    String? note,
  }) async {}

  @override
  Future<void> updateFund({
    String? name,
    Money? targetAmount,
    CalendarDate? targetDate,
    ContributionFrequency? contributionFrequency,
  }) async {
    final useCase = ref.read(updateFundUseCaseProvider);
    await useCase.execute(
      id: fundId,
      name: name,
      targetAmount: targetAmount,
      targetDate: targetDate,
      contributionFrequency: contributionFrequency,
    );
  }
}
