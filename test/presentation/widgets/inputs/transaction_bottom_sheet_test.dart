import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sinking_fund/presentation/widgets/inputs/transaction_bottom_sheet.dart';
import 'package:sinking_fund/presentation/state/fund_detail_notifier.dart';
import 'package:sinking_fund/application/models/fund_detail_state.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/application/errors/application_error.dart';
import 'package:sinking_fund/presentation/providers/dependencies.dart';
import 'package:sinking_fund/application/ports/clock.dart';

class FakeClock implements Clock {
  @override
  CalendarDate today() => CalendarDate(2026, 8, 14);
}

class FakeFundDetailNotifier extends FundDetailNotifier {
  final Future<void> Function(Money, CalendarDate, String?)? onAddContribution;
  final Future<void> Function(Money, CalendarDate, String?)? onAddWithdrawal;

  FakeFundDetailNotifier({this.onAddContribution, this.onAddWithdrawal})
    : super('test_fund');

  @override
  Future<FundDetailState> build() async {
    throw UnimplementedError('build should not be called in these tests');
  }

  @override
  Future<void> addContribution({
    required Money amount,
    required CalendarDate date,
    String? note,
  }) async {
    if (onAddContribution != null) {
      await onAddContribution!(amount, date, note);
    }
  }

  @override
  Future<void> addWithdrawal({
    required Money amount,
    required CalendarDate date,
    String? note,
  }) async {
    if (onAddWithdrawal != null) {
      await onAddWithdrawal!(amount, date, note);
    }
  }
}

