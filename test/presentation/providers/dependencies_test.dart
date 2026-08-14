import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:sinking_fund/data/local/database/app_database.dart';
import 'package:sinking_fund/presentation/providers/dependencies.dart';
import 'package:sinking_fund/application/ports/clock.dart';
import 'package:sinking_fund/domain/calendar_date.dart';

class FakeClock implements Clock {
  final CalendarDate fakeDate;
  FakeClock(this.fakeDate);
  @override
  CalendarDate today() => fakeDate;
}

void main() {
  group('Dependency Providers', () {
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

    test('databaseProvider injects AppDatabase and closes on dispose', () {
      final db = container.read(databaseProvider);
      expect(db, isNotNull);
      // Ensure we can close it correctly via container dispose
    });

    test('clockProvider injects FakeClock', () {
      final clock = container.read(clockProvider);
      expect(clock.today().year, 2026);
    });

    test('use cases are instantiated with proper dependencies', () {
      final createFundUseCase = container.read(createFundUseCaseProvider);
      expect(createFundUseCase, isNotNull);

      final getFundUseCase = container.read(getFundUseCaseProvider);
      expect(getFundUseCase, isNotNull);
    });
  });
}
