import '../../domain/money.dart';
import '../../domain/currency.dart';
import '../../domain/currency_data.dart';

class MoneyParser {
  /// Parses a string into a [Money] object using integer-safe arithmetic.
  /// 
  /// The [text] parameter should be normalized to use '.' as the decimal separator.
  /// Throws [FormatException] if the text is malformed or invalid.
  static Money parse(String text, Currency currency) {
    if (text.trim().isEmpty) {
      throw const FormatException('Empty input');
    }

    final trimmed = text.trim();

    if (trimmed.startsWith('-')) {
      throw const FormatException('Negative amounts are not allowed');
    }
    if (trimmed.startsWith('+')) {
      throw const FormatException('Plus signs are not allowed');
    }

    final parts = trimmed.split('.');
    if (parts.length > 2) {
      throw const FormatException('Malformed decimal');
    }

    final wholeStr = parts[0];
    final fracStr = parts.length > 1 ? parts[1] : '';

    if (wholeStr.isEmpty && fracStr.isEmpty) {
      throw const FormatException('Empty input');
    }

    final metadata = iso4217Currencies[currency.code];
    if (metadata == null) {
      throw FormatException('Unknown currency code: ${currency.code}');
    }
    
    final exponent = metadata.minorUnitExponent;

    if (fracStr.length > exponent) {
      throw FormatException('Fractional digits exceed minor unit exponent of $exponent');
    }

    final digitRegex = RegExp(r'^\d*$');
    if (!digitRegex.hasMatch(wholeStr) || !digitRegex.hasMatch(fracStr)) {
      throw const FormatException('Contains non-digit characters');
    }

    final wholePart = wholeStr.isEmpty ? 0 : int.parse(wholeStr);
    
    final paddedFracStr = fracStr.padRight(exponent, '0');
    final fractionalPart = paddedFracStr.isEmpty ? 0 : int.parse(paddedFracStr);

    final multiplier = _getMultiplier(exponent);
    final minorUnits = (wholePart * multiplier) + fractionalPart;

    return Money(minorUnits: minorUnits, currency: currency);
  }

  static int _getMultiplier(int exponent) {
    int result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
