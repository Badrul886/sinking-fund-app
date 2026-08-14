import 'package:drift/drift.dart';
import '../../domain/fund.dart';
import '../../domain/transaction.dart';
import '../../application/ports/onboarding_repository.dart';
import '../local/database/app_database.dart';
import '../exceptions.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final AppDatabase _db;

  OnboardingRepositoryImpl(this._db);

  @override
  Future<void> completeOnboarding(
    Fund fund,
    Transaction? initialTransaction,
  ) async {
    try {
      await _db.transaction(() async {
        // 1. Persist Fund
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
              mode: InsertMode.insertOrReplace,
            );

        // 2. Persist Initial Contribution if present
        if (initialTransaction != null) {
          final type = initialTransaction is Contribution ? 0 : 1;
          await _db
              .into(_db.transactions)
              .insert(
                TransactionsCompanion.insert(
                  id: initialTransaction.id,
                  fundId: fund.id,
                  amountMinorUnits: initialTransaction.amount.minorUnits,
                  date: initialTransaction.date.toString(),
                  note: Value(initialTransaction.note),
                  type: type,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                ),
                mode: InsertMode.insertOrReplace,
              );
        }

        // 3. Mark Onboarding Complete
        await _db
            .into(_db.appSettings)
            .insert(
              const AppSettingsCompanion(
                key: Value('has_completed_onboarding'),
                value: Value('true'),
              ),
              mode: InsertMode.insertOrReplace,
            );
      });
    } catch (e) {
      if (e is DataException) rethrow;
      throw DatabaseFailureException(e.toString());
    }
  }
}
