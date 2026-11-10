import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_motion.dart";
import "../theme/tokens/app_spacing.dart";

/// Text-only bottom navigation. The active tab is marked by a full-tab accent
/// rule sitting on top of the bar, matching the Phase 2 mockups.
class ArchivalNavBar extends StatelessWidget {
  const ArchivalNavBar({
    super.key,
    required this.labels,
    required this.currentIndex,
    required this.onTap,
  });

  final List<String> labels;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        border: Border(
          top: BorderSide(
            color: c.ink.withValues(alpha: 0.7),
            width: AppBorders.hairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: _NavItem(
                    label: labels[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
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
    final duration = AppMotion.resolve(context, AppMotion.base);
    final style = context.type.metaSmall.copyWith(
      color: selected ? c.accent : c.inkMuted,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
    );

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                duration: duration,
                curve: AppMotion.curve,
                width: double.infinity,
                height: 2,
                color: selected ? c.accent : Colors.transparent,
              ),
            ),
            AnimatedSlide(
              duration: duration,
              curve: AppMotion.curve,
              offset: selected ? const Offset(0, -0.04) : Offset.zero,
              child: AnimatedDefaultTextStyle(
                duration: duration,
                curve: AppMotion.curve,
                style: style,
                child: ExcludeSemantics(child: Text(label)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
