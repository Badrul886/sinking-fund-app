import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:sinking_fund/data/local/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('real v1 to v2 schema migration works and preserves data', () async {
    // 1. Construct v1 schema and populate data
    final v1Database = sqlite3.openInMemory();

    v1Database.execute('PRAGMA user_version = 1;');

    v1Database.execute('''
      CREATE TABLE funds (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        target_minor_units INTEGER NOT NULL,
        currency_code TEXT NOT NULL,
        start_date TEXT NOT NULL,
        target_date TEXT NOT NULL,
        contribution_frequency INTEGER NOT NULL
      );
    ''');

    v1Database.execute('''
      CREATE TABLE transactions (
        id TEXT NOT NULL PRIMARY KEY,
        fund_id TEXT NOT NULL REFERENCES funds (id) ON DELETE CASCADE,
        amount_minor_units INTEGER NOT NULL,
        date TEXT NOT NULL,
        type INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      );
    ''');

    v1Database.execute('''
      INSERT INTO funds (id, name, target_minor_units, currency_code, start_date, target_date, contribution_frequency)
      VALUES ('fund-1', 'Test Fund', 100000, 'USD', '2026-01-01', '2026-12-31', 1);
    ''');

    v1Database.execute('''
      INSERT INTO transactions (id, fund_id, amount_minor_units, date, type, created_at)
      VALUES ('tx-1', 'fund-1', 5000, '2026-02-01', 0, 1600000000);
    ''');

    // 2. Open with Drift (triggers migration from v1 to v2)
    final nativeDb = NativeDatabase.opened(v1Database);
    final db = AppDatabase.forTesting(nativeDb);

    // Trigger migration by doing a simple select
    await db.customSelect('SELECT 1').get();

    // 3. Verify schema version is now 2
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 2);

    // 4. Verify existing fund remains intact
    final funds = await db.select(db.funds).get();
    expect(funds.length, 1);
    expect(funds.first.id, 'fund-1');

    // 5. Verify existing transaction remains intact and note resolves to null
    final txs = await db.select(db.transactions).get();
    expect(txs.length, 1);
    expect(txs.first.id, 'tx-1');
    expect(txs.first.note, isNull);

    // 6. Verify new functionality: persist transaction with non-null note
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'tx-2',
            fundId: 'fund-1',
            amountMinorUnits: 1000,
            date: '2026-03-01',
            note: const Value('Bonus contribution'),
            type: 0,
            createdAt: 1600000001,
          ),
        );

    final tx2 = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals('tx-2'))).getSingle();
    expect(tx2.note, 'Bonus contribution');

    // 7. Verify new functionality: persist app settings
    await db
        .into(db.appSettings)
        .insert(
          AppSettingsCompanion.insert(
            key: 'onboarding_complete',
            value: 'true',
          ),
        );
    final settings = await db.select(db.appSettings).get();
    expect(settings.length, 1);
    expect(settings.first.key, 'onboarding_complete');
    expect(settings.first.value, 'true');

    await db.close();
  });
}
