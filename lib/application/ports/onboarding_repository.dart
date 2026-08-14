import '../../domain/fund.dart';
import '../../domain/transaction.dart';

abstract class OnboardingRepository {
  Future<void> completeOnboarding(Fund fund, Transaction? initialTransaction);
}
