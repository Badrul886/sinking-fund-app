import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/fund_repository_impl.dart';
import '../../domain/repositories/fund_repository.dart';
import '../../application/ports/identifier_generator.dart';
import '../../application/ports/clock.dart';
import '../../core/platform/secure_random_identifier_generator.dart';
import '../../core/platform/system_clock.dart';
import '../../application/use_cases/fund/create_fund_use_case.dart';
import '../../application/use_cases/fund/get_fund_use_case.dart';
import '../../application/use_cases/fund/get_all_funds_use_case.dart';
import '../../application/use_cases/transaction/add_contribution_use_case.dart';
import '../../application/use_cases/transaction/add_withdrawal_use_case.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../application/ports/onboarding_settings_repository.dart';
import '../../application/use_cases/onboarding/get_onboarding_status_use_case.dart';
import '../../application/use_cases/onboarding/complete_onboarding_use_case.dart';

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Repository Provider
final fundRepositoryProvider = Provider<FundRepository>((ref) {
  return FundRepositoryImpl(ref.watch(databaseProvider));
});

// Ports Providers
final identifierGeneratorProvider = Provider<IdentifierGenerator>((ref) {
  return SecureRandomIdentifierGenerator();
});

final clockProvider = Provider<Clock>((ref) {
  return SystemClock();
});

// Use Cases Providers
final createFundUseCaseProvider = Provider<CreateFundUseCase>((ref) {
  return CreateFundUseCase(
    ref.watch(fundRepositoryProvider),
    ref.watch(identifierGeneratorProvider),
  );
});

final getFundUseCaseProvider = Provider<GetFundUseCase>((ref) {
  return GetFundUseCase(ref.watch(fundRepositoryProvider));
});

final getAllFundsUseCaseProvider = Provider<GetAllFundsUseCase>((ref) {
  return GetAllFundsUseCase(ref.watch(fundRepositoryProvider));
});

final addContributionUseCaseProvider = Provider<AddContributionUseCase>((ref) {
  return AddContributionUseCase(
    ref.watch(fundRepositoryProvider),
    ref.watch(getFundUseCaseProvider),
    ref.watch(identifierGeneratorProvider),
  );
});

final addWithdrawalUseCaseProvider = Provider<AddWithdrawalUseCase>((ref) {
  return AddWithdrawalUseCase(
    ref.watch(fundRepositoryProvider),
    ref.watch(getFundUseCaseProvider),
    ref.watch(identifierGeneratorProvider),
  );
});

final onboardingSettingsRepositoryProvider = Provider<OnboardingSettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(databaseProvider));
});

final getOnboardingStatusUseCaseProvider = Provider<GetOnboardingStatusUseCase>((ref) {
  return GetOnboardingStatusUseCase(ref.watch(onboardingSettingsRepositoryProvider));
});

final completeOnboardingUseCaseProvider = Provider<CompleteOnboardingUseCase>((ref) {
  return CompleteOnboardingUseCase(ref.watch(onboardingSettingsRepositoryProvider));
});
