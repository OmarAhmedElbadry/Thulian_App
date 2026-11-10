import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_spacing.dart";
import "app_button.dart";

/// Confirmation dialog. Returns true (confirm), false (cancel) or null (dismissed).
Future<bool?> showAppDialog(
  BuildContext context, {
  required String title,
  String? message,
  String? recordLabel,
  String confirmLabel = "Confirm",
  String? cancelLabel = "Cancel",
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final c = dialogContext.colors;
      final t = dialogContext.type;
      return Dialog(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(AppSpacing.pageMargin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: c.ink),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recordLabel != null) ...[
                Text(recordLabel.toUpperCase(), style: t.metaSmall),
                const SizedBox(height: AppSpacing.s),
              ],
              Text(title, style: t.headline),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(message, style: t.bodySmall),
              ],
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  if (cancelLabel != null) ...[
                    Expanded(
                      child: AppButton(
                        label: cancelLabel,
                        showArrow: false,
                        variant: AppButtonVariant.ghost,
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                  ],
                  Expanded(
                    child: AppButton(
                      label: confirmLabel,
                      showArrow: false,
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
