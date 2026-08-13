import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/exceptions.dart';

void main() {
  group('CalendarDate', () {
    test('validation', () {
      expect(
        () => CalendarDate(2023, 13, 1),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => CalendarDate(2023, 0, 1),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => CalendarDate(2023, 1, 32),
        throwsA(isA<ValidationException>()),
      );
    });

    test('leap years', () {
      expect(CalendarDate.daysInMonth(2024, 2), 29);
      expect(CalendarDate.daysInMonth(2023, 2), 28);
      expect(CalendarDate.daysInMonth(2000, 2), 29);
      expect(CalendarDate.daysInMonth(1900, 2), 28);
    });

    test('comparison', () {
      final d1 = CalendarDate(2023, 1, 1);
      final d2 = CalendarDate(2023, 1, 2);
      final d3 = CalendarDate(2023, 2, 1);
      final d4 = CalendarDate(2024, 1, 1);

      expect(d1 < d2, true);
      expect(d2 < d3, true);
      expect(d3 < d4, true);
      expect(d1 == CalendarDate(2023, 1, 1), true);
    });

    test('addMonths month-end clamping (leap to non-leap)', () {
      final d1 = CalendarDate(2024, 2, 29); // leap year
      final d2 = d1.addMonths(12); // advance 1 year to 2025
      expect(d2, CalendarDate(2025, 2, 28)); // clamps to 28

      final d3 = CalendarDate(2023, 1, 31); // jan 31
      final d4 = d3.addMonths(1); // feb
      expect(d4, CalendarDate(2023, 2, 28)); // clamps to 28

      final d5 = CalendarDate(2024, 1, 31); // jan 31, leap
      final d6 = d5.addMonths(1); // feb
      expect(d6, CalendarDate(2024, 2, 29)); // clamps to 29
    });

    test('addMonths year boundary', () {
      final d1 = CalendarDate(2023, 12, 15);
      final d2 = d1.addMonths(1);
      expect(d2, CalendarDate(2024, 1, 15));

      final d3 = CalendarDate(2023, 11, 30);
      final d4 = d3.addMonths(14); // advance 1 year and 2 months
      expect(d4, CalendarDate(2025, 1, 30));
    });
  });
}
