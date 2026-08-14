import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/presentation/theme/app_theme.dart';
import 'package:sinking_fund/presentation/widgets/buttons/primary_action_button.dart';
import 'package:sinking_fund/presentation/widgets/buttons/secondary_action_button.dart';
import 'package:sinking_fund/presentation/widgets/data_display/amount_display.dart';
import 'package:sinking_fund/presentation/widgets/data_display/progress_visualizer.dart';
import 'package:sinking_fund/presentation/widgets/surfaces/app_card.dart';

// Deterministic wrapper for golden tests
class GoldenTestWrapper extends StatelessWidget {
  final Widget child;
  const GoldenTestWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}

void main() {
  group('Presentation Primitives Goldens', () {
    testWidgets('PrimaryActionButton matches golden', (tester) async {
      await tester.pumpWidget(
        GoldenTestWrapper(
          child: PrimaryActionButton(
            label: 'Save Fund',
            onPressed: () {},
          ),
        ),
      );
      
      await expectLater(
        find.byType(GoldenTestWrapper),
        matchesGoldenFile('primary_action_button.png'),
      );
    });

    testWidgets('SecondaryActionButton matches golden', (tester) async {
      await tester.pumpWidget(
        GoldenTestWrapper(
          child: SecondaryActionButton(
            label: 'Cancel',
            onPressed: () {},
          ),
        ),
      );
      
      await expectLater(
        find.byType(GoldenTestWrapper),
        matchesGoldenFile('secondary_action_button.png'),
      );
    });

    testWidgets('AppCard matches golden', (tester) async {
      await tester.pumpWidget(
        const GoldenTestWrapper(
          child: SizedBox(
            width: 300,
            height: 150,
            child: AppCard(
              child: Center(child: Text('Card Content')),
            ),
          ),
        ),
      );
      
      await expectLater(
        find.byType(GoldenTestWrapper),
        matchesGoldenFile('app_card.png'),
      );
    });

    testWidgets('AmountDisplay matches golden (USD)', (tester) async {
      final usd = const Currency('USD');
      final amount = Money(minorUnits: 1234567, currency: usd);

      await tester.pumpWidget(
        GoldenTestWrapper(
          child: AmountDisplay(
            amount: amount, 
            locale: 'en_US',
          ),
        ),
      );
      
      await expectLater(
        find.byType(GoldenTestWrapper),
        matchesGoldenFile('amount_display_usd.png'),
      );
    });

    testWidgets('ProgressVisualizer matches golden (Normal)', (tester) async {
      await tester.pumpWidget(
        const GoldenTestWrapper(
          child: SizedBox(
            width: 300,
            child: ProgressVisualizer(progress: 0.65), // 65%
          ),
        ),
      );
      
      // Allow animation to finish
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(GoldenTestWrapper),
        matchesGoldenFile('progress_visualizer_normal.png'),
      );
    });

    testWidgets('ProgressVisualizer matches golden (Overfunded)', (tester) async {
      await tester.pumpWidget(
        const GoldenTestWrapper(
          child: SizedBox(
            width: 300,
            child: ProgressVisualizer(progress: 1.25), // 125%
          ),
        ),
      );
      
      // Allow animation to finish
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(GoldenTestWrapper),
        matchesGoldenFile('progress_visualizer_overfunded.png'),
      );
    });
  });
}
