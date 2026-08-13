import 'money.dart';
import 'calendar_date.dart';
import 'schedule.dart';
import 'exceptions.dart';

enum FundStatus {
  overfunded,
  complete,
  deadlinePassed,
  notStarted,
  ahead,
  onTrack,
  behind,
}

class Fund {
  final String id;
  final String name;
  final Money targetAmount;
  final CalendarDate startDate;
  final CalendarDate targetDate;
  final ContributionFrequency contributionFrequency;

  Fund({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.startDate,
    required this.targetDate,
    required this.contributionFrequency,
  }) {
    if (targetAmount.minorUnits < 0) {
      throw ValidationException('Target amount cannot be negative');
    }
    if (targetDate < startDate) {
      throw ValidationException('Target date cannot be before start date');
    }
  }

  ContributionSchedule get schedule => ContributionSchedule(
    startDate: startDate,
    frequency: contributionFrequency,
  );
}
