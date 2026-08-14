abstract class ApplicationError implements Exception {
  final String message;
  const ApplicationError(this.message);

  @override
  String toString() => 'ApplicationError: $message';
}

class FundNotFoundError extends ApplicationError {
  const FundNotFoundError([super.message = 'Fund not found.']);
}

class InsufficientFundsError extends ApplicationError {
  const InsufficientFundsError([
    super.message = 'Insufficient funds for withdrawal.',
  ]);
}

class InvalidFundDataError extends ApplicationError {
  const InvalidFundDataError(super.message);
}

class PersistenceConstraintError extends ApplicationError {
  const PersistenceConstraintError(super.message);
}
