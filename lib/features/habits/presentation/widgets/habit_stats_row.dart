import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";

/// Bottom stat row for the expanded habit: BEST / TOTAL / RATE + EDIT button.
class HabitStatsRow extends StatelessWidget {
  const HabitStatsRow({
    super.key,
    required this.bestStreak,
    required this.totalCompletions,
    required this.completionRate,
    this.onEdit,
  });

  final int bestStreak;
  final int totalCompletions;
  final int completionRate;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            children: [
              _StatColumn(label: "BEST", value: "$bestStreak"),
              const SizedBox(width: AppSpacing.xl),
              _StatColumn(label: "TOTAL", value: "$totalCompletions"),
              const SizedBox(width: AppSpacing.xl),
              _StatColumn(label: "RATE", value: "$completionRate%"),
            ],
          ),
        ),
        SizedBox(
          width: 72,
          child: AppButton(
            label: "Edit",
            variant: AppButtonVariant.ghost,
            showArrow: false,
            onPressed: onEdit,
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: t.metaSmall.copyWith(color: c.inkMuted)),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: t.stat.copyWith(fontSize: 28)),
      ],
    );
  }
}
