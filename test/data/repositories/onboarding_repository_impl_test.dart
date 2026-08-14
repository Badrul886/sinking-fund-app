import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:sinking_fund/data/local/database/app_database.dart';
import 'package:sinking_fund/data/repositories/onboarding_repository_impl.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/transaction.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/data/exceptions.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  late AppDatabase db;
  late OnboardingRepositoryImpl repository;

  const usd = Currency('USD');
  const bdt = Currency('BDT');

  Fund createTestFund(String id, Currency currency) {
    return Fund(
      id: id,
      name: 'Test Fund $id',
      targetAmount: Money(minorUnits: 10000, currency: currency),
      startDate: CalendarDate(2023, 1, 1),
      targetDate: CalendarDate(2023, 12, 31),
      contributionFrequency: ContributionFrequency.monthly,
    );
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = OnboardingRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('OnboardingRepositoryImpl Atomicity', () {
    test('A. Onboarding success (Fund + Contribution + settings)', () async {
      final fund = createTestFund('f1', usd);
      final tx = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 5000, currency: usd),
        date: CalendarDate(2023, 1, 1),
      );

      await repository.completeOnboarding(fund, tx);

      // Verify Fund exists
      final fundRow = await (db.select(
        db.funds,
      )..where((t) => t.id.equals('f1'))).getSingleOrNull();
      expect(fundRow, isNotNull);

      // Verify Contribution exists
      final txRow = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals('t1'))).getSingleOrNull();
      expect(txRow, isNotNull);

      // Verify onboarding flag
      final settingRow =
          await (db.select(db.appSettings)
                ..where((t) => t.key.equals('has_completed_onboarding')))
              .getSingleOrNull();
      expect(settingRow?.value, 'true');
    });

    test('B. Onboarding Fund insertion failure', () async {
      // Force fund insertion to fail by dropping the funds table
      await db.customStatement('DROP TABLE funds');

      final fund = createTestFund('f1', usd);

      try {
        await repository.completeOnboarding(fund, null);
        fail('Should throw');
      } catch (_) {}

      // Verify onboarding flag NOT set
      final settingRow =
          await (db.select(db.appSettings)
                ..where((t) => t.key.equals('has_completed_onboarding')))
              .getSingleOrNull();
      expect(settingRow, isNull);
    });

    test(
      'C. Onboarding Contribution insertion failure (currency mismatch)',
      () async {
        final fund = createTestFund('f1', usd);
        final tx = Contribution(
          id: 't1',
          amount: const Money(minorUnits: 5000, currency: bdt), // Mismatch!
          date: CalendarDate(2023, 1, 1),
        );

        try {
          await repository.completeOnboarding(fund, tx);
          fail('Should throw');
        } catch (_) {}

        // Verify Fund rollback
        final fundRow = await (db.select(
          db.funds,
        )..where((t) => t.id.equals('f1'))).getSingleOrNull();
        expect(fundRow, isNull);

        // Verify Contribution rollback
        final txRow = await (db.select(
          db.transactions,
        )..where((t) => t.id.equals('t1'))).getSingleOrNull();
        expect(txRow, isNull);

        // Verify onboarding flag NOT set
        final settingRow =
            await (db.select(db.appSettings)
                  ..where((t) => t.key.equals('has_completed_onboarding')))
                .getSingleOrNull();
        expect(settingRow, isNull);
      },
    );

    test('D. Onboarding settings insertion failure', () async {
      final fund = createTestFund('f1', usd);

      // Force appSettings insertion to fail by dropping the table
      await db.customStatement('DROP TABLE app_settings');

      try {
        await repository.completeOnboarding(fund, null);
        fail('Should throw');
      } catch (_) {}

      // Verify Fund rollback
      final fundRow = await (db.select(
        db.funds,
      )..where((t) => t.id.equals('f1'))).getSingleOrNull();
      expect(fundRow, isNull);
    });
  });
}
