import 'calendar_date.dart';

enum ContributionFrequency { weekly, biweekly, monthly }

class ContributionSchedule {
  final CalendarDate startDate;
  final ContributionFrequency frequency;

  const ContributionSchedule({
    required this.startDate,
    required this.frequency,
  });

  List<CalendarDate> generateDates(CalendarDate limitDate) {
    if (limitDate < startDate) return [];
    List<CalendarDate> dates = [];
    CalendarDate current = startDate;
    int periods = 0;
    while (current <= limitDate) {
      dates.add(current);
      periods++;
      current = _nextDate(periods);
    }
    return dates;
  }

  CalendarDate _nextDate(int periods) {
    switch (frequency) {
      case ContributionFrequency.weekly:
        return startDate.addDays(periods * 7);
      case ContributionFrequency.biweekly:
        return startDate.addDays(periods * 14);
      case ContributionFrequency.monthly:
        return startDate.addMonths(periods);
    }
  }
}
