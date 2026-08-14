import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sinking_fund/presentation/screens/fund/fund_detail_screen.dart';
import 'package:sinking_fund/presentation/state/fund_detail_notifier.dart';
import 'package:sinking_fund/application/models/fund_detail_state.dart';
import 'package:sinking_fund/application/models/fund_state.dart';
import 'package:sinking_fund/domain/fund_calculator.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/transaction.dart';
import 'package:sinking_fund/domain/trajectory.dart';
import 'package:sinking_fund/application/errors/application_error.dart';
import 'package:sinking_fund/presentation/providers/dependencies.dart';
import 'package:sinking_fund/application/ports/clock.dart';

class FakeClock implements Clock {
  @override
  CalendarDate today() => CalendarDate(2026, 8, 14);
}

class FakeFundDetailNotifier extends FundDetailNotifier {
  final bool isLoading;
  final Object? error;
  final FundDetailState? fakeState;

  FakeFundDetailNotifier(
    super.fundId, {
    this.isLoading = false,
    this.error,
    this.fakeState,
  });

  @override
  Future<FundDetailState> build() async {
    if (isLoading) {
      await Future.delayed(const Duration(seconds: 1));
      throw Exception('Should not reach');
    }
    if (error != null) {
      throw error!;
    }
    return fakeState!;
  }
}

