import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/application/ports/clock.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/presentation/formatters/date_formatter.dart';

class MockClock implements Clock {
  final CalendarDate fixedToday;
  MockClock(this.fixedToday);

  @override
  CalendarDate today() => fixedToday;
}

void main() {
  group('DateFormatter', () {
    late DateFormatter formatter;
    late MockClock mockClock;

    setUp(() {
      // Oct 12, 2026
      mockClock = MockClock(CalendarDate(2026, 10, 12));
      formatter = DateFormatter(clock: mockClock, locale: 'en_US');
    });

    test('formatAbsolute returns standard date', () {
      final date = CalendarDate(2026, 12, 25);
      final result = formatter.formatAbsolute(date);
      expect(result, 'Dec 25, 2026');
    });

    test('formatRelative for today', () {
      final date = CalendarDate(2026, 10, 12);
      final result = formatter.formatRelative(date);
      expect(result, 'Today');
    });

    test('formatRelative for tomorrow', () {
      final date = CalendarDate(2026, 10, 13);
      final result = formatter.formatRelative(date);
      expect(result, 'Tomorrow');
    });

    test('formatRelative for yesterday', () {
      final date = CalendarDate(2026, 10, 11);
      final result = formatter.formatRelative(date);
      expect(result, 'Yesterday');
    });

    test('formatRelative for future days', () {
      final date = CalendarDate(2026, 11, 11); // 30 days later
      final result = formatter.formatRelative(date);
      expect(result, 'In 30 days');
    });

    test('formatRelative for past days', () {
      final date = CalendarDate(2026, 9, 12); // 30 days ago
      final result = formatter.formatRelative(date);
      expect(result, '30 days ago');
    });

    test('getDaysRemaining returns exact integer difference', () {
      final date = CalendarDate(2026, 10, 22);
      final result = formatter.getDaysRemaining(date);
      expect(result, 10);
    });
  });
}
