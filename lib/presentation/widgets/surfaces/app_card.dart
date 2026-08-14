import 'package:flutter/material.dart';
import '../../theme/app_theme_extensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interaction = theme.extension<AppInteraction>() ?? AppInteraction.regular;
    final elevation = theme.extension<AppElevation>() ?? AppElevation.regular;
    final padding = theme.extension<AppSpacing>() ?? AppSpacing.regular;

    return Semantics(
      container: true,
      button: onTap != null,
      child: Material(
        color: theme.extension<AppSemanticColors>()?.surfaceElevated ?? theme.colorScheme.surface,
        elevation: elevation.card,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(interaction.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(padding.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
