import '../fund.dart';
import '../transaction.dart';

abstract class FundRepository {
  Future<void> saveFund(Fund fund);
  Future<Fund?> getFund(String id);
  Future<List<Fund>> getAllFunds();
  Future<void> deleteFund(String id);

  Future<void> saveTransaction(String fundId, Transaction transaction);
  Future<List<Transaction>> getTransactionsForFund(String fundId);
}
