import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:sinking_fund/data/local/database/app_database.dart';
import 'package:sinking_fund/presentation/providers/dependencies.dart';
import 'package:sinking_fund/presentation/state/funds_list_notifier.dart';
import 'package:sinking_fund/application/ports/clock.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/schedule.dart';

class FakeClock implements Clock {
  final CalendarDate fakeDate;
  FakeClock(this.fakeDate);
  @override
  CalendarDate today() => fakeDate;
}

void main() {
  group('FundsListNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((ref) {
            final db = AppDatabase.forTesting(NativeDatabase.memory());
            ref.onDispose(() => db.close());
            return db;
          }),
          clockProvider.overrideWithValue(FakeClock(CalendarDate(2026, 8, 14))),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty list', () async {
      final state = await container.read(fundsListProvider.future);
      expect(state, isEmpty);
    });

    test('createFund updates state and invalidates', () async {
      final notifier = container.read(fundsListProvider.notifier);

      await notifier.createFund(
        name: 'Test Fund',
        targetAmount: Money(
          minorUnits: 100000,
          currency: const Currency('USD'),
        ),
        startDate: CalendarDate(2026, 8, 1),
        targetDate: CalendarDate(2026, 12, 1),
        contributionFrequency: ContributionFrequency.monthly,
      );

      final state = await container.read(fundsListProvider.future);
      expect(state.length, 1);
      expect(state.first.fund.name, 'Test Fund');
    });
  });
}
