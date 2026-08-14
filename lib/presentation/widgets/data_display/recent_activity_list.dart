import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/models/recent_activity_item.dart';
import '../../../domain/transaction.dart';
import '../../formatters/money_formatter.dart';
import '../../formatters/date_formatter.dart';
import '../../providers/dependencies.dart';

class RecentActivityList extends ConsumerWidget {
  final List<RecentActivityItem> items;

  const RecentActivityList({super.key, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = DateFormatter(clock: ref.watch(clockProvider));

    return Column(
      children: items.map((item) {
        final tx = item.transaction;
        final isContribution = tx is Contribution;
        final icon = isContribution ? Icons.arrow_downward : Icons.arrow_upward;
        final color = isContribution ? Colors.green : Colors.red;
        final sign = isContribution ? '+' : '-';

        final formattedDate = formatter.formatRelative(tx.date);
        final subtitleText = (tx.note != null && tx.note!.isNotEmpty)
            ? '$formattedDate • ${tx.note}'
            : formattedDate;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(item.fundName),
          subtitle: Text(subtitleText),
          trailing: Text(
            '$sign${const MoneyFormatter().format(tx.amount)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }
}
