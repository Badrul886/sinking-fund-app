import 'package:flutter/material.dart';
import '../../../application/models/fund_state.dart';
import '../data_display/amount_display.dart';
import '../data_display/progress_visualizer.dart';
import '../surfaces/app_card.dart';
import '../../formatters/money_formatter.dart';
import '../../formatters/date_formatter.dart';
import '../../theme/app_typography.dart';
import '../../providers/dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SinkingFundCard extends ConsumerWidget {
  final FundState fundState;
  final VoidCallback onTap;

  const SinkingFundCard({
    super.key,
    required this.fundState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final dateFormatter = DateFormatter(clock: ref.watch(clockProvider));
    final daysRemaining = dateFormatter.getDaysRemaining(fundState.fund.targetDate);

    final targetAmountText = const MoneyFormatter().format(
      fundState.fund.targetAmount,
    );
    final requiredContributionText = const MoneyFormatter().format(
      fundState.calculationResult.requiredContribution,
    );

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings_outlined, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fundState.fund.name,
                  style: textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AmountDisplay(
            amount: fundState.calculationResult.currentBalance,
            style: AppTypography.financialLarge(theme.colorScheme.onSurface),
          ),
          Text(
            'of $targetAmountText',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ProgressVisualizer(
            progress: fundState.calculationResult.progress,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$requiredContributionText / ${fundState.fund.contributionFrequency.name}',
                style: textTheme.bodySmall,
              ),
              Text(
                '$daysRemaining days left',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