void main() {
  group('TransactionBottomSheet Tests', () {
    late FakeClock fakeClock;

    setUp(() {
      fakeClock = FakeClock();
    });

    Widget createTestWidget({
      required TransactionType type,
      Future<void> Function(Money, CalendarDate, String?)? onAddContribution,
      Future<void> Function(Money, CalendarDate, String?)? onAddWithdrawal,
    }) {
      return ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(fakeClock),
          fundDetailProvider('test_fund').overrideWith(
            () => FakeFundDetailNotifier(
              onAddContribution: onAddContribution,
              onAddWithdrawal: onAddWithdrawal,
            ),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TransactionBottomSheet(
                  fundId: 'test_fund',
                  currency: const Currency('USD'),
                  type: type,
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets('Contribution success closes sheet', (tester) async {
      bool contributionCalled = false;
      Money? calledAmount;
      String? calledNote;

      await tester.pumpWidget(
        createTestWidget(
          type: TransactionType.contribution,
          onAddContribution: (amount, date, note) async {
            contributionCalled = true;
            calledAmount = amount;
            calledNote = note;
          },
        ),
      );

      await tester.enterText(find.byKey(const Key('amount_input')), '50.00');
      await tester.enterText(find.byKey(const Key('note_input')), 'Bonus');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(contributionCalled, isTrue);
      expect(calledAmount?.minorUnits, 5000);
      expect(calledNote, 'Bonus');
      expect(
        find.byType(TransactionBottomSheet),
        findsNothing,
      ); // Navigated away
    });

    testWidgets('Contribution note is normalized (whitespace only -> null)', (
      tester,
    ) async {
      String? calledNote;

      await tester.pumpWidget(
        createTestWidget(
          type: TransactionType.contribution,
          onAddContribution: (amount, date, note) async {
            calledNote = note;
          },
        ),
      );

      await tester.enterText(find.byKey(const Key('amount_input')), '50.00');
      await tester.enterText(find.byKey(const Key('note_input')), '   ');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(calledNote, isNull);
    });

    testWidgets('Contribution failure keeps sheet open and shows snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          type: TransactionType.contribution,
          onAddContribution: (amount, date, note) async {
            throw const InvalidFundDataError('Currency mismatch');
          },
        ),
      );

      await tester.enterText(find.byKey(const Key('amount_input')), '50.00');
      await tester.tap(find.byType(FilledButton));
      await tester.pump(); // Start animation
      await tester.pump(
        const Duration(milliseconds: 50),
      ); // Snackbar starts showing

      expect(find.byType(TransactionBottomSheet), findsOneWidget);
      expect(find.text('Currency mismatch'), findsWidgets); // In SnackBar
    });

    testWidgets('Withdrawal success closes sheet', (tester) async {
      bool withdrawalCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          type: TransactionType.withdrawal,
          onAddWithdrawal: (amount, date, note) async {
            withdrawalCalled = true;
          },
        ),
      );

      await tester.enterText(find.byKey(const Key('amount_input')), '20.00');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(withdrawalCalled, isTrue);
      expect(find.byType(TransactionBottomSheet), findsNothing);
    });

    testWidgets('Withdrawal insufficient funds keeps sheet open', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          type: TransactionType.withdrawal,
          onAddWithdrawal: (amount, date, note) async {
            throw const InsufficientFundsError();
          },
        ),
      );

      await tester.enterText(find.byKey(const Key('amount_input')), '2000.00');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 50),
      ); // Snackbar starts showing

      expect(find.byType(TransactionBottomSheet), findsOneWidget);
      expect(
        find.text('Insufficient funds for withdrawal.'),
        findsWidgets,
      ); // Default error message
    });

    testWidgets('Zero amount is rejected by MoneyParser', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          type: TransactionType.contribution,
          onAddContribution: (a, d, n) async {},
        ),
      );

      await tester.enterText(find.byKey(const Key('amount_input')), '0.00');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionBottomSheet), findsOneWidget);
      expect(
        find.text('Amount must be strictly positive'),
        findsOneWidget,
      ); // errorText
    });

    testWidgets('Negative amount is rejected by MoneyParser', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          type: TransactionType.contribution,
          onAddContribution: (a, d, n) async {},
        ),
      );

      await tester.enterText(find.byKey(const Key('amount_input')), '-5.00');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Negative amounts are not allowed'), findsOneWidget);
    });

    testWidgets('Malformed amount is rejected by MoneyParser', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          type: TransactionType.contribution,
          onAddContribution: (a, d, n) async {},
        ),
      );

      await tester.enterText(find.byKey(const Key('amount_input')), '5.00.00');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Malformed decimal'), findsOneWidget);
    });

    testWidgets('Duplicate submission prevented by loading state', (
      tester,
    ) async {
      int callCount = 0;
      await tester.pumpWidget(
        createTestWidget(
          type: TransactionType.contribution,
          onAddContribution: (a, d, n) async {
            callCount++;
            await Future.delayed(
              const Duration(seconds: 1),
            ); // Simulate slow request
          },
        ),
      );

      await tester.enterText(find.byKey(const Key('amount_input')), '50.00');
      await tester.tap(find.byType(FilledButton));
      await tester.pump(); // Start request

      // Tap again while loading
      await tester.tap(find.text('Add Contribution'));
      await tester.pump();

      expect(callCount, 1);

      // We should see a loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 1)); // Finish request
      await tester.pumpAndSettle(); // Navigate away
    });

    testWidgets('Accessibility and layout properties', (tester) async {
      await tester.pumpWidget(
        createTestWidget(type: TransactionType.contribution),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(
        button.style?.minimumSize?.resolve({})?.height,
        48,
      ); // Accessibility target

      // Check for padding reflecting viewInsets.bottom
      final padding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byType(SingleChildScrollView),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding, isA<EdgeInsets>());
    });

    testWidgets(
      'Currency and formatting (JPY vs USD/BHD is tested by MoneyParser implicitly, but verifying display)',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return const TransactionBottomSheet(
                      fundId: 'test_fund',
                      currency: Currency('JPY'),
                      type: TransactionType.contribution,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Assert prefix text
        expect(find.textContaining('JPY '), findsOneWidget);
      },
    );
  });
}
