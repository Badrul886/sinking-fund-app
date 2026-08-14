import '../../application/ports/clock.dart';
import '../../domain/calendar_date.dart';

class SystemClock implements Clock {
  @override
  CalendarDate today() {
    final now = DateTime.now();
    return CalendarDate(now.year, now.month, now.day);
  }
}
