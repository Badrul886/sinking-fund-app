import 'package:drift/drift.dart';
import '../../domain/fund.dart';
import '../../domain/transaction.dart';
import '../../application/ports/onboarding_repository.dart';
import '../local/database/app_database.dart';
import '../exceptions.dart';
import '../local/database/fund_insertion_helper.dart';

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
        // 1 & 2. Persist Fund and Initial Contribution atomically
        await _db.insertFundAndTransaction(
          fund,
          transaction: initialTransaction,
        );

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
