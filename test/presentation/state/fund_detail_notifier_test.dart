import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:sinking_fund/data/local/database/app_database.dart';
import 'package:sinking_fund/presentation/providers/dependencies.dart';
import 'package:sinking_fund/presentation/state/funds_list_notifier.dart';
import 'package:sinking_fund/presentation/state/fund_detail_notifier.dart';
import 'package:sinking_fund/application/ports/clock.dart';
import 'package:sinking_fund/application/errors/application_error.dart';
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
  group('FundDetailNotifier', () {
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

    test('addContribution updates state and invalidates', () async {
      final listNotifier = container.read(fundsListProvider.notifier);
      await listNotifier.createFund(
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
      final fundId = state.first.fund.id;

      final detailNotifier = container.read(
        fundDetailProvider(fundId).notifier,
      );
      await detailNotifier.addContribution(
        amount: Money(minorUnits: 10000, currency: const Currency('USD')),
        date: CalendarDate(2026, 8, 14),
      );

      final detailState = await container.read(
        fundDetailProvider(fundId).future,
      );
      expect(
        detailState.fundState.calculationResult.currentBalance.minorUnits,
        10000,
      );
    });

    test('AsyncError is preserved as ApplicationError', () async {
      final provider = fundDetailProvider('non-existent-id');

      // Keep the provider alive and trigger evaluation
      final sub = container.listen(provider, (prev, next) {});

      // Allow the async build to complete and the error state to propagate
      // In Riverpod 3.x, if build throws, the state transitions to AsyncError.
      await Future<void>.delayed(Duration.zero);

      final state = container.read(provider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<FundNotFoundError>());

      sub.close();
    });
  });
}
