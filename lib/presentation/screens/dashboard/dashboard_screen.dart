import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sinking_fund/presentation/state/dashboard_notifier.dart';
import 'package:sinking_fund/presentation/state/funds_list_notifier.dart';
import '../../widgets/surfaces/sinking_fund_card.dart';
import '../../widgets/data_display/recent_activity_list.dart';
import '../../widgets/buttons/primary_action_button.dart';
import '../../formatters/money_formatter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: dashboardState.when(
        data: (data) {
          if (data.funds.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text('No funds yet', style: textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Start by creating your first sinking fund.',
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    PrimaryActionButton(
                      label: 'Create Fund',
                      onPressed: () => context.push('/fund/create'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Total Savings', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              ...data.totalSavingsByCurrency.values.map((money) {
                final formatted = const MoneyFormatter().format(money);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    formatted,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    semanticsLabel:
                        'Total savings in ${money.currency.code}: $formatted',
                  ),
                );
              }),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Funds', style: textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Create Fund',
                    onPressed: () => context.push('/fund/create'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...data.funds.map((fundState) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SinkingFundCard(
                    fundState: fundState,
                    onTap: () => context.push('/fund/${fundState.fund.id}'),
                  ),
                );
              }),
              const SizedBox(height: 24),
              if (data.recentActivity.isNotEmpty) ...[
                Text('Recent Activity', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                RecentActivityList(items: data.recentActivity),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to load dashboard', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                PrimaryActionButton(
                  label: 'Retry',
                  onPressed: () {
                    ref.invalidate(fundsListProvider);
                    ref.invalidate(recentActivityProvider);
                    ref.invalidate(dashboardProvider);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
