import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/models/fund_state.dart';
import '../../domain/money.dart';
import '../../domain/calendar_date.dart';
import '../../domain/schedule.dart';
import '../providers/dependencies.dart';

final fundsListProvider =
    AsyncNotifierProvider<FundsListNotifier, List<FundState>>(
      FundsListNotifier.new,
    );

class FundsListNotifier extends AsyncNotifier<List<FundState>> {
  @override
  Future<List<FundState>> build() async {
    final useCase = ref.watch(getAllFundsUseCaseProvider);
    final clock = ref.watch(clockProvider);
    return useCase.execute(clock.today());
  }

  // Mutation: Create Fund
  Future<void> createFund({
    required String name,
    required Money targetAmount,
    required CalendarDate startDate,
    required CalendarDate targetDate,
    required ContributionFrequency contributionFrequency,
  }) async {
    final useCase = ref.read(createFundUseCaseProvider);
    await useCase.execute(
      name: name,
      targetAmount: targetAmount,
      startDate: startDate,
      targetDate: targetDate,
      contributionFrequency: contributionFrequency,
    );
    // Invalidate to trigger rebuild
    ref.invalidateSelf();
  }
}
