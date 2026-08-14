import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/presentation/formatters/percentage_formatter.dart';

void main() {
  group('PercentageFormatter', () {
    const formatter = PercentageFormatter();

    test('formats zero correctly', () {
      expect(formatter.format(0.0), '0%');
      expect(formatter.format(-0.5), '0%');
    });

    test('formats standard values correctly', () {
      expect(formatter.format(0.5), '50%');
      expect(formatter.format(0.25), '25%');
      expect(formatter.format(0.75), '75%');
    });

    test('rounds values correctly', () {
      expect(formatter.format(0.123), '12%');
      expect(formatter.format(0.126), '13%');
    });

    test('prevents false zero', () {
      expect(formatter.format(0.001), '1%'); // Would otherwise round to 0%
    });

    test('prevents false completion', () {
      expect(formatter.format(0.999), '99%'); // Would otherwise round to 100%
    });

    test('formats exactly 100% correctly', () {
      expect(formatter.format(1.0), '100%');
    });

    test('formats over 100% correctly', () {
      expect(formatter.format(1.5), '150%');
      expect(formatter.format(2.0), '200%');
    });
  });
}
