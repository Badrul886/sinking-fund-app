import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/exceptions.dart';

void main() {
  const usd = Currency('USD');
  const bdt = Currency('BDT');

  group('Money', () {
    test('creation and zero', () {
      const m1 = Money(minorUnits: 100, currency: usd);
      expect(m1.minorUnits, 100);

      const z = Money.zero(usd);
      expect(z.minorUnits, 0);
    });

    test('equality and comparisons', () {
      const m1 = Money(minorUnits: 100, currency: usd);
      const m2 = Money(minorUnits: 100, currency: usd);
      const m3 = Money(minorUnits: 50, currency: usd);

      expect(m1, m2);
      expect(m1 == m3, false);
      expect(m1 > m3, true);
      expect(m3 < m1, true);
      expect(m1 >= m2, true);
    });

    test('addition and subtraction', () {
      const m1 = Money(minorUnits: 100, currency: usd);
      const m2 = Money(minorUnits: 50, currency: usd);

      expect(m1 + m2, const Money(minorUnits: 150, currency: usd));
      expect(m1 - m2, const Money(minorUnits: 50, currency: usd));
    });

    test('currency mismatch', () {
      const m1 = Money(minorUnits: 100, currency: usd);
      const m2 = Money(minorUnits: 50, currency: bdt);

      expect(() => m1 + m2, throwsA(isA<CurrencyMismatchException>()));
      expect(() => m1 > m2, throwsA(isA<CurrencyMismatchException>()));
    });

    test('multiplication and division', () {
      const m1 = Money(minorUnits: 100, currency: usd); // $1.00
      expect(
        m1.multiply(2),
        const Money(minorUnits: 200, currency: usd),
      ); // $2.00
      expect(m1.divide(2), const Money(minorUnits: 50, currency: usd)); // $0.50
    });

    test('Integer Half-Even Rounding (divide) - exact halves to even', () {
      expect(
        const Money(minorUnits: 5, currency: usd).divide(2).minorUnits,
        2,
      ); // 2.5 -> 2
      expect(
        const Money(minorUnits: 7, currency: usd).divide(2).minorUnits,
        4,
      ); // 3.5 -> 4
      expect(
        const Money(minorUnits: -5, currency: usd).divide(2).minorUnits,
        -2,
      ); // -2.5 -> -2
      expect(
        const Money(minorUnits: -7, currency: usd).divide(2).minorUnits,
        -4,
      ); // -3.5 -> -4
    });

    test('Integer Half-Even Rounding (divide) - just below/above half', () {
      expect(
        const Money(minorUnits: 26, currency: usd).divide(10).minorUnits,
        3,
      ); // 2.6 -> 3
      expect(
        const Money(minorUnits: 24, currency: usd).divide(10).minorUnits,
        2,
      ); // 2.4 -> 2
      expect(
        const Money(minorUnits: -26, currency: usd).divide(10).minorUnits,
        -3,
      ); // -2.6 -> -3
      expect(
        const Money(minorUnits: -24, currency: usd).divide(10).minorUnits,
        -2,
      ); // -2.4 -> -2
    });

    test('Integer Half-Even Rounding (divide) - odd/even quotient', () {
      expect(
        const Money(minorUnits: 15, currency: usd).divide(10).minorUnits,
        2,
      ); // 1.5 -> 2
      expect(
        const Money(minorUnits: 25, currency: usd).divide(10).minorUnits,
        2,
      ); // 2.5 -> 2
    });

    test('Integer Half-Even Rounding (divide) - very large integers', () {
      const int large = 9007199254740993; // 2^53 + 1
      expect(
        const Money(minorUnits: large, currency: usd).divide(1).minorUnits,
        large,
      );
    });

    test('division by zero throws', () {
      const m = Money(minorUnits: 100, currency: usd);
      expect(() => m.divide(0), throwsStateError);
    });
  });
}
