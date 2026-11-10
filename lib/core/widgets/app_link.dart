import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_sizes.dart";
import "../theme/tokens/app_spacing.dart";

/// Mono, uppercase text link with a trailing arrow. Used for "see all" actions
/// at the end of a dashboard section.
class AppLink extends StatelessWidget {
  const AppLink({
    super.key,
    required this.label,
    required this.onTap,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final VoidCallback onTap;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final style = context.type.metaSmall.copyWith(color: context.colors.ink);
    return Align(
      alignment: alignment,
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              child: ExcludeSemantics(
                child: Text("${label.toUpperCase()}  \u2192", style: style),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
