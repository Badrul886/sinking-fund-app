import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/fund_detail_notifier.dart';
import '../../formatters/money_formatter.dart';
import '../../formatters/date_formatter.dart';
import '../../providers/dependencies.dart';
import '../../widgets/charts/trajectory_chart.dart';
import '../../widgets/lists/transaction_tile.dart';
import '../../widgets/data_display/amount_display.dart';
import '../../widgets/data_display/progress_visualizer.dart';
import '../../../domain/fund.dart';
import '../../../application/errors/application_error.dart';
import '../../../domain/money.dart';
import '../../widgets/inputs/transaction_bottom_sheet.dart';

class FundDetailScreen extends ConsumerWidget {
  final String fundId;

  const FundDetailScreen({super.key, required this.fundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fundDetailProvider(fundId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go('/fund/$fundId/edit');
            },
            tooltip: 'Edit Fund',
          ),
        ],
      ),
      body: state.when(
        data: (detailState) {
          final fund = detailState.fundState.fund;
          final calcResult = detailState.fundState.calculationResult;
          final clock = ref.watch(clockProvider);
          final dateFormatter = DateFormatter(clock: clock);

          final theme = Theme.of(context);

          final isOverfunded = calcResult.status == FundStatus.overfunded;

          final statusDetails = _getStatusDetails(calcResult.status, theme);
          final statusColor = statusDetails.color;
          final statusText = statusDetails.text;

          // Deterministic sort for transactions: date ASC -> created_at ASC -> id ASC
          // (Wait, Domain doesn't have created_at yet? If not, we just sort by date ASC -> id ASC.
          // The transactions are already provided by UseCase exactly as queried from repository.
          // The query should be sorted, but let's enforce it here just in case, or trust the Application layer.
          // The instruction: "Use the deterministic existing order... Do not re-query or resort in Presentation."
          // So I will just use `detailState.fundState.transactions.reversed` to show newest first?
          // Actually, "Preserve deterministic order... Do not re-query or resort in Presentation."
          // Okay, I'll just use the list as provided (which is date ASC). To show latest first, we can render from the end or just render as is.)
          final transactions = detailState.fundState.transactions.reversed
              .toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(fund.name, style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    AmountDisplay(
                      amount: calcResult.currentBalance,
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${const MoneyFormatter().format(fund.targetAmount)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProgressVisualizer(progress: calcResult.progress),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${dateFormatter.getDaysRemaining(fund.targetDate)} days left',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 26 / 255),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 77 / 255),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: statusColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  statusText,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Required: ${const MoneyFormatter().format(calcResult.requiredContribution)} / ${fund.contributionFrequency.name}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: calcResult.status == FundStatus.behind
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isOverfunded) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Surplus: ${const MoneyFormatter().format(Money(minorUnits: calcResult.currentBalance.minorUnits - fund.targetAmount.minorUnits, currency: fund.targetAmount.currency))}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Trajectory', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    if (detailState.fundState.transactions.isEmpty &&
                        calcResult.status == FundStatus.notStarted)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('Ready to start saving.'),
                        ),
                      )
                    else
                      TrajectoryChart(
                        startDate: fund.startDate,
                        targetDate: fund.targetDate,
                        currentDate: clock.today(),
                        targetAmount: fund.targetAmount,
                        trajectory: detailState.trajectory,
                        semanticsLabel: 'Trajectory Chart',
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Transaction History',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
              if (transactions.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No transactions yet.')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return TransactionTile(transaction: transactions[index]);
                  }, childCount: transactions.length),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          if (error is FundNotFoundError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('This fund no longer exists.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Return to Dashboard'),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('An error occurred: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(fundDetailProvider(fundId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.isLoading || state.hasError
                      ? null
                      : () {
                          final fundState = state.asData?.value.fundState;
                          if (fundState != null) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => TransactionBottomSheet(
                                fundId: fundId,
                                currency: fundState.fund.targetAmount.currency,
                                type: TransactionType.contribution,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Contribution'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(
                      0,
                      48,
                    ), // Accessbility minimum touch target
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isLoading || state.hasError
                      ? null
                      : () {
                          final fundState = state.asData?.value.fundState;
                          if (fundState != null) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => TransactionBottomSheet(
                                fundId: fundId,
                                currency: fundState.fund.targetAmount.currency,
                                type: TransactionType.withdrawal,
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.remove),
                  label: const Text('Withdraw'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusDetails _getStatusDetails(FundStatus status, ThemeData theme) {
    switch (status) {
      case FundStatus.onTrack:
        return _StatusDetails(
          text: "You're on track.",
          color: theme.colorScheme.primary,
        );
      case FundStatus.ahead:
        return _StatusDetails(
          text: "You're ahead of schedule.",
          color: Colors.green,
        );
      case FundStatus.behind:
        return _StatusDetails(
          text: "You're behind schedule.",
          color: Colors.orange,
        );
      case FundStatus.complete:
        return _StatusDetails(text: "Fund complete!", color: Colors.green);
      case FundStatus.overfunded:
        return _StatusDetails(text: "Fund overfunded!", color: Colors.green);
      case FundStatus.deadlinePassed:
        return _StatusDetails(
          text: "Target date has passed.",
          color: Colors.red,
        );
      case FundStatus.notStarted:
        return _StatusDetails(
          text: "Ready to start saving.",
          color: theme.colorScheme.primary,
        );
    }
  }
}

class _StatusDetails {
  final String text;
  final Color color;

  _StatusDetails({required this.text, required this.color});
}
