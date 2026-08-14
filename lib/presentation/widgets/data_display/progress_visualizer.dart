import 'package:flutter/material.dart';
import '../../theme/app_theme_extensions.dart';

class ProgressVisualizer extends StatelessWidget {
  final double progress; // 0.0 to 1.0, can be > 1.0 (overfunded)

  const ProgressVisualizer({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? AppSpacing.regular;
    final radii = theme.extension<AppRadii>() ?? AppRadii.regular;
    final animation = theme.extension<AppAnimation>() ?? AppAnimation.regular;

    final isOverfunded = progress > 1.0;
    final displayPercentage = (progress * 100).toInt();
    
    // Clamp visual progress to [0.0, 1.0]
    final clampedProgress = progress.clamp(0.0, 1.0);

    final String semanticsLabel = isOverfunded 
        ? '$displayPercentage% complete. Overfunded.' 
        : '$displayPercentage% complete.';

    final String displayLabel = isOverfunded
        ? '$displayPercentage% · Overfunded'
        : '$displayPercentage%';

    return Semantics(
      label: semanticsLabel,
      value: '${(clampedProgress * 100).toInt()}%',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isOverfunded ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
              if (isOverfunded)
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
          SizedBox(height: spacing.sm),
          ExcludeSemantics(
            child: Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.extension<AppSemanticColors>()?.surfaceElevated ?? theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(radii.pill),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      AnimatedContainer(
                        duration: animation.standard,
                        curve: Curves.easeOutCubic,
                        width: constraints.maxWidth * clampedProgress,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(radii.pill),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
