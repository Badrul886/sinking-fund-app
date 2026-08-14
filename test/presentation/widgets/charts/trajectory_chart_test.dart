import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/trajectory.dart';
import 'package:sinking_fund/presentation/widgets/charts/trajectory_chart.dart';

void main() {
  Widget createTestWidget({required Trajectory trajectory}) {
    return MaterialApp(
      home: Scaffold(
        body: TrajectoryChart(
          startDate: CalendarDate(2026, 1, 1),
          targetDate: CalendarDate(2026, 12, 31),
          currentDate: CalendarDate(2026, 6, 15),
          targetAmount: Money(
            minorUnits: 100000,
            currency: const Currency('USD'),
          ),
          trajectory: trajectory,
          semanticsLabel: 'Test Chart',
        ),
      ),
    );
  }

  testWidgets('renders empty trajectory', (tester) async {
    final trajectory = Trajectory(historicalPoints: [], futurePoints: []);

    await tester.pumpWidget(createTestWidget(trajectory: trajectory));

    // Check semantics
    expect(find.bySemanticsLabel('Test Chart'), findsOneWidget);

    // Verify it doesn't crash
    expect(
      find.descendant(
        of: find.byType(TrajectoryChart),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('renders full trajectory', (tester) async {
    final trajectory = Trajectory(
      historicalPoints: [
        HistoricalPoint(
          date: CalendarDate(2026, 2, 1),
          balance: Money(minorUnits: 10000, currency: const Currency('USD')),
        ),
      ],
      futurePoints: [
        FuturePoint(
          date: CalendarDate(2026, 7, 1),
          projectedBalance: Money(
            minorUnits: 50000,
            currency: const Currency('USD'),
          ),
          requiredContribution: Money(
            minorUnits: 10000,
            currency: const Currency('USD'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(createTestWidget(trajectory: trajectory));
    expect(find.bySemanticsLabel('Test Chart'), findsOneWidget);
  });
}