void main() {
  group('FundDetailScreen Tests', () {
    late FakeClock fakeClock;

    setUp(() {
      fakeClock = FakeClock();
    });

    FundDetailState createTestState({
      required FundStatus status,
      required double progress,
      required List<Transaction> transactions,
      bool overfunded = false,
    }) {
      final currency = const Currency('USD');
      final target = Money(minorUnits: 100000, currency: currency);
      final current = Money(
        minorUnits: overfunded ? 150000 : (progress * 100000).toInt(),
        currency: currency,
      );

      final fund = Fund(
        id: 'f1',
        name: 'Vacation',
        targetAmount: target,
        startDate: CalendarDate(2026, 1, 1),
        targetDate: CalendarDate(2026, 12, 31),
        contributionFrequency: ContributionFrequency.monthly,
      );

      final calcResult = FundCalculationResult(
        currentBalance: current,
        remainingAmount: Money(
          minorUnits: overfunded ? 0 : target.minorUnits - current.minorUnits,
          currency: currency,
        ),
        totalPeriods: 12,
        elapsedPeriods: 6,
        remainingPeriods: 6,
        requiredContribution: Money(minorUnits: 1000, currency: currency),
        expectedBalance: Money(
          minorUnits: target.minorUnits ~/ 2,
          currency: currency,
        ),
        progress: progress,
        status: status,
      );

      final trajectory = Trajectory(
        historicalPoints: transactions.isEmpty
            ? []
            : [
                HistoricalPoint(
                  date: CalendarDate(2026, 6, 1),
                  balance: current,
                ),
              ],
        futurePoints:
            status == FundStatus.complete || status == FundStatus.overfunded
            ? []
            : [
                FuturePoint(
                  date: CalendarDate(2026, 12, 1),
                  projectedBalance: target,
                  requiredContribution: calcResult.requiredContribution,
                ),
              ],
      );

      return FundDetailState(
        fundState: FundState(
          fund: fund,
          transactions: transactions,
          calculationResult: calcResult,
        ),
        trajectory: trajectory,
      );
    }

    Widget createTestWidget({
      FundDetailState? state,
      bool isLoading = false,
      Object? error,
    }) {
      final router = GoRouter(
        initialLocation: '/fund/f1',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Text('Dashboard')),
          ),
          GoRoute(
            path: '/fund/:id',
            builder: (context, state) =>
                FundDetailScreen(fundId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/fund/:id/edit',
            builder: (context, state) =>
                const Scaffold(body: Text('Edit Fund')),
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(fakeClock),
          if (isLoading)
            fundDetailProvider(
              'f1',
            ).overrideWith(() => FakeFundDetailNotifier('f1', isLoading: true)),
          if (error != null)
            fundDetailProvider(
              'f1',
            ).overrideWith(() => FakeFundDetailNotifier('f1', error: error)),
          if (!isLoading && error == null && state != null)
            fundDetailProvider('f1').overrideWith(
              () => FakeFundDetailNotifier('f1', fakeState: state),
            ),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('loading state', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1)); // complete timer
    });

    testWidgets('generic error state', (tester) async {
      await tester.pumpWidget(createTestWidget(error: 'Test error'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Test error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('FundNotFoundError state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(error: const FundNotFoundError()),
      );
      await tester.pumpAndSettle();
      expect(find.text('This fund no longer exists.'), findsOneWidget);
      expect(find.text('Return to Dashboard'), findsOneWidget);

      await tester.tap(find.text('Return to Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('normal / onTrack state', (tester) async {
      final state = createTestState(
        status: FundStatus.onTrack,
        progress: 0.5,
        transactions: [],
      );
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text('Vacation'), findsOneWidget);
      expect(find.text('Target: \$1,000.00'), findsOneWidget);
      expect(find.text('\$500.00'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text("You're on track."), findsOneWidget);
      expect(find.text('Required: \$10.00 / monthly'), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('No transactions yet.'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget); // Add Contribution
      expect(find.byType(OutlinedButton), findsOneWidget); // Withdraw
    });

    testWidgets('ahead state', (tester) async {
      final state = createTestState(
        status: FundStatus.ahead,
        progress: 0.6,
        transactions: [],
      );
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text("You're ahead of schedule."), findsOneWidget);
    });

    testWidgets('behind state', (tester) async {
      final state = createTestState(
        status: FundStatus.behind,
        progress: 0.3,
        transactions: [],
      );
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text("You're behind schedule."), findsOneWidget);
    });

    testWidgets('complete state', (tester) async {
      final state = createTestState(
        status: FundStatus.complete,
        progress: 1.0,
        transactions: [],
      );
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text("Fund complete!"), findsOneWidget);
    });

    testWidgets('overfunded state', (tester) async {
      final state = createTestState(
        status: FundStatus.overfunded,
        progress: 1.5,
        transactions: [],
        overfunded: true,
      );
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text("Fund overfunded!"), findsOneWidget);
      expect(find.text('Surplus: \$500.00'), findsOneWidget);
      expect(
        find.text('150% · Overfunded'),
        findsOneWidget,
      ); // Percentage remains 150%
    });

    testWidgets('deadlinePassed state', (tester) async {
      final state = createTestState(
        status: FundStatus.deadlinePassed,
        progress: 0.5,
        transactions: [],
      );
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text("Target date has passed."), findsOneWidget);
    });

    testWidgets('notStarted state empty trajectory', (tester) async {
      final state = createTestState(
        status: FundStatus.notStarted,
        progress: 0.0,
        transactions: [],
      );
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(
        find.text("Ready to start saving."),
        findsNWidgets(2),
      ); // One in status, one in trajectory placeholder
    });

    testWidgets('mixed transaction history with notes', (tester) async {
      final tx1 = Contribution(
        id: 'tx1',
        amount: Money(minorUnits: 1000, currency: const Currency('USD')),
        date: CalendarDate(2026, 6, 1),
        note: 'Bonus',
      );
      final tx2 = Withdrawal(
        id: 'tx2',
        amount: Money(minorUnits: 500, currency: const Currency('USD')),
        date: CalendarDate(2026, 6, 2), // note is null
      );
      final state = createTestState(
        status: FundStatus.onTrack,
        progress: 0.5,
        transactions: [tx1, tx2],
      );
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Bonus'), findsOneWidget);
      expect(find.text('Withdrawal'), findsOneWidget); // Fallback note
      expect(find.text('+\$10.00'), findsOneWidget);
      expect(find.text('-\$5.00'), findsOneWidget);
    });

    testWidgets('edit fund navigation', (tester) async {
      final state = createTestState(
        status: FundStatus.onTrack,
        progress: 0.5,
        transactions: [],
      );
      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Edit Fund'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Fund'), findsOneWidget);
    });
  });
}
