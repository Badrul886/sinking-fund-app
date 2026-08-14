import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/application/ports/recent_activity_repository.dart';
import 'package:sinking_fund/application/models/recent_activity_item.dart';
import 'package:sinking_fund/application/use_cases/dashboard/get_recent_activity_use_case.dart';
import 'package:sinking_fund/data/exceptions.dart';
import 'package:sinking_fund/domain/transaction.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';

class MockRecentActivityRepository implements RecentActivityRepository {
  bool shouldThrowDatabaseFailure = false;
  bool shouldThrowUnexpected = false;
  List<RecentActivityItem> itemsToReturn = [];

  @override
  Future<List<RecentActivityItem>> getRecentActivity({int limit = 5}) async {
    if (shouldThrowDatabaseFailure) {
      throw DatabaseFailureException('DB error');
    }
    if (shouldThrowUnexpected) {
      throw Exception('Unexpected error');
    }
    return itemsToReturn;
  }
}

void main() {
  group('GetRecentActivityUseCase', () {
    late MockRecentActivityRepository repository;
    late GetRecentActivityUseCase useCase;

    setUp(() {
      repository = MockRecentActivityRepository();
      useCase = GetRecentActivityUseCase(repository);
    });

    test('returns items correctly from repository', () async {
      final item = RecentActivityItem(
        transaction: Contribution(
          id: 'tx_1',
          amount: Money(minorUnits: 100, currency: const Currency('USD')),
          date: CalendarDate(2026, 1, 1),
        ),
        fundName: 'Vacation',
        fundCurrency: const Currency('USD'),
      );
      repository.itemsToReturn = [item];

      final result = await useCase.execute(limit: 5);
      expect(result.length, 1);
      expect(result.first.fundName, 'Vacation');
    });

    test('allows DatabaseFailureException to bubble as unexpected', () async {
      repository.shouldThrowDatabaseFailure = true;

      expect(() => useCase.execute(), throwsA(isA<DatabaseFailureException>()));
    });

    test('allows unexpected exceptions to bubble', () async {
      repository.shouldThrowUnexpected = true;

      expect(
        () => useCase.execute(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unexpected error'),
          ),
        ),
      );
    });
  });
}
