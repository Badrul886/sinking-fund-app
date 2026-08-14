class PercentageFormatter {
  const PercentageFormatter();

  /// Formats a 0.0 to 1.0 progress double into a clean percentage string.
  /// E.g., 0.456 -> "46%"
  /// Values slightly above 0% will not round to 0 unless exactly 0.
  /// Values slightly below 100% will not round to 100% unless exactly 1.
  String format(double progress) {
    if (progress <= 0) return '0%';
    if (progress >= 1.0) return '${(progress * 100).toStringAsFixed(0)}%';

    final percent = (progress * 100).round();

    // Prevent false completion/start states due to rounding
    if (percent == 0) return '1%';
    if (percent == 100) return '99%';

    return '$percent%';
  }
}
