import 'package:flutter/material.dart';

class AppSpacing extends ThemeExtension<AppSpacing> {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
  });

  static const AppSpacing regular = AppSpacing(
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
    xxl: 32,
    xxxl: 40,
  );

  @override
  ThemeExtension<AppSpacing> copyWith() {
    return this; // Spacing is constant
  }

  @override
  ThemeExtension<AppSpacing> lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return this; // Not lerping spacing for now
  }
}

class AppRadii extends ThemeExtension<AppRadii> {
  final double small;
  final double medium;
  final double large;
  final double xl;
  final double pill;

  const AppRadii({
    required this.small,
    required this.medium,
    required this.large,
    required this.xl,
    required this.pill,
  });

  static const AppRadii regular = AppRadii(
    small: 8,
    medium: 12,
    large: 16,
    xl: 24,
    pill: 999,
  );

  @override
  ThemeExtension<AppRadii> copyWith() => this;

  @override
  ThemeExtension<AppRadii> lerp(ThemeExtension<AppRadii>? other, double t) =>
      this;
}

class AppElevation extends ThemeExtension<AppElevation> {
  final double none;
  final double subtle;
  final double card;
  final double raised;
  final double modal;

  const AppElevation({
    required this.none,
    required this.subtle,
    required this.card,
    required this.raised,
    required this.modal,
  });

  static const AppElevation regular = AppElevation(
    none: 0,
    subtle: 1,
    card: 2,
    raised: 4,
    modal: 8,
  );

  @override
  ThemeExtension<AppElevation> copyWith() => this;

  @override
  ThemeExtension<AppElevation> lerp(
    ThemeExtension<AppElevation>? other,
    double t,
  ) => this;
}

class AppInteraction extends ThemeExtension<AppInteraction> {
  final double minTouchTarget;
  final double primaryButtonHeight;
  final double primaryButtonRadius;
  final double inputRadius;
  final double cardRadius;

  const AppInteraction({
    required this.minTouchTarget,
    required this.primaryButtonHeight,
    required this.primaryButtonRadius,
    required this.inputRadius,
    required this.cardRadius,
  });

  static const AppInteraction regular = AppInteraction(
    minTouchTarget: 48,
    primaryButtonHeight: 48,
    primaryButtonRadius: 12,
    inputRadius: 12,
    cardRadius: 16,
  );

  @override
  ThemeExtension<AppInteraction> copyWith() => this;

  @override
  ThemeExtension<AppInteraction> lerp(
    ThemeExtension<AppInteraction>? other,
    double t,
  ) => this;
}

class AppAnimation extends ThemeExtension<AppAnimation> {
  final Duration fast;
  final Duration standard;
  final Duration emphasis;

  const AppAnimation({
    required this.fast,
    required this.standard,
    required this.emphasis,
  });

  static const AppAnimation regular = AppAnimation(
    fast: Duration(milliseconds: 120),
    standard: Duration(milliseconds: 200),
    emphasis: Duration(milliseconds: 300),
  );

  @override
  ThemeExtension<AppAnimation> copyWith() => this;

  @override
  ThemeExtension<AppAnimation> lerp(
    ThemeExtension<AppAnimation>? other,
    double t,
  ) => this;
}

class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color surfaceElevated;
  final Color textMuted;

  const AppSemanticColors({
    required this.surfaceElevated,
    required this.textMuted,
  });

  @override
  ThemeExtension<AppSemanticColors> copyWith() => this;

  @override
  ThemeExtension<AppSemanticColors> lerp(
    ThemeExtension<AppSemanticColors>? other,
    double t,
  ) => this;
}

extension AppThemeExtensions on ThemeData {
  AppSpacing get spacing => extension<AppSpacing>()!;
  AppRadii get radii => extension<AppRadii>()!;
  AppElevation get elevation => extension<AppElevation>()!;
  AppInteraction get interaction => extension<AppInteraction>()!;
  AppAnimation get animation => extension<AppAnimation>()!;
  AppSemanticColors get semanticColors => extension<AppSemanticColors>()!;
}
