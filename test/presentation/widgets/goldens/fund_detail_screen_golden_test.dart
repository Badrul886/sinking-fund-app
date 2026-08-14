import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:sinking_fund/presentation/providers/dependencies.dart';
import 'package:sinking_fund/application/ports/clock.dart';

class FakeClock implements Clock {
  @override
  CalendarDate today() => CalendarDate(2026, 8, 14);
}

class FakeFundDetailNotifier extends FundDetailNotifier {
  final FundDetailState fakeState;

  FakeFundDetailNotifier(super.fundId, this.fakeState);

  @override
  Future<FundDetailState> build() async => fakeState;
}

void main() {
  group('FundDetailScreen Goldens', () {
    late FakeClock fakeClock;

    setUp(() {
      fakeClock = FakeClock();
    });

    FundDetailState createTestState({
      required FundStatus status,
      required double progress,
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
        name: 'Test Fund',
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

      final tx1 = Contribution(
        id: 'tx1',
        amount: Money(minorUnits: 10000, currency: currency),
        date: CalendarDate(2026, 2, 1),
        note: 'Initial',
      );
      final tx2 = Contribution(
        id: 'tx2',
        amount: Money(minorUnits: 40000, currency: currency),
        date: CalendarDate(2026, 6, 1),
        note: 'Bonus',
      );

      final trajectory = Trajectory(
        historicalPoints: [
          HistoricalPoint(
            date: CalendarDate(2026, 2, 1),
            balance: Money(minorUnits: 10000, currency: currency),
          ),
          HistoricalPoint(date: CalendarDate(2026, 6, 1), balance: current),
        ],
        futurePoints:
            status == FundStatus.complete || status == FundStatus.overfunded
            ? []
            : [
                FuturePoint(
                  date: CalendarDate(2026, 12, 31),
                  projectedBalance: target,
                  requiredContribution: calcResult.requiredContribution,
                ),
              ],
      );

      return FundDetailState(
        fundState: FundState(
          fund: fund,
          transactions: [tx2, tx1], // newest first for display
          calculationResult: calcResult,
        ),
        trajectory: trajectory,
      );
    }

    Widget createTestWidget(FundDetailState state) {
      return ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(fakeClock),
          fundDetailProvider(
            'f1',
          ).overrideWith(() => FakeFundDetailNotifier('f1', state)),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: FundDetailScreen(fundId: 'f1'),
        ),
      );
    }

    testWidgets('matches golden (onTrack)', (tester) async {
      final state = createTestState(status: FundStatus.onTrack, progress: 0.5);
      await tester.pumpWidget(createTestWidget(state));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(FundDetailScreen),
        matchesGoldenFile('fund_detail_screen_on_track.png'),
      );
    });

    testWidgets('matches golden (behind)', (tester) async {
      final state = createTestState(status: FundStatus.behind, progress: 0.2);
      await tester.pumpWidget(createTestWidget(state));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(FundDetailScreen),
        matchesGoldenFile('fund_detail_screen_behind.png'),
      );
    });

    testWidgets('matches golden (complete)', (tester) async {
      final state = createTestState(status: FundStatus.complete, progress: 1.0);
      await tester.pumpWidget(createTestWidget(state));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(FundDetailScreen),
        matchesGoldenFile('fund_detail_screen_complete.png'),
      );
    });

    testWidgets('matches golden (overfunded)', (tester) async {
      final state = createTestState(
        status: FundStatus.overfunded,
        progress: 1.5,
        overfunded: true,
      );
      await tester.pumpWidget(createTestWidget(state));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(FundDetailScreen),
        matchesGoldenFile('fund_detail_screen_overfunded.png'),
      );
    });
  });
}
