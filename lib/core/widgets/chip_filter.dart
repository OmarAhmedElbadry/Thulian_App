import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_sizes.dart";
import "../theme/tokens/app_spacing.dart";

/// Square filter chip ("ALL . 5", "#STUDY"). Selected = filled ink.
class ChipFilter extends StatelessWidget {
  const ChipFilter({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.minTouchTarget - 8,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? c.ink : Colors.transparent,
              border: Border.all(color: selected ? c.ink : c.hairline),
            ),
            child: ExcludeSemantics(
              child: Text(
                label.toUpperCase(),
                style: context.type.metaSmall.copyWith(
                  color: selected ? c.background : c.ink,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
