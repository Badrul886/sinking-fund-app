import 'dart:math';
import 'package:intl/intl.dart';
import '../../domain/money.dart';

class MoneyFormatter {
  final String? locale;

  const MoneyFormatter({this.locale});

  String format(Money money) {
    final metadata = money.currency.metadata;
    final exponent = metadata.minorUnitExponent;

    final int minorUnits = money.minorUnits;
    final bool isNegative = minorUnits < 0;
    final int absMinor = minorUnits.abs();

    final int divisor = pow(10, exponent).toInt();
    final int wholePart = exponent == 0 ? absMinor : absMinor ~/ divisor;
    final int fractionPart = exponent == 0 ? 0 : absMinor % divisor;

    // Use a decimal pattern to format the integer part with grouping (e.g., 1,234 or 1.234)
    final decimalFormat = NumberFormat.decimalPattern(locale);
    final String formattedWhole = decimalFormat.format(wholePart);

    // Get the currency formatting metadata
    final currencyFormat = NumberFormat.simpleCurrency(
      locale: locale,
      name: money.currency.code,
    );

    // Determine the decimal separator
    final String decimalSeparator = decimalFormat.symbols.DECIMAL_SEP;

    // Build the value string (without currency symbol/sign)
    String valueString = formattedWhole;
    if (exponent > 0) {
      final String paddedFraction = fractionPart.toString().padLeft(
        exponent,
        '0',
      );
      valueString = '$formattedWhole$decimalSeparator$paddedFraction';
    }

    // Now construct the final string using the currency format's prefixes and suffixes.
    // intl NumberFormat positive/negative prefixes often include the currency symbol and sign.
    // However, if we just use them, we must be careful.
    // An alternative reliable way to avoid double conversion while using exact currency pattern:
    final noDecimalCurrencyFormat = NumberFormat.currency(
      locale: locale,
      name: money.currency.code,
      symbol: currencyFormat.currencySymbol,
      decimalDigits: 0,
    );

    String formattedCurrencyNoDecimals;
    if (wholePart == 0 && isNegative) {
      // Dart integers don't have -0, so formatting 0 loses the sign.
      // We format -1 to get the negative currency template (e.g. "-$1"), then replace '1' with '0'.
      final template = noDecimalCurrencyFormat.format(-1);
      formattedCurrencyNoDecimals = template.replaceFirst('1', '0');
    } else {
      formattedCurrencyNoDecimals = noDecimalCurrencyFormat.format(
        isNegative ? -wholePart : wholePart,
      );
    }

    // If there is no exponent, we are done.
    if (exponent == 0) {
      return formattedCurrencyNoDecimals;
    }

    // If there is an exponent, we need to inject the decimal point and fraction.
    // The format could be "$1,234" or "1 234 €" or "-$1,234"
    // We look for the last occurrence of a digit, and insert it immediately after.
    int lastDigitIndex = -1;
    for (int i = formattedCurrencyNoDecimals.length - 1; i >= 0; i--) {
      // Check if it's a digit (0-9). In some locales digits might be different, but NumberFormat standard output uses arabic numerals by default unless configured otherwise.
      // A more robust check for typical Arabic numerals:
      if (formattedCurrencyNoDecimals.codeUnitAt(i) >= 48 &&
          formattedCurrencyNoDecimals.codeUnitAt(i) <= 57) {
        lastDigitIndex = i;
        break;
      }
    }

    if (lastDigitIndex != -1) {
      final String prefixPart = formattedCurrencyNoDecimals.substring(
        0,
        lastDigitIndex + 1,
      );
      final String suffixPart = formattedCurrencyNoDecimals.substring(
        lastDigitIndex + 1,
      );
      final String paddedFraction = fractionPart.toString().padLeft(
        exponent,
        '0',
      );

      // Some currency formats for negative numbers put the sign at the very end or have special wrappers (like parentheses).
      // By injecting right after the digits, we preserve suffix patterns like " €" or ")".
      return '$prefixPart$decimalSeparator$paddedFraction$suffixPart';
    }

    // Fallback if no digit found (highly unlikely unless wholePart was formatted blank)
    return isNegative ? '-$valueString' : valueString;
  }
}
