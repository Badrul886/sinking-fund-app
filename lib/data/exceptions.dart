class DataException implements Exception {
  final String message;
  const DataException(this.message);

  @override
  String toString() => 'DataException: $message';
}

class RecordNotFoundException extends DataException {
  const RecordNotFoundException(super.message);
}

class ConstraintViolationException extends DataException {
  const ConstraintViolationException(super.message);
}

class DatabaseFailureException extends DataException {
  const DatabaseFailureException(super.message);
}

class MigrationFailureException extends DataException {
  const MigrationFailureException(super.message);
}
