import 'money.dart';
import 'calendar_date.dart';
import 'exceptions.dart';

sealed class Transaction {
  final String id;
  final Money amount;
  final CalendarDate date;

  Transaction({required this.id, required this.amount, required this.date}) {
    if (amount.minorUnits <= 0) {
      throw ValidationException('Transaction amount must be strictly positive');
    }
  }
}

class Contribution extends Transaction {
  Contribution({required super.id, required super.amount, required super.date});
}

class Withdrawal extends Transaction {
  Withdrawal({required super.id, required super.amount, required super.date});
}
