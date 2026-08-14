import 'package:drift/drift.dart';
import '../../domain/transaction.dart';
import '../../domain/money.dart';
import '../../domain/currency.dart';
import '../../domain/calendar_date.dart';
import '../../application/ports/recent_activity_repository.dart';
import '../../application/models/recent_activity_item.dart';
import '../local/database/app_database.dart';
import '../exceptions.dart';

class RecentActivityRepositoryImpl implements RecentActivityRepository {
  final AppDatabase _db;

  const RecentActivityRepositoryImpl(this._db);

  @override
  Future<List<RecentActivityItem>> getRecentActivity({int limit = 5}) async {
    try {
      final query =
          _db.select(_db.transactions).join([
              innerJoin(
                _db.funds,
                _db.funds.id.equalsExp(_db.transactions.fundId),
              ),
            ])
            ..orderBy([
              OrderingTerm(
                expression: _db.transactions.date,
                mode: OrderingMode.desc,
              ),
              OrderingTerm(
                expression: _db.transactions.createdAt,
                mode: OrderingMode.desc,
              ),
              OrderingTerm(
                expression: _db.transactions.id,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(limit);

      final rows = await query.get();

      return rows.map((row) {
        final txData = row.readTable(_db.transactions);
        final fundData = row.readTable(_db.funds);

        final currency = Currency(fundData.currencyCode);
        final amount = Money(
          minorUnits: txData.amountMinorUnits,
          currency: currency,
        );

        final parts = txData.date.split('-');
        final date = CalendarDate(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );

        Transaction transaction;
        if (txData.type == 0) {
          transaction = Contribution(
            id: txData.id,
            amount: amount,
            date: date,
            note: txData.note,
          );
        } else {
          transaction = Withdrawal(
            id: txData.id,
            amount: amount,
            date: date,
            note: txData.note,
          );
        }

        return RecentActivityItem(
          transaction: transaction,
          fundName: fundData.name,
          fundCurrency: currency,
        );
      }).toList();
    } on DataException {
      rethrow;
    } catch (e) {
      throw DatabaseFailureException(e.toString());
    }
  }
}
