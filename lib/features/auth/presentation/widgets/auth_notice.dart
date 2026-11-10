import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";

/// Bordered editorial notice card, e.g. "LINK SENT" on the recovery page.
///
/// The surrounding [RevealGroup] animates it in when it first appears.
class AuthNotice extends StatelessWidget {
  const AuthNotice({super.key, required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.ink, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: context.type.metaSmall.copyWith(color: c.accent),
          ),
          const SizedBox(height: AppSpacing.m),
          ...children,
        ],
      ),
    );
  }
}
