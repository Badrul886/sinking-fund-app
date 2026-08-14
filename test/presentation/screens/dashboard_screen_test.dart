
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sinking_fund/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:sinking_fund/presentation/state/funds_list_notifier.dart';
import 'package:sinking_fund/presentation/state/dashboard_notifier.dart';
import 'package:sinking_fund/application/models/fund_state.dart';
import 'package:sinking_fund/domain/fund_calculator.dart';
import 'package:sinking_fund/application/models/recent_activity_item.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/transaction.dart';
import 'package:sinking_fund/presentation/widgets/surfaces/sinking_fund_card.dart';
import 'package:sinking_fund/presentation/widgets/data_display/recent_activity_list.dart';
import 'package:sinking_fund/presentation/providers/dependencies.dart';
import 'package:sinking_fund/application/ports/clock.dart';

class FakeClock implements Clock {
  @override
  CalendarDate today() => CalendarDate(2026, 8, 14);
}

class FakeFundsListNotifier extends FundsListNotifier {
  final bool isLoading;
  final Object? error;
  final List<FundState>? funds;
  final Function()? onBuild;

  FakeFundsListNotifier({
    this.isLoading = false,
    this.error,
    this.funds,
    this.onBuild,
  });

  @override
  Future<List<FundState>> build() async {
    onBuild?.call();
    if (isLoading) {
      await Future.delayed(const Duration(seconds: 1));
      return [];
    }
    if (error != null) {
      throw error!;
    }
    return funds ?? [];
  }
}

