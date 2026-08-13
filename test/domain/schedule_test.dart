import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';

void main() {
  group('ContributionSchedule', () {
    test('weekly', () {
      final start = CalendarDate(2023, 1, 1);
      final limit = CalendarDate(2023, 1, 20);
      final sched = ContributionSchedule(
        startDate: start,
        frequency: ContributionFrequency.weekly,
      );

      final dates = sched.generateDates(limit);
      expect(dates, [
        CalendarDate(2023, 1, 1),
        CalendarDate(2023, 1, 8),
        CalendarDate(2023, 1, 15),
      ]);
    });

    test('end-of-month clamping (Jan 31 -> Feb 28 -> Mar 31)', () {
      final start = CalendarDate(2023, 1, 31);
      final limit = CalendarDate(2023, 4, 30);
      final sched = ContributionSchedule(
        startDate: start,
        frequency: ContributionFrequency.monthly,
      );

      final dates = sched.generateDates(limit);
      expect(dates, [
        CalendarDate(2023, 1, 31),
        CalendarDate(2023, 2, 28),
        CalendarDate(2023, 3, 31),
        CalendarDate(2023, 4, 30),
      ]);
    });

    test('leap year clamping', () {
      final start = CalendarDate(2024, 1, 31);
      final limit = CalendarDate(2024, 3, 1);
      final sched = ContributionSchedule(
        startDate: start,
        frequency: ContributionFrequency.monthly,
      );

      final dates = sched.generateDates(limit);
      expect(dates, [CalendarDate(2024, 1, 31), CalendarDate(2024, 2, 29)]);
    });
  });
}
