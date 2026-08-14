import 'package:flutter/material.dart';
import '../../theme/app_theme_extensions.dart';

class PrimaryActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const PrimaryActionButton({
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
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(interaction.primaryButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              interaction.primaryButtonRadius,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
