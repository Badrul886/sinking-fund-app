import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/transaction.dart';
import 'package:sinking_fund/domain/repositories/fund_repository.dart';
import 'package:sinking_fund/application/ports/identifier_generator.dart';
import 'package:sinking_fund/data/exceptions.dart';

class FakeFundRepository implements FundRepository {
  final Map<String, Fund> funds = {};
  final Map<String, List<Transaction>> transactions = {};

  bool throwOnSave = false;

  @override
  Future<void> saveFund(Fund fund) async {
    if (throwOnSave) {
      throw const ConstraintViolationException('Mock constraint error');
    }
    funds[fund.id] = fund;
    if (!transactions.containsKey(fund.id)) {
      transactions[fund.id] = [];
    }
  }

  @override
  Future<Fund?> getFund(String id) async {
    return funds[id];
  }

  @override
  Future<List<Fund>> getAllFunds() async {
    return funds.values.toList();
  }

  @override
  Future<void> deleteFund(String id) async {
    funds.remove(id);
    transactions.remove(id);
  }

  @override
  Future<void> saveTransaction(String fundId, Transaction transaction) async {
    if (throwOnSave) {
      throw const ConstraintViolationException('Mock constraint error');
    }
    if (!funds.containsKey(fundId)) {
      throw const RecordNotFoundException('Fund not found');
    }
    if (!transactions.containsKey(fundId)) {
      transactions[fundId] = [];
    }
    transactions[fundId]!.add(transaction);
  }

  @override
  Future<List<Transaction>> getTransactionsForFund(String fundId) async {
    return transactions[fundId] ?? [];
  }
}

class FakeIdentifierGenerator implements IdentifierGenerator {
  String idToGenerate = 'fake-id';

  @override
  String generate() => idToGenerate;
}
