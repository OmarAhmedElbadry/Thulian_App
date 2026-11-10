import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/hairline_divider.dart";
import "../../domain/entities/habit_entry.dart";
import "completion_dots.dart";

/// A single habit row in the register: numbered index, title, category/freq
/// subtitle, 7-day completion dots and a streak badge.
///
/// Tapping navigates to the expanded detail (Phase 4); for now it's inert.
class HabitRow extends StatelessWidget {
  const HabitRow({
    super.key,
    required this.index,
    required this.habit,
    this.onTap,
  });

  final int index;
  final HabitEntry habit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;
    final number = index.toString().padLeft(2, "0");

    return Semantics(
      button: onTap != null,
      label: habit.title,
      hint: "Streak ${habit.streakDays} days, ${habit.subtitle}",
      child: InkWell(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Number
                    SizedBox(
                      width: 24,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          number,
                          style: t.metaSmall.copyWith(color: c.inkMuted),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),

                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: t.title.copyWith(fontSize: 17),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            habit.subtitle,
                            style: t.metaSmall.copyWith(color: c.inkMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),

                    // Dots + streak
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CompletionDots(completions: habit.weekCompletions),
                        const SizedBox(height: 6),
                        Text(
                          "STR ${habit.streakDays.toString().padLeft(2, "0")}",
                          style: t.metaSmall.copyWith(color: c.inkMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const HairlineDivider(),
            ],
          ),
        ),
      ),
    );
  }
}
