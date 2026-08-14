import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Mode Colors
  static const Color lightPrimary = Color(0xFF166B5C);
  static const Color lightPrimaryDark = Color(0xFF0F5146);
  static const Color lightPrimaryContainer = Color(0xFFDCEFEA);
  static const Color lightBackground = Color(0xFFF7F8F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFCFCFA);
  static const Color lightTextPrimary = Color(0xFF17211E);
  static const Color lightTextSecondary = Color(0xFF5C6964);
  static const Color lightTextMuted = Color(0xFF87928E);
  static const Color lightBorder = Color(0xFFDCE2DE);
  static const Color lightDivider = Color(0xFFE8ECE9);
  static const Color lightSuccess = Color(0xFF1F7A5A);
  static const Color lightSuccessContainer = Color(0xFFDDF2E8);
  static const Color lightWarning = Color(0xFFA86A00);
  static const Color lightWarningContainer = Color(0xFFFFF0D0);
  static const Color lightError = Color(0xFFB54747);
  static const Color lightErrorContainer = Color(0xFFFBE4E4);
  static const Color lightInfo = Color(0xFF3569A8);
  static const Color lightInfoContainer = Color(0xFFE5EEFA);
  static const Color lightFocus = Color(0xFF166B5C);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF101614);
  static const Color darkSurface = Color(0xFF17201D);
  static const Color darkSurfaceElevated = Color(0xFF1D2925);
  static const Color darkTextPrimary = Color(0xFFF2F5F3);
  static const Color darkTextSecondary = Color(0xFFB8C3BE);
  static const Color darkTextMuted = Color(0xFF8F9B96);
  static const Color darkBorder = Color(0xFF2B3833);
  static const Color darkDivider = Color(0xFF25312D);
  static const Color darkPrimary = Color(0xFF63B5A3);
  static const Color darkPrimaryContainer = Color(0xFF183F36);

  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: lightPrimary,
        onPrimary: lightSurface,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightPrimaryDark,
        secondary: lightPrimaryDark,
        onSecondary: lightSurface,
        error: lightError,
        onError: lightSurface,
        errorContainer: lightErrorContainer,
        onErrorContainer: lightError,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        onSurfaceVariant: lightTextSecondary,
        outline: lightBorder,
        outlineVariant: lightDivider,
      );

  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkSurface,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkPrimary,
        secondary: darkPrimary,
        onSecondary: darkSurface,
        error: lightError, // Fallback gracefully if dark error isn't explicitly defined
        onError: darkSurface,
        errorContainer: lightErrorContainer,
        onErrorContainer: lightError,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        onSurfaceVariant: darkTextSecondary,
        outline: darkBorder,
        outlineVariant: darkDivider,
      );
}
