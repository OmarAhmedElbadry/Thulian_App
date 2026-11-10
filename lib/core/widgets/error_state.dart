import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_spacing.dart";
import "app_button.dart";

/// Recoverable error block with an optional retry action.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title = "Could not file that.",
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ERROR", style: t.metaSmall.copyWith(color: c.accent)),
          const SizedBox(height: AppSpacing.s),
          Text(title, style: t.headline),
          const SizedBox(height: AppSpacing.s),
          Text(message, style: t.bodySmall),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: "Try again",
              variant: AppButtonVariant.ghost,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}
