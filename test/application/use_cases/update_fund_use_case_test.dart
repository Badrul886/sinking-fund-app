import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/application/use_cases/fund/update_fund_use_case.dart';
import 'package:sinking_fund/application/errors/application_error.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/repositories/fund_repository.dart';
import 'package:sinking_fund/domain/transaction.dart';

class MockFundRepository implements FundRepository {
  final Map<String, Fund> _funds = {};

  @override
  Future<List<Fund>> getAllFunds() async => _funds.values.toList();

  @override
  Future<Fund?> getFund(String id) async => _funds[id];

  @override
  Future<void> saveFund(Fund fund, {Transaction? transaction}) async {
    _funds[fund.id] = fund;
  }

  @override
  Future<void> updateFund(Fund fund) async {
    _funds[fund.id] = fund;
  }

  @override
  Future<void> deleteFund(String id) async {
    _funds.remove(id);
  }

  @override
  Future<List<Transaction>> getTransactionsForFund(String fundId) async => [];

  @override
  Future<void> saveTransaction(String fundId, Transaction transaction) async {}
}

void main() {
  final usd = Currency('USD');
  final bdt = Currency('BDT');
  late MockFundRepository repository;
  late UpdateFundUseCase useCase;

  setUp(() {
    repository = MockFundRepository();
    useCase = UpdateFundUseCase(repository);
  });

  test('successfully updates fund name', () async {
    final originalFund = Fund(
      id: 'fund1',
      name: 'Original',
      targetAmount: Money(minorUnits: 1000, currency: usd),
      startDate: CalendarDate(2025, 1, 1),
      targetDate: CalendarDate(2025, 12, 1),
      contributionFrequency: ContributionFrequency.monthly,
    );
    await repository.saveFund(originalFund);

    final updatedFund = await useCase.execute(id: 'fund1', name: 'New Name');

    expect(updatedFund.name, 'New Name');
    expect(updatedFund.targetAmount.minorUnits, 1000);
  });

  test('successfully updates financial fields', () async {
    final originalFund = Fund(
      id: 'fund1',
      name: 'Original',
      targetAmount: Money(minorUnits: 1000, currency: usd),
      startDate: CalendarDate(2025, 1, 1),
      targetDate: CalendarDate(2025, 12, 1),
      contributionFrequency: ContributionFrequency.monthly,
    );
    await repository.saveFund(originalFund);

    final updatedFund = await useCase.execute(
      id: 'fund1',
      targetAmount: Money(minorUnits: 2000, currency: usd),
      targetDate: CalendarDate(2026, 1, 1),
      contributionFrequency: ContributionFrequency.weekly,
    );

    expect(updatedFund.targetAmount.minorUnits, 2000);
    expect(updatedFund.targetDate, CalendarDate(2026, 1, 1));
    expect(updatedFund.contributionFrequency, ContributionFrequency.weekly);
  });

  test('rejects currency change', () async {
    final originalFund = Fund(
      id: 'fund1',
      name: 'Original',
      targetAmount: Money(minorUnits: 1000, currency: usd),
      startDate: CalendarDate(2025, 1, 1),
      targetDate: CalendarDate(2025, 12, 1),
      contributionFrequency: ContributionFrequency.monthly,
    );
    await repository.saveFund(originalFund);

    expect(
      () => useCase.execute(
        id: 'fund1',
        targetAmount: Money(minorUnits: 1000, currency: bdt),
      ),
      throwsA(isA<InvalidFundDataError>()),
    );
  });

  test('rejects invalid target date (before start date)', () async {
    final originalFund = Fund(
      id: 'fund1',
      name: 'Original',
      targetAmount: Money(minorUnits: 1000, currency: usd),
      startDate: CalendarDate(2025, 6, 1),
      targetDate: CalendarDate(2025, 12, 1),
      contributionFrequency: ContributionFrequency.monthly,
    );
    await repository.saveFund(originalFund);

    expect(
      () => useCase.execute(
        id: 'fund1',
        targetDate: CalendarDate(2025, 1, 1), // Before start date
      ),
      throwsA(isA<InvalidFundDataError>()),
    );
  });

  test('throws if fund not found', () async {
    expect(
      () => useCase.execute(id: 'non-existent'),
      throwsA(isA<FundNotFoundError>()),
    );
  });
}
