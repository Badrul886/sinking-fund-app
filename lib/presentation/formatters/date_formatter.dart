import 'package:intl/intl.dart';
import '../../application/ports/clock.dart';
import '../../domain/calendar_date.dart';

class DateFormatter {
  final Clock clock;
  final String? locale;

  const DateFormatter({required this.clock, this.locale});

  /// Formats the date absolutely (e.g., "Oct 12, 2026").
  String formatAbsolute(CalendarDate date) {
    final dateTime = DateTime(date.year, date.month, date.day);
    // Use yMMMd for standard medium-length date format
    return DateFormat.yMMMd(locale).format(dateTime);
  }

  /// Formats the date relative to the current date from the clock.
  /// (e.g. "Today", "Tomorrow", "In 30 days", "30 days ago")
  String formatRelative(CalendarDate date) {
    final today = clock.today();

    final currentDt = DateTime.utc(today.year, today.month, today.day);
    final targetDt = DateTime.utc(date.year, date.month, date.day);

    final difference = targetDt.difference(currentDt).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Tomorrow";
    } else if (difference == -1) {
      return "Yesterday";
    } else if (difference > 1) {
      return "In $difference days";
    } else {
      return "${difference.abs()} days ago";
    }
  }

  /// Calculates presentation-only days remaining.
  int getDaysRemaining(CalendarDate date) {
    final today = clock.today();

    final currentDt = DateTime.utc(today.year, today.month, today.day);
    final targetDt = DateTime.utc(date.year, date.month, date.day);

    return targetDt.difference(currentDt).inDays;
  }
}
