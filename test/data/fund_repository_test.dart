import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:sinking_fund/data/local/database/app_database.dart';
import 'package:sinking_fund/data/repositories/fund_repository_impl.dart';
import 'package:sinking_fund/data/exceptions.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/transaction.dart';

void main() {
  late AppDatabase db;
  late FundRepositoryImpl repository;
  const usd = Currency('USD');
  const bdt = Currency('BDT');

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = FundRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  Fund createTestFund(String id, Currency curr) {
    return Fund(
      id: id,
      name: 'Test Fund $id',
      targetAmount: Money(minorUnits: 10000, currency: curr),
      startDate: CalendarDate(2023, 1, 1),
      targetDate: CalendarDate(2023, 12, 31),
      contributionFrequency: ContributionFrequency.monthly,
    );
  }

  group('FundRepositoryImpl', () {
    test('Fund round-trip', () async {
      final fund = createTestFund('1', usd);
      await repository.saveFund(fund);

      final fetched = await repository.getFund('1');
      expect(fetched, isNotNull);
      expect(fetched!.id, '1');
      expect(fetched.targetAmount.minorUnits, 10000);
      expect(fetched.targetAmount.currency, usd);
    });

    test('Transaction round-trip (Contribution and Withdrawal)', () async {
      final fund = createTestFund('1', usd);
      await repository.saveFund(fund);

      final t1 = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 1000, currency: usd),
        date: CalendarDate(2023, 2, 1),
      );
      final t2 = Withdrawal(
        id: 't2',
        amount: const Money(minorUnits: 500, currency: usd),
        date: CalendarDate(2023, 3, 1),
      );

      await repository.saveTransaction('1', t1);
      await repository.saveTransaction('1', t2);

      final transactions = await repository.getTransactionsForFund('1');
      expect(transactions.length, 2);
      expect(transactions[0], isA<Contribution>());
      expect(transactions[0].id, 't1');
      expect(transactions[0].amount.minorUnits, 1000);
      expect(transactions[1], isA<Withdrawal>());
      expect(transactions[1].id, 't2');
      expect(transactions[1].amount.minorUnits, 500);
    });

    test(
      'Currency mismatch on insert throws ConstraintViolationException',
      () async {
        final fund = createTestFund('1', bdt);
        await repository.saveFund(fund);

        final t1 = Contribution(
          id: 't1',
          amount: const Money(minorUnits: 1000, currency: usd), // Mismatch
          date: CalendarDate(2023, 2, 1),
        );

        expect(
          () => repository.saveTransaction('1', t1),
          throwsA(isA<ConstraintViolationException>()),
        );
      },
    );

    test('Cascade deletion', () async {
      final fund = createTestFund('1', usd);
      await repository.saveFund(fund);

      final t1 = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 1000, currency: usd),
        date: CalendarDate(2023, 2, 1),
      );
      await repository.saveTransaction('1', t1);

      await repository.deleteFund('1');

      final funds = await repository.getAllFunds();
      expect(funds.isEmpty, true);

      // Verify transaction is cascaded by querying DB directly
      final transactions = await db.select(db.transactions).get();
      expect(transactions.isEmpty, true);
    });

    test('Chronological ordering with same-date tie-break', () async {
      final fund = createTestFund('1', usd);
      await repository.saveFund(fund);

      final date = CalendarDate(2023, 2, 1);

      // Insert in reverse order
      await repository.saveTransaction(
        '1',
        Contribution(
          id: 't3',
          amount: const Money(minorUnits: 30, currency: usd),
          date: date,
        ),
      );
      await Future.delayed(
        const Duration(milliseconds: 10),
      ); // Guarantee created_at difference
      await repository.saveTransaction(
        '1',
        Contribution(
          id: 't2',
          amount: const Money(minorUnits: 20, currency: usd),
          date: date,
        ),
      );

      final transactions = await repository.getTransactionsForFund('1');
      expect(transactions.length, 2);
      // t3 was inserted first, so it has earlier created_at, thus it should come first despite id 't3' > 't2'
      expect(transactions[0].id, 't3');
      expect(transactions[1].id, 't2');
    });

    test('Duplicate ID handling', () async {
      final fund = createTestFund('1', usd);
      await repository.saveFund(fund);
      // InsertOrReplace semantics mean duplicate ID replaces, no crash.
      await repository.saveFund(fund);
      final funds = await repository.getAllFunds();
      expect(funds.length, 1);
    });
    test('Persistence across reopen', () async {
      final tempFile = File('test_db.sqlite');
      if (tempFile.existsSync()) tempFile.deleteSync();

      var fileDb = AppDatabase.forTesting(NativeDatabase(tempFile));
      var fileRepo = FundRepositoryImpl(fileDb);

      final fund = createTestFund('1', usd);
      await fileRepo.saveFund(fund);
      final t1 = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 1000, currency: usd),
        date: CalendarDate(2023, 2, 1),
      );
      await fileRepo.saveTransaction('1', t1);

      await fileDb.close();

      // Reopen
      fileDb = AppDatabase.forTesting(NativeDatabase(tempFile));
      fileRepo = FundRepositoryImpl(fileDb);

      final fetchedFund = await fileRepo.getFund('1');
      expect(fetchedFund, isNotNull);
      expect(fetchedFund!.name, 'Test Fund 1');

      final fetchedTxs = await fileRepo.getTransactionsForFund('1');
      expect(fetchedTxs.length, 1);
      expect(fetchedTxs[0].id, 't1');

      await fileDb.close();
      if (tempFile.existsSync()) tempFile.deleteSync();
    });

    test('Large Money round-trip', () async {
      final fund = createTestFund('1', usd);
      await repository.saveFund(fund);

      // 9,000,000,000,000,000 minor units
      const largeAmount = 9000000000000000;
      final t1 = Contribution(
        id: 't1',
        amount: const Money(minorUnits: largeAmount, currency: usd),
        date: CalendarDate(2023, 2, 1),
      );
      await repository.saveTransaction('1', t1);

      final fetchedTxs = await repository.getTransactionsForFund('1');
      expect(fetchedTxs[0].amount.minorUnits, largeAmount);
    });

    test('Currency precision round-trip', () async {
      const jpy = Currency('JPY');
      const bhd = Currency('BHD');

      final fundJpy = createTestFund('jpy', jpy);
      await repository.saveFund(fundJpy);
      final tJpy = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 500, currency: jpy),
        date: CalendarDate(2023, 2, 1),
      );
      await repository.saveTransaction('jpy', tJpy);

      final fundBhd = createTestFund('bhd', bhd);
      await repository.saveFund(fundBhd);
      final tBhd = Contribution(
        id: 't2',
        amount: const Money(minorUnits: 1500, currency: bhd),
        date: CalendarDate(2023, 2, 1),
      );
      await repository.saveTransaction('bhd', tBhd);

      final fetchedJpyTxs = await repository.getTransactionsForFund('jpy');
      expect(fetchedJpyTxs[0].amount.currency.metadata.minorUnitExponent, 0);
      expect(fetchedJpyTxs[0].amount.minorUnits, 500);

      final fetchedBhdTxs = await repository.getTransactionsForFund('bhd');
      expect(fetchedBhdTxs[0].amount.currency.metadata.minorUnitExponent, 3);
      expect(fetchedBhdTxs[0].amount.minorUnits, 1500);
    });

    test('CalendarDate round-trip', () async {
      final fund = createTestFund('1', usd);
      await repository.saveFund(fund);

      final t1 = Contribution(
        id: 't1',
        amount: const Money(minorUnits: 100, currency: usd),
        date: CalendarDate(2024, 2, 29),
      ); // Leap year
      final t2 = Contribution(
        id: 't2',
        amount: const Money(minorUnits: 200, currency: usd),
        date: CalendarDate(2023, 2, 28),
      ); // Non-leap
      final t3 = Contribution(
        id: 't3',
        amount: const Money(minorUnits: 300, currency: usd),
        date: CalendarDate(2026, 1, 31),
      ); // Month-end

      await repository.saveTransaction('1', t1);
      await repository.saveTransaction('1', t2);
      await repository.saveTransaction('1', t3);

      final fetchedTxs = await repository.getTransactionsForFund('1');
      expect(fetchedTxs[0].date, CalendarDate(2023, 2, 28)); // 2023 comes first
      expect(fetchedTxs[1].date, CalendarDate(2024, 2, 29));
      expect(fetchedTxs[2].date, CalendarDate(2026, 1, 31));
    });

    test('Ordering regression', () async {
      final fund = createTestFund('1', usd);
      await repository.saveFund(fund);

      final d1 = CalendarDate(2023, 2, 1);
      final d2 = CalendarDate(2023, 2, 2);

      // different dates
      await repository.saveTransaction(
        '1',
        Contribution(
          id: 't3',
          amount: const Money(minorUnits: 10, currency: usd),
          date: d2,
        ),
      );
      await repository.saveTransaction(
        '1',
        Contribution(
          id: 't1',
          amount: const Money(minorUnits: 10, currency: usd),
          date: d1,
        ),
      );

      // same date, different created_at
      await Future.delayed(const Duration(milliseconds: 10));
      await repository.saveTransaction(
        '1',
        Contribution(
          id: 't4',
          amount: const Money(minorUnits: 10, currency: usd),
          date: d1,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 10));
      await repository.saveTransaction(
        '1',
        Contribution(
          id: 't2',
          amount: const Money(minorUnits: 10, currency: usd),
          date: d1,
        ),
      );

      // same date and same created_at, different IDs
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 't0',
              fundId: '1',
              amountMinorUnits: 10,
              date: d1.toString(),
              type: 0,
              createdAt: 1000, // Explicit arbitrary created_at
            ),
          );
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 't0_a',
              fundId: '1',
              amountMinorUnits: 10,
              date: d1.toString(),
              type: 0,
              createdAt: 1000, // Same created_at
            ),
          );

      final txs = await repository.getTransactionsForFund('1');

      expect(txs[0].id, 't0');
      expect(txs[1].id, 't0_a');
      expect(txs[2].id, 't1');
      expect(txs[3].id, 't4');
      expect(txs[4].id, 't2');
      expect(txs[5].id, 't3'); // d2
    });

    test('Atomic rollback when saveFund with transaction fails', () async {
      // Create a fund and transaction that should be saved together
      final fund = createTestFund('rollback-1', usd);

      // Introduce an invalid transaction (e.g., currency mismatch, which throws ConstraintViolation)
      final invalidTx = Contribution(
        id: 'tx-1',
        amount: const Money(
          minorUnits: 1000,
          currency: bdt,
        ), // Mismatch with USD
        date: CalendarDate(2023, 2, 1),
      );

      try {
        await repository.saveFund(fund, transaction: invalidTx);
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<ConstraintViolationException>());
      }

      // Verify complete rollback: neither the fund nor the transaction should exist
      final savedFund = await repository.getFund('rollback-1');
      expect(savedFund, isNull);

      final allTxs = await db.select(db.transactions).get();
      final hasTx1 = allTxs.any((t) => t.id == 'tx-1');
      expect(hasTx1, isFalse);
    });
  });
}
