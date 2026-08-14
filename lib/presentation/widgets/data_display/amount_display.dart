import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/money.dart';
import '../../formatters/money_formatter.dart';
import '../../theme/app_theme_extensions.dart';
import '../../theme/app_typography.dart';

class AmountDisplay extends StatelessWidget {
  final Money amount;
  final String? locale;
  final TextStyle? style;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.locale,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = MoneyFormatter(locale: locale);
    final String formattedValue = formatter.format(amount);

    final decimalSeparator = NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP;
    final exponent = amount.currency.metadata.minorUnitExponent;

    final defaultStyle = style ?? AppTypography.financialLarge(theme.colorScheme.onSurface);
    
    // Semantics should read the whole string coherently.
    return Semantics(
      label: formattedValue,
      child: ExcludeSemantics(
        child: _buildRichText(formattedValue, decimalSeparator, exponent, defaultStyle, theme),
      ),
    );
  }

  Widget _buildRichText(
    String formattedValue, 
    String decimalSeparator, 
    int exponent, 
    TextStyle baseStyle,
    ThemeData theme,
  ) {
    if (exponent == 0) {
      return Text(formattedValue, style: baseStyle);
    }

    final int separatorIndex = formattedValue.indexOf(decimalSeparator);
    
    // If for some reason the decimal separator isn't found (e.g. malformed locale), fallback to raw text.
    if (separatorIndex == -1) {
      return Text(formattedValue, style: baseStyle);
    }

    final String wholePart = formattedValue.substring(0, separatorIndex);
    final String fractionPartAndSuffix = formattedValue.substring(separatorIndex);

    // Make the fraction part slightly smaller and muted, per typical financial app design.
    final fractionStyle = baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * 0.75, // Scaled down
      color: theme.extension<AppSemanticColors>()?.textMuted ?? theme.colorScheme.onSurface,
    );

    return Text.rich(
      TextSpan(
        text: wholePart,
        style: baseStyle,
        children: [
          TextSpan(
            text: fractionPartAndSuffix,
            style: fractionStyle,
          ),
        ],
      ),
    );
  }
}
