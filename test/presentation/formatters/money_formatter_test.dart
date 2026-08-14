import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/presentation/formatters/money_formatter.dart';

void main() {
  group('MoneyFormatter', () {
    test('formats zero decimals (JPY)', () {
      final formatter = const MoneyFormatter(locale: 'en_US');
      final jpy = const Currency('JPY');
      final money = Money(minorUnits: 123456789, currency: jpy);

      final result = formatter.format(money);
      expect(result, '¥123,456,789');
    });

    test('formats negative zero decimals (JPY)', () {
      final formatter = const MoneyFormatter(locale: 'en_US');
      final jpy = const Currency('JPY');
      final money = Money(minorUnits: -123456789, currency: jpy);

      final result = formatter.format(money);
      expect(result, '-¥123,456,789'); // en_US standard for JPY is -¥123,456,789
    });

    test('formats two decimals (USD)', () {
      final formatter = const MoneyFormatter(locale: 'en_US');
      final usd = const Currency('USD');
      final money = Money(minorUnits: 123456789, currency: usd); // 1,234,567.89

      final result = formatter.format(money);
      expect(result, '\$1,234,567.89');
    });

    test('formats negative two decimals (USD)', () {
      final formatter = const MoneyFormatter(locale: 'en_US');
      final usd = const Currency('USD');
      final money = Money(minorUnits: -123456789, currency: usd);

      final result = formatter.format(money);
      expect(result, '-\$1,234,567.89');
    });

    test('formats exactly zero correctly (USD)', () {
      final formatter = const MoneyFormatter(locale: 'en_US');
      final usd = const Currency('USD');
      final money = Money(minorUnits: 0, currency: usd);

      final result = formatter.format(money);
      expect(result, '\$0.00');
    });

    test('formats fraction only (USD)', () {
      final formatter = const MoneyFormatter(locale: 'en_US');
      final usd = const Currency('USD');
      final money = Money(minorUnits: 5, currency: usd); // 0.05

      final result = formatter.format(money);
      expect(result, '\$0.05');
    });
    
    test('formats fraction only negative (USD)', () {
      final formatter = const MoneyFormatter(locale: 'en_US');
      final usd = const Currency('USD');
      final money = Money(minorUnits: -5, currency: usd); // -0.05

      final result = formatter.format(money);
      expect(result, '-\$0.05');
    });

    test('formats three decimals (BHD)', () {
      final formatter = const MoneyFormatter(locale: 'en_US');
      final bhd = const Currency('BHD');
      final money = Money(minorUnits: 123456789, currency: bhd); // 123,456.789

      final result = formatter.format(money);
      // Depending on intl package, it might output 'BHD 123,456.789' or something similar.
      // We check that it contains the decimal and the fraction.
      expect(result, contains('123,456.789'));
    });

    test('handles large integers without double precision loss', () {
      final formatter = const MoneyFormatter(locale: 'en_US');
      final usd = const Currency('USD');
      
      // Dart integers are 64-bit on native. 
      // A number that cannot be represented accurately in double: 9007199254740993 (2^53 + 1)
      final money = Money(minorUnits: 9007199254740993, currency: usd);
      
      final result = formatter.format(money);
      expect(result, '\$90,071,992,547,409.93');
    });
  });
}
