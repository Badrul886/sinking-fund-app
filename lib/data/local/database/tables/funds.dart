import 'package:drift/drift.dart';

@DataClassName('FundData')
class Funds extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetMinorUnits => integer()();
  TextColumn get currencyCode => text()();
  TextColumn get startDate => text()();
  TextColumn get targetDate => text()();
  IntColumn get contributionFrequency => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
