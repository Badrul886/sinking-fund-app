import 'package:flutter_test/flutter_test.dart';

import 'package:drift/native.dart';
import 'package:sinking_fund/data/local/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Database initialization and basic insertion', () async {
    await db
        .into(db.funds)
        .insert(
          FundsCompanion.insert(
            id: '1',
            name: 'Test Fund',
            targetMinorUnits: 1000,
            currencyCode: 'USD',
            startDate: '2023-01-01',
            targetDate: '2023-12-31',
            contributionFrequency: 2,
          ),
        );

    final funds = await db.select(db.funds).get();
    expect(funds.length, 1);
    expect(funds.first.name, 'Test Fund');
  });
}
