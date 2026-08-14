import 'package:drift/drift.dart';
import '../../../domain/fund.dart';
import '../../../domain/transaction.dart';
import 'app_database.dart';
import '../../exceptions.dart';

extension FundInsertionHelper on AppDatabase {
  /// Inserts a Fund and an optional Transaction into the database.
  /// This method does NOT open a transaction boundary itself.
  /// It is intended to be called from within an existing transaction boundary.
  Future<void> insertFundAndTransaction(
    Fund fund, {
    Transaction? transaction,
  }) async {
    await into(funds).insert(
      FundsCompanion.insert(
        id: fund.id,
        name: fund.name,
        targetMinorUnits: fund.targetAmount.minorUnits,
        currencyCode: fund.targetAmount.currency.code,
        startDate: fund.startDate.toString(),
        targetDate: fund.targetDate.toString(),
        contributionFrequency: fund.contributionFrequency.index,
      ),
      mode: InsertMode.insertOrReplace,
    );

    if (transaction != null) {
      if (transaction.amount.currency.code != fund.targetAmount.currency.code) {
        throw ConstraintViolationException(
          'Currency mismatch: Transaction is ${transaction.amount.currency.code}, Fund is ${fund.targetAmount.currency.code}',
        );
      }

      final type = transaction is Contribution ? 0 : 1;
      await into(transactions).insert(
        TransactionsCompanion.insert(
          id: transaction.id,
          fundId: fund.id,
          amountMinorUnits: transaction.amount.minorUnits,
          date: transaction.date.toString(),
          note: Value(transaction.note),
          type: type,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
        mode: InsertMode.insertOrReplace,
      );
    }
  }
}
