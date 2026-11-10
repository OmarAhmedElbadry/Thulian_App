import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_motion.dart";
import "../../../../core/widgets/square_checkbox.dart";
import "../../domain/entities/dashboard_snapshot.dart";
import "../dashboard_format.dart";

/// A habit line on the dashboard: index, checkbox, title and streak/status.
/// Tapping anywhere on the row files or unfiles the habit; the title softly
/// strikes through when done.
class HabitBriefRow extends StatelessWidget {
  const HabitBriefRow({
    super.key,
    required this.number,
    required this.habit,
    required this.onToggle,
  });

  final int number;
  final HabitBrief habit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = habit.done;
    final status = done ? "STR ${habit.streakDays}" : "PENDING";
    final titleStyle = context.type.title.copyWith(
      fontSize: 17,
      color: done ? c.inkMuted : c.ink,
      decoration: done ? TextDecoration.lineThrough : null,
      decorationColor: c.inkMuted,
      decorationThickness: 1,
    );

    return Semantics(
      button: true,
      checked: done,
      label: habit.title,
      hint: done ? "Streak ${habit.streakDays} days" : "Pending",
      child: InkWell(
        onTap: onToggle,
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.hairline)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    twoDigits(number),
                    style: context.type.metaSmall.copyWith(color: c.inkMuted),
                  ),
                ),
                const SizedBox(width: 5),
                SquareCheckbox(value: done, onChanged: (_) => onToggle()),
                const SizedBox(width: 11),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: AppMotion.resolve(context, AppMotion.base),
                    curve: AppMotion.curve,
                    style: titleStyle,
                    child: Text(
                      habit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: context.type.metaSmall.copyWith(
                    color: done ? c.inkMuted : c.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
