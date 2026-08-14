import 'package:sinking_fund/application/ports/onboarding_settings_repository.dart';
import 'package:sinking_fund/data/local/database/app_database.dart';

class SettingsRepositoryImpl implements OnboardingSettingsRepository {
  final AppDatabase _db;

  static const _onboardingKey = 'has_completed_onboarding';

  const SettingsRepositoryImpl(this._db);

  @override
  Future<bool> hasCompletedOnboarding() async {
    final setting = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(_onboardingKey))).getSingleOrNull();
    return setting?.value == 'true';
  }

  @override
  Future<void> setOnboardingCompleted() async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingData(key: _onboardingKey, value: 'true'),
        );
  }
}
