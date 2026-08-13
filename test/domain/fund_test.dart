import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/exceptions.dart';

void main() {
  const usd = Currency('USD');

  group('Fund', () {
    test('valid creation with same-day target', () {
      final fund = Fund(
        id: '1',
        name: 'Test',
        targetAmount: const Money(minorUnits: 100, currency: usd),
        startDate: CalendarDate(2023, 1, 1),
        targetDate: CalendarDate(2023, 1, 1),
        contributionFrequency: ContributionFrequency.monthly,
      );
      expect(fund.id, '1');
    });

    test('Fund invalid target < 0', () {
      expect(
        () => Fund(
          id: '1',
          name: 'Invalid',
          targetAmount: const Money(
            minorUnits: -100,
            currency: Currency('USD'),
          ),
          startDate: CalendarDate(2023, 1, 1),
          targetDate: CalendarDate(2023, 1, 1),
          contributionFrequency: ContributionFrequency.monthly,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('target date before start date', () {
      expect(
        () => Fund(
          id: '1',
          name: 'Test',
          targetAmount: const Money(minorUnits: 100, currency: usd),
          startDate: CalendarDate(2023, 1, 2),
          targetDate: CalendarDate(2023, 1, 1),
          contributionFrequency: ContributionFrequency.monthly,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
