import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/core/platform/system_clock.dart';
void main() {
  group('SystemClock', () {
    test('today() returns current local date', () {
      final clock = SystemClock();
      final now = DateTime.now();
      final today = clock.today();

      expect(today.year, equals(now.year));
      expect(today.month, equals(now.month));
      expect(today.day, equals(now.day));
    });
  });
}
