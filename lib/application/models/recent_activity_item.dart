import '../../domain/transaction.dart';
import '../../domain/currency.dart';

class RecentActivityItem {
  final Transaction transaction;
  final String fundName;
  final Currency fundCurrency;

  const RecentActivityItem({
    required this.transaction,
    required this.fundName,
    required this.fundCurrency,
  });
}
