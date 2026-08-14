import 'package:flutter/material.dart';
import '../../theme/app_theme_extensions.dart';

class SecondaryActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const SecondaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interaction =
        theme.extension<AppInteraction>() ?? AppInteraction.regular;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(interaction.primaryButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              interaction.primaryButtonRadius,
            ),
          ),
          side: BorderSide(
            color: onPressed != null
                ? theme.colorScheme.outline
                : theme.colorScheme.outline.withValues(alpha: 0.38),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: onPressed != null
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }
}
