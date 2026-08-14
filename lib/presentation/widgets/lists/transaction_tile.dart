import 'package:flutter/material.dart';
import '../../../domain/transaction.dart';
import '../../formatters/money_formatter.dart';
import '../../formatters/date_formatter.dart';
import '../../providers/dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isContribution = transaction is Contribution;

    final icon = isContribution ? Icons.arrow_upward : Icons.arrow_downward;
    final iconColor = isContribution ? Colors.green : Colors.red;

    final sign = isContribution ? '+' : '-';
    final amountText = const MoneyFormatter().format(transaction.amount);

    final dateFormatter = DateFormatter(clock: ref.watch(clockProvider));
    final dateText = dateFormatter.formatAbsolute(transaction.date);

    final typeFallback = isContribution ? 'Contribution' : 'Withdrawal';
    final note = transaction.note ?? typeFallback;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 26 / 255),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(note),
      subtitle: Text(dateText),
      trailing: Text(
        '$sign$amountText',
        style: theme.textTheme.titleMedium?.copyWith(
          color: iconColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
