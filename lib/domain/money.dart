import 'currency.dart';
import 'exceptions.dart';

class Money implements Comparable<Money> {
  final int minorUnits;
  final Currency currency;

  const Money({required this.minorUnits, required this.currency});

  const Money.zero(this.currency) : minorUnits = 0;

  void _checkCurrency(Money other) {
    if (currency != other.currency) {
      throw CurrencyMismatchException(currency.code, other.currency.code);
    }
  }

  Money operator +(Money other) {
    _checkCurrency(other);
    return Money(minorUnits: minorUnits + other.minorUnits, currency: currency);
  }

  Money operator -(Money other) {
    _checkCurrency(other);
    return Money(minorUnits: minorUnits - other.minorUnits, currency: currency);
  }

  Money multiply(int factor) {
    final value = minorUnits * factor;
    return Money(minorUnits: value, currency: currency);
  }

  Money divide(int divisor) {
    if (divisor == 0) throw StateError('Division by zero');
    final quotient = _roundHalfEvenInt(minorUnits, divisor);
    return Money(minorUnits: quotient, currency: currency);
  }

  static int _roundHalfEvenInt(int numerator, int denominator) {
    if (denominator == 0) throw StateError('Division by zero');
    int absNum = numerator.abs();
    int absDiv = denominator.abs();
    int quotient = absNum ~/ absDiv;
    int remainder = absNum % absDiv;

    if (remainder * 2 > absDiv) {
      quotient += 1;
    } else if (remainder * 2 == absDiv) {
      if (quotient % 2 != 0) {
        quotient += 1;
      }
    }

    int finalSign = (numerator.isNegative != denominator.isNegative) ? -1 : 1;
    return quotient * finalSign;
  }

  static int multiplyAndDivide(int base, int multiplier, int divisor) {
    return _roundHalfEvenInt(base * multiplier, divisor);
  }

  @override
  int compareTo(Money other) {
    _checkCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;
  bool operator >(Money other) => compareTo(other) > 0;
  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          currency == other.currency &&
          minorUnits == other.minorUnits;

  @override
  int get hashCode => minorUnits.hashCode ^ currency.hashCode;
}
