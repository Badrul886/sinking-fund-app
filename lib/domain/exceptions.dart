class CurrencyMismatchException implements Exception {
  final String expected;
  final String actual;

  CurrencyMismatchException(this.expected, this.actual);

  @override
  String toString() =>
      'CurrencyMismatchException: Cannot operate on $expected and $actual';
}

class InsufficientFundsException implements Exception {
  final String message;
  InsufficientFundsException([
    this.message = 'Insufficient funds for withdrawal',
  ]);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}
