import '../../domain/fund.dart';
import '../../domain/transaction.dart';
import '../../domain/fund_calculator.dart';

class FundState {
  final Fund fund;
  final List<Transaction> transactions;
  final FundCalculationResult calculationResult;

  const FundState({
    required this.fund,
    required this.transactions,
    required this.calculationResult,
  });
}
