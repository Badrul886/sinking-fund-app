import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // We are instructed to use a bundled cross-platform sans-serif font, using standard Flutter text themes.
  // We can use the default sans-serif font (Roboto on Android, San Francisco on iOS) via standard ThemeData.
  // The financial fonts specifically need tabular figures if supported (FontFeature.tabularFigures()).

  static TextTheme getTextTheme(Color defaultColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        height: 42 / 36,
        color: defaultColor,
      ),
      displayMedium: TextStyle(
        fontSize: 30,
        height: 36 / 30,
        color: defaultColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 26,
        height: 32 / 26,
        color: defaultColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        height: 28 / 22,
        color: defaultColor,
      ),
      titleLarge: TextStyle(fontSize: 20, height: 26 / 20, color: defaultColor),
      titleMedium: TextStyle(
        fontSize: 17,
        height: 22 / 17,
        color: defaultColor,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, color: defaultColor),
      bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, color: defaultColor),
      bodySmall: TextStyle(fontSize: 12, height: 18 / 12, color: defaultColor),
      labelLarge: TextStyle(fontSize: 14, height: 20 / 14, color: defaultColor),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 16 / 12,
        color: defaultColor,
      ),
      labelSmall: TextStyle(fontSize: 11, height: 14 / 11, color: defaultColor),
    );
  }

  static TextStyle financialLarge(Color color) => TextStyle(
    fontSize: 40,
    height: 44 / 40,
    fontWeight: FontWeight.w700,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle financialMedium(Color color) => TextStyle(
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle financialSmall(Color color) => TextStyle(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
