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
      final c = Contribution(const Money(minorUnits: 100, currency: usd), date);
      expect(c.amount.minorUnits, 100);
    });

    test('zero or negative amount rejection', () {
      expect(
        () => Contribution(const Money(minorUnits: 0, currency: usd), date),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => Withdrawal(const Money(minorUnits: -10, currency: usd), date),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
