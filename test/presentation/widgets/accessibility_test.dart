import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/presentation/widgets/buttons/primary_action_button.dart';
import 'package:sinking_fund/presentation/widgets/data_display/amount_display.dart';
import 'package:sinking_fund/presentation/widgets/data_display/progress_visualizer.dart';

void main() {
  group('Accessibility & Semantics', () {
    testWidgets('PrimaryActionButton meets minimum touch target', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryActionButton(label: 'Test', onPressed: () {}),
          ),
        ),
      );

      final buttonSize = tester.getSize(find.byType(FilledButton));
      expect(buttonSize.width, greaterThanOrEqualTo(48.0));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('AmountDisplay exposes formatted semantics', (tester) async {
      final usd = const Currency('USD');
      final amount = Money(minorUnits: 123456, currency: usd); // $1,234.56

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmountDisplay(amount: amount, locale: 'en_US'),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AmountDisplay));
      expect(semantics.label, '\$1,234.56');
    });

    testWidgets('ProgressVisualizer exposes semantics and handles overfunded', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ProgressVisualizer(progress: 1.25))),
      );

      final semantics = tester.getSemantics(find.byType(ProgressVisualizer));
      expect(semantics.label, '125% complete. Overfunded.');
      expect(semantics.value, '100%'); // Visual clamp
    });

    testWidgets('AmountDisplay scales text without clipping layout bounds', (
      tester,
    ) async {
      final usd = const Currency('USD');
      final amount = Money(minorUnits: 123456, currency: usd); // $1,234.56

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(3.0),
            ), // Extreme scale
            child: Scaffold(
              body: Center(
                child: AmountDisplay(amount: amount, locale: 'en_US'),
              ),
            ),
          ),
        ),
      );

      // Verify it pumped successfully without render overflow errors causing a crash
      expect(find.byType(AmountDisplay), findsOneWidget);
    });
  });
}
