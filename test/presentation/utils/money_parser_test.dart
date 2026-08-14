import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/presentation/utils/money_parser.dart';
import 'package:sinking_fund/domain/currency.dart';

void main() {
  group('MoneyParser', () {
    test('USD (exponent 2)', () {
      final currency = Currency('USD');
      
      expect(MoneyParser.parse('100', currency).minorUnits, 10000);
      expect(MoneyParser.parse('100.5', currency).minorUnits, 10050);
      expect(MoneyParser.parse('100.50', currency).minorUnits, 10050);
      
      expect(() => MoneyParser.parse('100.505', currency), throwsFormatException);
    });

    test('JPY (exponent 0)', () {
      final currency = Currency('JPY');
      
      expect(MoneyParser.parse('100', currency).minorUnits, 100);
      
      expect(() => MoneyParser.parse('100.0', currency), throwsFormatException);
    });

    test('BHD (exponent 3)', () {
      final currency = Currency('BHD');
      
      expect(MoneyParser.parse('12.345', currency).minorUnits, 12345);
      expect(MoneyParser.parse('12.34', currency).minorUnits, 12340);
      
      expect(() => MoneyParser.parse('12.3456', currency), throwsFormatException);
    });

    test('Edge cases', () {
      final currency = Currency('USD');

      // Empty / whitespace
      expect(() => MoneyParser.parse('', currency), throwsFormatException);
      expect(() => MoneyParser.parse('   ', currency), throwsFormatException);
      
      // Negative
      expect(() => MoneyParser.parse('-100', currency), throwsFormatException);
      
      // Plus sign
      expect(() => MoneyParser.parse('+100', currency), throwsFormatException);
      
      // Fractional only
      expect(MoneyParser.parse('.50', currency).minorUnits, 50);
      expect(MoneyParser.parse('0.50', currency).minorUnits, 50);
      
      // Whole with dangling dot
      expect(MoneyParser.parse('100.', currency).minorUnits, 10000);
      
      // Malformed decimal
      expect(() => MoneyParser.parse('100.50.50', currency), throwsFormatException);
      
      // Leading zeros
      expect(MoneyParser.parse('000100', currency).minorUnits, 10000);
      expect(MoneyParser.parse('0100.5', currency).minorUnits, 10050);
    });
  });
}
