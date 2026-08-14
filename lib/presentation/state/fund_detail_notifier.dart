import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/models/fund_state.dart';
import '../../domain/money.dart';
import '../../domain/calendar_date.dart';
import '../providers/dependencies.dart';
import 'funds_list_notifier.dart';

final fundDetailProvider =
    AsyncNotifierProvider.family<FundDetailNotifier, FundState, String>(
      FundDetailNotifier.new,
    );

class FundDetailNotifier extends AsyncNotifier<FundState> {
  final String fundId;
  FundDetailNotifier(this.fundId);

  @override
  Future<FundState> build() async {
    final useCase = ref.watch(getFundUseCaseProvider);
    final clock = ref.watch(clockProvider);
    return useCase.execute(fundId, clock.today());
  }

  // Mutation: Add Contribution
  Future<void> addContribution({
    required Money amount,
    required CalendarDate date,
  }) async {
    final useCase = ref.read(addContributionUseCaseProvider);
    final clock = ref.read(clockProvider);
    await useCase.execute(
      fundId: fundId,
      amount: amount,
      date: date,
      currentDate: clock.today(),
    );
    // Invalidate self and list provider to refresh data
    ref.invalidateSelf();
    ref.invalidate(fundsListProvider);
  }

  // Mutation: Add Withdrawal
  Future<void> addWithdrawal({
    required Money amount,
    required CalendarDate date,
  }) async {
    final useCase = ref.read(addWithdrawalUseCaseProvider);
    final clock = ref.read(clockProvider);
    await useCase.execute(
      fundId: fundId,
      amount: amount,
      date: date,
      currentDate: clock.today(),
    );
    // Invalidate self and list provider to refresh data
    ref.invalidateSelf();
    ref.invalidate(fundsListProvider);
  }
}
