import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:sinking_fund/data/local/database/app_database.dart';
import 'package:sinking_fund/data/repositories/recent_activity_repository_impl.dart';
import 'package:sinking_fund/domain/transaction.dart';

void main() {
  group('RecentActivityRepositoryImpl', () {
    late AppDatabase db;
    late RecentActivityRepositoryImpl repository;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repository = RecentActivityRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('returns empty result when no transactions exist', () async {
      final result = await repository.getRecentActivity();
      expect(result, isEmpty);
    });

    test(
      'joins transaction to correct fund and returns correctly sorted',
      () async {
        // Create funds
        await db
            .into(db.funds)
            .insert(
              FundsCompanion.insert(
                id: 'f1',
                name: 'Vacation',
                targetMinorUnits: 1000,
                currencyCode: 'USD',
                startDate: '2026-01-01',
                targetDate: '2026-12-31',
                contributionFrequency: 2,
              ),
            );

        await db
            .into(db.funds)
            .insert(
              FundsCompanion.insert(
                id: 'f2',
                name: 'Car',
                targetMinorUnits: 5000,
                currencyCode: 'EUR',
                startDate: '2026-01-01',
                targetDate: '2027-12-31',
                contributionFrequency: 2,
              ),
            );

        // Insert transactions out of order
        // tx1: f1, old date
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: 'tx1',
                fundId: 'f1',
                amountMinorUnits: 100,
                date: '2026-01-01',
                type: 0,
                createdAt: 100,
              ),
            );

        // tx2: f2, newer date
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: 'tx2',
                fundId: 'f2',
                amountMinorUnits: 200,
                date: '2026-01-05',
                type: 0,
                createdAt: 200,
              ),
            );

        // tx3: f1, same newer date, but newer created_at
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: 'tx3',
                fundId: 'f1',
                amountMinorUnits: 300,
                date: '2026-01-05',
                type: 1, // withdrawal
                createdAt: 300,
              ),
            );

        // tx4: f2, same newer date, same created_at, but larger id (string sorting)
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: 'tx4',
                fundId: 'f2',
                amountMinorUnits: 400,
                date: '2026-01-05',
                type: 0,
                createdAt: 300,
              ),
            );

        final result = await repository.getRecentActivity(limit: 10);

        expect(result.length, 4);

        // Order should be: date DESC, createdAt DESC, id DESC
        // 1. tx4 (date: 2026-01-05, createdAt: 300, id: tx4)
        // 2. tx3 (date: 2026-01-05, createdAt: 300, id: tx3)
        // 3. tx2 (date: 2026-01-05, createdAt: 200, id: tx2)
        // 4. tx1 (date: 2026-01-01, createdAt: 100, id: tx1)

        expect(result[0].transaction.id, 'tx4');
        expect(result[0].fundName, 'Car');
        expect(result[0].fundCurrency.code, 'EUR');
        expect(result[0].transaction is Contribution, isTrue);

        expect(result[1].transaction.id, 'tx3');
        expect(result[1].fundName, 'Vacation');
        expect(result[1].fundCurrency.code, 'USD');
        expect(result[1].transaction is Withdrawal, isTrue);

        expect(result[2].transaction.id, 'tx2');
        expect(result[3].transaction.id, 'tx1');
      },
    );

    test('respects limit', () async {
      await db
          .into(db.funds)
          .insert(
            FundsCompanion.insert(
              id: 'f1',
              name: 'Vacation',
              targetMinorUnits: 1000,
              currencyCode: 'USD',
              startDate: '2026-01-01',
              targetDate: '2026-12-31',
              contributionFrequency: 2,
            ),
          );

      for (var i = 0; i < 10; i++) {
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: 'tx_$i',
                fundId: 'f1',
                amountMinorUnits: 100,
                date: '2026-01-01',
                type: 0,
                createdAt: i,
              ),
            );
      }

      final result = await repository.getRecentActivity(limit: 3);
      expect(result.length, 3);
      // Newest created_at first: 9, 8, 7
      expect(result[0].transaction.id, 'tx_9');
      expect(result[1].transaction.id, 'tx_8');
      expect(result[2].transaction.id, 'tx_7');
    });
  });
}
