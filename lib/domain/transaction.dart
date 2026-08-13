import 'money.dart';
import 'calendar_date.dart';
import 'exceptions.dart';

sealed class Transaction {
  final Money amount;
  final CalendarDate date;

  Transaction(this.amount, this.date) {
    if (amount.minorUnits <= 0) {
      throw ValidationException('Transaction amount must be strictly positive');
    }
  }
}

class Contribution extends Transaction {
  Contribution(super.amount, super.date);
}

class Withdrawal extends Transaction {
  Withdrawal(super.amount, super.date);
}
