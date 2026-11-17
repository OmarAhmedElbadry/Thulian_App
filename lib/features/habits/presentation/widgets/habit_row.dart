import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/hairline_divider.dart";
import "../../domain/entities/habit_entry.dart";
import "completion_dots.dart";

/// A habit row with an edit action on its title and a completion action for
/// today's dot.
class HabitRow extends StatelessWidget {
  const HabitRow({
    super.key,
    required this.index,
    required this.habit,
    this.onTap,
    this.todayIndex = -1,
    this.onSetTodayCompletion,
  });

  final int index;
  final HabitEntry habit;
  final VoidCallback? onTap;
  final int todayIndex;
  final ValueChanged<bool>? onSetTodayCompletion;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;
    final number = index.toString().padLeft(2, "0");

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Expanded(
                child: Semantics(
                  button: onTap != null,
                  label: habit.title,
                  hint: habit.subtitle,
                  child: InkWell(
                    onTap: onTap,
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
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              CompletionDots(
                completions: habit.weekCompletions,
                todayIndex: todayIndex,
                onSetTodayCompletion: onSetTodayCompletion,
              ),
            ],
          ),
        ),
        const HairlineDivider(),
      ],
    );
  }
}
