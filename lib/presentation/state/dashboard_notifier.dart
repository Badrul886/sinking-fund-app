import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/models/fund_state.dart';
import '../../application/models/recent_activity_item.dart';
import '../../domain/currency.dart';
import '../../domain/money.dart';
import 'funds_list_notifier.dart';
import '../providers/dependencies.dart';

class DashboardData {
  final List<FundState> funds;
  final List<RecentActivityItem> recentActivity;
  final Map<Currency, Money> totalSavingsByCurrency;

  const DashboardData({
    required this.funds,
    required this.recentActivity,
    required this.totalSavingsByCurrency,
  });
}

final recentActivityProvider =
    FutureProvider.autoDispose<List<RecentActivityItem>>((ref) async {
      final useCase = ref.watch(getRecentActivityUseCaseProvider);
      return useCase.execute(limit: 5);
    });

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((
  ref,
) async {
  final funds = await ref.watch(fundsListProvider.future);
  final recentActivity = await ref.watch(recentActivityProvider.future);

  final savingsByCurrency = <Currency, int>{};
  for (final fundState in funds) {
    final currency = fundState.calculationResult.currentBalance.currency;
    final balanceMinor = fundState.calculationResult.currentBalance.minorUnits;
    savingsByCurrency[currency] =
        (savingsByCurrency[currency] ?? 0) + balanceMinor;
  }

  final totalSavingsByCurrency = savingsByCurrency.map(
    (currency, minorUnits) =>
        MapEntry(currency, Money(minorUnits: minorUnits, currency: currency)),
  );

  return DashboardData(
    funds: funds,
    recentActivity: recentActivity,
    totalSavingsByCurrency: totalSavingsByCurrency,
  );
});
