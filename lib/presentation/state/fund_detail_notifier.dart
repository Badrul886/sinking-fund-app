import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/models/fund_detail_state.dart';
import '../../domain/money.dart';
import '../../domain/calendar_date.dart';
import '../../domain/schedule.dart';
import '../providers/dependencies.dart';
import 'funds_list_notifier.dart';

final fundDetailProvider =
    AsyncNotifierProvider.family<FundDetailNotifier, FundDetailState, String>(
      FundDetailNotifier.new,
    );

class FundDetailNotifier extends AsyncNotifier<FundDetailState> {
  final String fundId;
  FundDetailNotifier(this.fundId);

  @override
  Future<FundDetailState> build() async {
    final useCase = ref.watch(getFundDetailUseCaseProvider);
    return useCase.execute(fundId);
  }

  // Mutation: Add Contribution
  Future<void> addContribution({
    required Money amount,
    required CalendarDate date,
    String? note,
  }) async {
    final useCase = ref.read(addContributionUseCaseProvider);
    final clock = ref.read(clockProvider);
    await useCase.execute(
      fundId: fundId,
      amount: amount,
      date: date,
      currentDate: clock.today(),
      note: note,
    );
    // Invalidate self and list provider to refresh data
    ref.invalidateSelf();
    ref.invalidate(fundsListProvider);
  }

  // Mutation: Add Withdrawal
  Future<void> addWithdrawal({
    required Money amount,
    required CalendarDate date,
    String? note,
  }) async {
    final useCase = ref.read(addWithdrawalUseCaseProvider);
    final clock = ref.read(clockProvider);
    await useCase.execute(
      fundId: fundId,
      amount: amount,
      date: date,
      currentDate: clock.today(),
      note: note,
    );
    // Invalidate self and list provider to refresh data
    ref.invalidateSelf();
    ref.invalidate(fundsListProvider);
  }

  // Mutation: Update Fund
  Future<void> updateFund({
    String? name,
    Money? targetAmount,
    CalendarDate? targetDate,
    ContributionFrequency? contributionFrequency,
  }) async {
    final useCase = ref.read(updateFundUseCaseProvider);
    await useCase.execute(
      id: fundId,
      name: name,
      targetAmount: targetAmount,
      targetDate: targetDate,
      contributionFrequency: contributionFrequency,
    );
    // Invalidate self and list provider to refresh data
    ref.invalidateSelf();
    ref.invalidate(fundsListProvider);
  }
}
