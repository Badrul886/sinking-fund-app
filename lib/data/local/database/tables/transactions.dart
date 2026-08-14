import 'package:drift/drift.dart';
import 'funds.dart';

@DataClassName('TransactionData')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get fundId =>
      text().references(Funds, #id, onDelete: KeyAction.cascade)();
  IntColumn get amountMinorUnits => integer()();
  TextColumn get date => text()();
  TextColumn get note => text().nullable()();
  IntColumn get type => integer()(); // 0: contribution, 1: withdrawal
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  List<Set<Column>> get customUniqueKeys => [];
}
