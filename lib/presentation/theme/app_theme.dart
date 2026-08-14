import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme_extensions.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = AppColors.lightColorScheme;
    final textTheme = AppTypography.getTextTheme(AppColors.lightTextPrimary);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: const [
        AppSpacing.regular,
        AppRadii.regular,
        AppElevation.regular,
        AppInteraction.regular,
        AppAnimation.regular,
        AppSemanticColors(surfaceElevated: AppColors.lightSurfaceElevated, textMuted: AppColors.lightTextMuted),
      ],
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = AppColors.darkColorScheme;
    final textTheme = AppTypography.getTextTheme(AppColors.darkTextPrimary);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: const [
        AppSpacing.regular,
        AppRadii.regular,
        AppElevation.regular,
        AppInteraction.regular,
        AppAnimation.regular,
        AppSemanticColors(surfaceElevated: AppColors.darkSurfaceElevated, textMuted: AppColors.darkTextMuted),
      ],
    );
  }
}
