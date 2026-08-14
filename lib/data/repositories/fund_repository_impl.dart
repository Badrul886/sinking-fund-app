import 'package:drift/drift.dart';
import '../../domain/fund.dart';
import '../../domain/transaction.dart';
import '../../domain/money.dart';
import '../../domain/currency.dart';
import '../../domain/calendar_date.dart';
import '../../domain/schedule.dart';
import '../../domain/repositories/fund_repository.dart';
import '../local/database/app_database.dart';
import '../exceptions.dart';
import '../local/database/fund_insertion_helper.dart';

class FundRepositoryImpl implements FundRepository {
  final AppDatabase _db;

  FundRepositoryImpl(this._db);

  @override
  Future<void> saveFund(Fund fund, {Transaction? transaction}) async {
    try {
      await _db.transaction(() async {
        await _db.insertFundAndTransaction(fund, transaction: transaction);
      });
    } catch (e) {
      if (e is DataException) rethrow;
      throw DatabaseFailureException(e.toString());
    }
  }

  @override
  Future<void> updateFund(Fund fund) async {
    try {
      final existingFundRow = await (_db.select(
        _db.funds,
      )..where((t) => t.id.equals(fund.id))).getSingleOrNull();
      if (existingFundRow == null) {
        throw RecordNotFoundException('Fund ${fund.id} not found');
      }

      await _db
          .into(_db.funds)
          .insert(
            FundsCompanion.insert(
              id: fund.id,
              name: fund.name,
              targetMinorUnits: fund.targetAmount.minorUnits,
              currencyCode: fund.targetAmount.currency.code,
              startDate: fund.startDate.toString(),
              targetDate: fund.targetDate.toString(),
              contributionFrequency: fund.contributionFrequency.index,
            ),
            mode: InsertMode.replace,
          );
    } catch (e) {
      if (e is DataException) rethrow;
      throw DatabaseFailureException(e.toString());
    }
  }

  @override
  Future<Fund?> getFund(String id) async {
    try {
      final query = _db.select(_db.funds)..where((t) => t.id.equals(id));
      final row = await query.getSingleOrNull();
      if (row == null) return null;
      return _mapFund(row);
    } catch (e) {
      throw DatabaseFailureException(e.toString());
    }
  }

  @override
  Future<List<Fund>> getAllFunds() async {
    try {
      final rows = await _db.select(_db.funds).get();
      return rows.map(_mapFund).toList();
    } catch (e) {
      throw DatabaseFailureException(e.toString());
    }
  }

  @override
  Future<void> deleteFund(String id) async {
    try {
      await (_db.delete(_db.funds)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw DatabaseFailureException(e.toString());
    }
  }

  @override
  Future<void> saveTransaction(String fundId, Transaction transaction) async {
    try {
      final fundRow = await (_db.select(
        _db.funds,
      )..where((t) => t.id.equals(fundId))).getSingleOrNull();
      if (fundRow == null) {
        throw RecordNotFoundException('Fund $fundId not found');
      }

      if (transaction.amount.currency.code != fundRow.currencyCode) {
        throw ConstraintViolationException(
          'Currency mismatch: Transaction is ${transaction.amount.currency.code}, Fund is ${fundRow.currencyCode}',
        );
      }

      final type = transaction is Contribution ? 0 : 1;

      await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: transaction.id,
              fundId: fundId,
              amountMinorUnits: transaction.amount.minorUnits,
              date: transaction.date.toString(),
              note: Value(transaction.note),
              type: type,
              createdAt: DateTime.now().millisecondsSinceEpoch,
            ),
            mode: InsertMode.insertOrReplace,
          );
    } on DataException {
      rethrow;
    } catch (e) {
      throw DatabaseFailureException(e.toString());
    }
  }

  @override
  Future<List<Transaction>> getTransactionsForFund(String fundId) async {
    try {
      final fundRow = await (_db.select(
        _db.funds,
      )..where((t) => t.id.equals(fundId))).getSingleOrNull();
      if (fundRow == null) {
        throw RecordNotFoundException('Fund $fundId not found');
      }
      final currency = Currency(fundRow.currencyCode);

      final query = _db.select(_db.transactions)
        ..where((t) => t.fundId.equals(fundId))
        ..orderBy([
          (t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc),
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
        ]);

      final rows = await query.get();

      return rows.map((row) {
        final amount = Money(
          minorUnits: row.amountMinorUnits,
          currency: currency,
        );
        final parts = row.date.split('-');
        final date = CalendarDate(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        if (row.type == 0) {
          return Contribution(
            id: row.id,
            amount: amount,
            date: date,
            note: row.note,
          );
        } else {
          return Withdrawal(
            id: row.id,
            amount: amount,
            date: date,
            note: row.note,
          );
        }
      }).toList();
    } on DataException {
      rethrow;
    } catch (e) {
      throw DatabaseFailureException(e.toString());
    }
  }

  Fund _mapFund(FundData row) {
    final currency = Currency(row.currencyCode);
    final targetAmount = Money(
      minorUnits: row.targetMinorUnits,
      currency: currency,
    );

    final startParts = row.startDate.split('-');
    final start = CalendarDate(
      int.parse(startParts[0]),
      int.parse(startParts[1]),
      int.parse(startParts[2]),
    );

    final targetParts = row.targetDate.split('-');
    final target = CalendarDate(
      int.parse(targetParts[0]),
      int.parse(targetParts[1]),
      int.parse(targetParts[2]),
    );

    return Fund(
      id: row.id,
      name: row.name,
      targetAmount: targetAmount,
      startDate: start,
      targetDate: target,
      contributionFrequency:
          ContributionFrequency.values[row.contributionFrequency],
    );
  }
}
