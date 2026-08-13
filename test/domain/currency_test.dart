import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/currency.dart';

void main() {
  group('Currency', () {
    test('lookup valid metadata', () {
      final usd = Currency('USD');
      expect(usd.metadata.alpha3Code, 'USD');
      expect(usd.metadata.numericCode, 840);
      expect(usd.metadata.minorUnitExponent, 2);
    });

    test('invalid code throws', () {
      final invalid = Currency('XXX');
      expect(() => invalid.metadata, throwsStateError);
    });

    test('equality', () {
      expect(const Currency('USD'), const Currency('USD'));
      expect(const Currency('USD') == const Currency('BDT'), false);
    });
  });
}
