import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/transaction.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/application/ports/clock.dart';
import 'package:sinking_fund/application/ports/identifier_generator.dart';
import 'package:sinking_fund/application/ports/onboarding_repository.dart';
import 'package:sinking_fund/application/use_cases/onboarding/complete_initial_onboarding_use_case.dart';

class MockClock implements Clock {
  final DateTime _now;
  MockClock(this._now);

  @override
  CalendarDate today() => CalendarDate(_now.year, _now.month, _now.day);
}

class MockIdentifierGenerator implements IdentifierGenerator {
  int _counter = 0;
  @override
  String generate() {
    _counter++;
    return 'id_$_counter';
  }
}

class MockOnboardingRepository implements OnboardingRepository {
  Fund? savedFund;
  Transaction? savedTransaction;
  bool shouldThrow = false;

  @override
  Future<void> completeOnboarding(Fund fund, Transaction? initialTransaction) async {
    if (shouldThrow) {
      throw Exception('Database Error');
    }
    savedFund = fund;
    savedTransaction = initialTransaction;
  }
}

void main() {
  group('CompleteInitialOnboardingUseCase', () {
    late MockClock clock;
    late MockIdentifierGenerator identifierGenerator;
    late MockOnboardingRepository repository;
    late CompleteInitialOnboardingUseCase useCase;

    setUp(() {
      clock = MockClock(DateTime(2025, 1, 1));
      identifierGenerator = MockIdentifierGenerator();
      repository = MockOnboardingRepository();
      useCase = CompleteInitialOnboardingUseCase(clock, repository, identifierGenerator);
    });

    test('successfully completes onboarding with initial savings = 0', () async {
      final preview = await useCase.execute(
        name: 'Vacation',
        targetAmount: Money(minorUnits: 100000, currency: Currency('USD')),
        targetDate: CalendarDate(2025, 12, 31),
        frequency: ContributionFrequency.monthly,
        initialSavings: Money(minorUnits: 0, currency: Currency('USD')),
      );

      expect(repository.savedFund, isNotNull);
      expect(repository.savedFund!.name, 'Vacation');
      expect(repository.savedFund!.startDate, CalendarDate(2025, 1, 1)); // From clock
      expect(repository.savedTransaction, isNull);
      
      expect(preview.calculationResult, isNotNull);
      expect(preview.trajectory, isNotNull);
    });

    test('successfully completes onboarding with initial savings > 0', () async {
      final preview = await useCase.execute(
        name: 'Car',
        targetAmount: Money(minorUnits: 500000, currency: Currency('USD')),
        targetDate: CalendarDate(2025, 12, 31),
        frequency: ContributionFrequency.monthly,
        initialSavings: Money(minorUnits: 50000, currency: Currency('USD')),
      );

      expect(repository.savedFund, isNotNull);
      expect(repository.savedFund!.id, 'id_1');
      expect(repository.savedTransaction, isNotNull);
      expect(repository.savedTransaction!.id, 'id_2');
      expect(repository.savedTransaction!.amount.minorUnits, 50000);
      
      // Calculate should reflect the initial savings
      expect(preview.calculationResult.currentBalance.minorUnits, 50000);
    });

    test('bubbles up persistence failure', () async {
      repository.shouldThrow = true;

      expect(
        () => useCase.execute(
          name: 'House',
          targetAmount: Money(minorUnits: 10000000, currency: Currency('USD')),
          targetDate: CalendarDate(2026, 1, 1),
          frequency: ContributionFrequency.monthly,
          initialSavings: Money(minorUnits: 0, currency: Currency('USD')),
        ),
        throwsException,
      );
    });
  });
}
