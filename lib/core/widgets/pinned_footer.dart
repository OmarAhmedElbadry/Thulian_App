import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_sizes.dart";
import "../theme/tokens/app_spacing.dart";

/// Footer pinned to the bottom of a full-page flow. The top rule is full-bleed
/// ink; the content is aligned to the page margin and capped in width.
class PinnedFooter extends StatelessWidget {
  const PinnedFooter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.ink)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.m,
          AppSpacing.pageMargin,
          AppSpacing.l,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
