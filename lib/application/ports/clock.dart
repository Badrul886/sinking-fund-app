import '../../domain/calendar_date.dart';

abstract interface class Clock {
  CalendarDate today();
}
