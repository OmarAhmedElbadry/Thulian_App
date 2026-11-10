import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_spacing.dart";
import "app_button.dart";

/// "Nothing here yet" block: mono label, serif title, short message, optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.label = "No entries",
    this.figure,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final String label;
  final Widget? figure;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (figure != null) ...[
            figure!,
            const SizedBox(height: AppSpacing.xl),
          ],
          Text(label.toUpperCase(), style: t.metaSmall),
          const SizedBox(height: AppSpacing.s),
          Text(title, style: t.headline),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(message!, style: t.bodySmall),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
