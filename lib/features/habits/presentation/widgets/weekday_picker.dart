import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_motion.dart";
import "../habit_format.dart";

/// M T W T F S S selector. Selected days are filled with the accent colour.
class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  /// 1-based weekdays (1 = Monday).
  final List<int> selected;
  final ValueChanged<int> onToggle;

  static const _labels = ["M", "T", "W", "T", "F", "S", "S"];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _DayCell(
              label: _labels[i],
              semanticLabel: weekdaysLong[i],
              selected: selected.contains(i + 1),
              onTap: () => onToggle(i + 1),
            ),
          ),
        ],
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.resolve(context, AppMotion.fast),
          curve: AppMotion.curve,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.accent : Colors.transparent,
            border: Border.all(color: selected ? c.accent : c.ink),
          ),
          child: ExcludeSemantics(
            child: Text(
              label,
              style: context.type.meta.copyWith(
                color: selected ? c.onAccent : c.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
