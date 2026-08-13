import 'exceptions.dart';

class CalendarDate implements Comparable<CalendarDate> {
  final int year;
  final int month;
  final int day;

  const CalendarDate._(this.year, this.month, this.day);

  factory CalendarDate(int year, int month, int day) {
    if (month < 1 || month > 12) throw ValidationException('Invalid month');
    if (day < 1 || day > daysInMonth(year, month)) {
      throw ValidationException('Invalid day');
    }
    return CalendarDate._(year, month, day);
  }

  static int daysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    }
    const days = [31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }

  static bool _isLeapYear(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }

  CalendarDate addDays(int days) {
    final dt = DateTime.utc(year, month, day).add(Duration(days: days));
    return CalendarDate(dt.year, dt.month, dt.day);
  }

  CalendarDate addMonths(int months) {
    int newMonth = month + months;
    int newYear = year;
    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }
    int maxDays = CalendarDate.daysInMonth(newYear, newMonth);
    int newDay = day;
    if (newDay > maxDays) {
      newDay = maxDays;
    }
    return CalendarDate(newYear, newMonth, newDay);
  }

  @override
  int compareTo(CalendarDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  bool operator <(CalendarDate other) => compareTo(other) < 0;
  bool operator <=(CalendarDate other) => compareTo(other) <= 0;
  bool operator >(CalendarDate other) => compareTo(other) > 0;
  bool operator >=(CalendarDate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDate &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => year.hashCode ^ month.hashCode ^ day.hashCode;

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
