import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/transaction.dart';
import 'package:sinking_fund/domain/exceptions.dart';

void main() {
  const usd = Currency('USD');
  final date = CalendarDate(2023, 1, 1);

  group('Transaction', () {
    test('valid contribution', () {
      final c = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 100, currency: usd),
        date: date,
      );
      expect(c.amount.minorUnits, 100);
    });

    test('zero or negative amount rejection', () {
      expect(
        () => Contribution(
          id: 't2',
          amount: const Money(minorUnits: 0, currency: usd),
          date: date,
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Withdrawal(
          id: 't3',
          amount: const Money(minorUnits: -10, currency: usd),
          date: date,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('valid contribution with optional note', () {
      final c = Contribution(
        id: 't4',
        amount: const Money(minorUnits: 100, currency: usd),
        date: date,
        note: 'Bonus',
      );
      expect(c.note, 'Bonus');
    });

    test('valid withdrawal with optional note', () {
      final w = Withdrawal(
        id: 't5',
        amount: const Money(minorUnits: 50, currency: usd),
        date: date,
        note: 'Emergency',
      );
      expect(w.note, 'Emergency');
    });
  });
}