void main() {
  group('DashboardScreen Tests', () {
    late FakeClock fakeClock;

    setUp(() {
      fakeClock = FakeClock();
    });

    FundState createTestFund({
      required String id,
      required String name,
      required String currencyCode,
      required int currentMinorUnits,
      required int targetMinorUnits,
    }) {
      final currency = Currency(currencyCode);
      return FundState(
        fund: Fund(
          id: id,
          name: name,
          targetAmount: Money(minorUnits: targetMinorUnits, currency: currency),
          startDate: CalendarDate(2026, 1, 1),
          targetDate: CalendarDate(2026, 12, 31),
          contributionFrequency: ContributionFrequency.monthly,
        ),
        transactions: const [],
        calculationResult: FundCalculationResult(
          currentBalance: Money(minorUnits: currentMinorUnits, currency: currency),
          remainingAmount: Money(minorUnits: targetMinorUnits - currentMinorUnits, currency: currency),
          totalPeriods: 12,
          elapsedPeriods: 6,
          remainingPeriods: 6,
          requiredContribution: Money(minorUnits: 1000, currency: currency),
          expectedBalance: Money(minorUnits: targetMinorUnits ~/ 2, currency: currency),
          progress: currentMinorUnits / targetMinorUnits,
          status: FundStatus.onTrack,
        ),
      );
    }

    Widget createTestWidget({
      List<FundState>? funds,
      List<RecentActivityItem>? recentActivity,
      bool isLoading = false,
      Object? error,
      String? initialLocation,
      GoRouter? router,
    }) {
      final effectiveRouter =
          router ??
          GoRouter(
            initialLocation: initialLocation ?? '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
              GoRoute(
                path: '/fund/create',
                builder: (context, state) =>
                    const Scaffold(body: Text('Create Fund Screen')),
              ),
              GoRoute(
                path: '/fund/:id',
                builder: (context, state) => Scaffold(
                  body: Text('Fund Detail ${state.pathParameters['id']}'),
                ),
              ),
            ],
          );

      return ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(fakeClock),
          if (isLoading)
            fundsListProvider.overrideWith(() => FakeFundsListNotifier(isLoading: true)),
          if (error != null)
            fundsListProvider.overrideWith(() => FakeFundsListNotifier(error: error)),
          if (!isLoading && error == null) ...[
            fundsListProvider.overrideWith(() => FakeFundsListNotifier(funds: funds ?? [])),
            recentActivityProvider.overrideWith(
              (ref) => Future.value(recentActivity ?? []),
            ),
          ],
        ],
        child: MaterialApp.router(routerConfig: effectiveRouter),
      );
    }

    testWidgets('loading state', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1)); // complete timer
    });

    testWidgets('error state and retry action', (tester) async {
      int retryCount = 0;
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clockProvider.overrideWithValue(fakeClock),
            fundsListProvider.overrideWith(() {
              return FakeFundsListNotifier(
                error: 'Test error',
                onBuild: () => retryCount++,
              );
            }),
            recentActivityProvider.overrideWith((ref) => Future.value([])),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load dashboard'), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retryCount, greaterThan(1));
    });

    testWidgets('empty dashboard navigates to create fund', (tester) async {
      await tester.pumpWidget(createTestWidget(funds: [], recentActivity: []));
      await tester.pumpAndSettle();

      expect(find.text('No funds yet'), findsOneWidget);
      expect(
        find.text('Start by creating your first sinking fund.'),
        findsOneWidget,
      );
      expect(
        find.byIcon(Icons.account_balance_wallet_outlined),
        findsOneWidget,
      );
      expect(find.text('Priority Fund'), findsNothing);

      await tester.tap(find.text('Create Fund'));
      await tester.pumpAndSettle();

      expect(find.text('Create Fund Screen'), findsOneWidget);
    });

    testWidgets('one fund', (tester) async {
      final fund = createTestFund(
        id: 'f1',
        name: 'Vacation',
        currencyCode: 'USD',
        currentMinorUnits: 50000,
        targetMinorUnits: 100000,
      );
      await tester.pumpWidget(
        createTestWidget(funds: [fund], recentActivity: []),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Savings'), findsOneWidget);
      expect(find.text('\$500.00'), findsNWidgets(2));
      expect(find.byType(SinkingFundCard), findsOneWidget);
      expect(find.text('Vacation'), findsOneWidget);
    });

    testWidgets('multiple funds same currency grouped together', (
      tester,
    ) async {
      final f1 = createTestFund(
        id: 'f1',
        name: 'Vacation',
        currencyCode: 'USD',
        currentMinorUnits: 50000,
        targetMinorUnits: 100000,
      );
      final f2 = createTestFund(
        id: 'f2',
        name: 'Car',
        currencyCode: 'USD',
        currentMinorUnits: 25000,
        targetMinorUnits: 100000,
      );

      await tester.pumpWidget(
        createTestWidget(funds: [f1, f2], recentActivity: []),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SinkingFundCard), findsNWidgets(2));
      expect(find.text('\$750.00'), findsOneWidget);
    });

    testWidgets('multiple currencies grouped separately', (tester) async {
      final f1 = createTestFund(
        id: 'f1',
        name: 'Vacation',
        currencyCode: 'USD',
        currentMinorUnits: 50000,
        targetMinorUnits: 100000,
      );
      final f2 = createTestFund(
        id: 'f2',
        name: 'Car',
        currencyCode: 'EUR',
        currentMinorUnits: 25000,
        targetMinorUnits: 100000,
      );

      await tester.pumpWidget(
        createTestWidget(funds: [f1, f2], recentActivity: []),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SinkingFundCard), findsNWidgets(2));
      expect(find.text('\$500.00'), findsNWidgets(2));
      expect(find.text('€250.00'), findsNWidgets(2));
    });

    testWidgets('navigation to fund detail', (tester) async {
      final f1 = createTestFund(
        id: 'f1',
        name: 'Vacation',
        currencyCode: 'USD',
        currentMinorUnits: 50000,
        targetMinorUnits: 100000,
      );

      await tester.pumpWidget(
        createTestWidget(funds: [f1], recentActivity: []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SinkingFundCard));
      await tester.pumpAndSettle();

      expect(find.text('Fund Detail f1'), findsOneWidget);
    });

    testWidgets('recent activity rendering', (tester) async {
      final f1 = createTestFund(
        id: 'f1',
        name: 'Vacation',
        currencyCode: 'USD',
        currentMinorUnits: 50000,
        targetMinorUnits: 100000,
      );
      final tx = Contribution(
        id: 'tx1',
        amount: Money(minorUnits: 5000, currency: const Currency('USD')),
        date: CalendarDate(2026, 8, 14),
        note: 'Bonus',
      );
      final recent = RecentActivityItem(
        transaction: tx,
        fundName: 'Vacation',
        fundCurrency: const Currency('USD'),
      );

      await tester.pumpWidget(
        createTestWidget(funds: [f1], recentActivity: [recent]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RecentActivityList), findsOneWidget);
      expect(find.text('Recent Activity'), findsOneWidget);
      expect(
        find.text('Vacation'),
        findsNWidgets(2),
      ); // One in card, one in activity
      expect(find.text('+\$50.00'), findsOneWidget);
      expect(find.textContaining('Bonus'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('navigation to create fund from list header', (tester) async {
      final f1 = createTestFund(
        id: 'f1',
        name: 'Vacation',
        currencyCode: 'USD',
        currentMinorUnits: 50000,
        targetMinorUnits: 100000,
      );

      await tester.pumpWidget(
        createTestWidget(funds: [f1], recentActivity: []),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Create Fund'));
      await tester.pumpAndSettle();

      expect(find.text('Create Fund Screen'), findsOneWidget);
    });

    testWidgets('FundCard semantics', (tester) async {
      final handle = tester.ensureSemantics();
      final f1 = createTestFund(id: 'f1', name: 'Vacation', currencyCode: 'USD', currentMinorUnits: 50000, targetMinorUnits: 100000);
      
      await tester.pumpWidget(createTestWidget(funds: [f1], recentActivity: []));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp(r'\$500\.00')), findsNWidgets(2));
      expect(find.bySemanticsLabel(RegExp(r'50% complete')), findsOneWidget);
      handle.dispose();
    });
  });
}
