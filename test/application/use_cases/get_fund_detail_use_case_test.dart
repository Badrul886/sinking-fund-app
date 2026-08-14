import 'package:flutter_test/flutter_test.dart';
import 'package:sinking_fund/application/models/fund_detail_state.dart';
import 'package:sinking_fund/application/use_cases/fund/get_fund_detail_use_case.dart';
import 'package:sinking_fund/domain/fund.dart';
import 'package:sinking_fund/domain/money.dart';
import 'package:sinking_fund/domain/currency.dart';
import 'package:sinking_fund/domain/calendar_date.dart';
import 'package:sinking_fund/domain/schedule.dart';
import 'package:sinking_fund/domain/trajectory.dart';
import 'package:sinking_fund/application/errors/application_error.dart';

import '../fakes.dart';
import 'package:sinking_fund/application/ports/clock.dart';

class FakeClock implements Clock {
  CalendarDate currentDate = CalendarDate(2026, 1, 1);
  @override
  CalendarDate today() => currentDate;
}

void main() {
  late FakeFundRepository repository;
  late FakeClock clock;
  late GetFundDetailUseCase useCase;

  setUp(() {
    repository = FakeFundRepository();
    clock = FakeClock();
    useCase = GetFundDetailUseCase(repository, clock);
  });

  group('GetFundDetailUseCase', () {
    test('successfully builds FundDetailState with Trajectory', () async {
      final target = Money(minorUnits: 100000, currency: Currency('USD'));
      final fund = Fund(
        id: 'fund-detail-1',
        name: 'Test Detail',
        targetAmount: target,
        startDate: CalendarDate(2026, 1, 1),
        targetDate: CalendarDate(2026, 12, 31),
        contributionFrequency: ContributionFrequency.monthly,
      );

      await repository.saveFund(fund);

      clock.currentDate = CalendarDate(2026, 6, 15);

      final result = await useCase.execute('fund-detail-1');

      expect(result, isA<FundDetailState>());
      expect(result.fundState.fund, fund);
      expect(result.fundState.transactions, isEmpty);
      expect(result.fundState.calculationResult, isNotNull);

      expect(result.trajectory, isA<Trajectory>());
      expect(result.trajectory.historicalPoints, isEmpty);
      expect(result.trajectory.futurePoints, isNotEmpty);
    });

    test('throws FundNotFoundError for missing fund', () async {
      expect(
        () => useCase.execute('missing-fund'),
        throwsA(isA<FundNotFoundError>()),
      );
    });
  });
}
