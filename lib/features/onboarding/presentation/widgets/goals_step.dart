import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/display_title.dart";
import "../../../../core/widgets/square_checkbox.dart";
import "../../domain/entities/onboarding_goal.dart";

class GoalsStep extends StatelessWidget {
  const GoalsStep({
    super.key,
    required this.selectedIds,
    required this.onToggle,
    required this.showError,
  });

  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DisplayTitle("What are you filing", extraLarge: true),
        const SizedBox(height: AppSpacing.s),
        Text(
          "Choose the areas to start with. You can change this later.",
          style: context.type.bodySmall.copyWith(color: c.inkMuted),
        ),
        if (showError) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            "PICK AT LEAST ONE AREA TO FILE",
            style: context.type.metaSmall.copyWith(color: c.accent),
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        for (var i = 0; i < OnboardingCatalog.goals.length; i++)
          _GoalRow(
            index: i,
            goal: OnboardingCatalog.goals[i],
            selected: selectedIds.contains(OnboardingCatalog.goals[i].id),
            onToggle: onToggle,
          ),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.index,
    required this.goal,
    required this.selected,
    required this.onToggle,
  });

  final int index;
  final OnboardingGoal goal;
  final bool selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      checked: selected,
      label: goal.title,
      hint: goal.meta,
      child: InkWell(
        onTap: () => onToggle(goal.id),
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.hairline)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    (index + 1).toString().padLeft(2, "0"),
                    style: context.type.metaSmall.copyWith(color: c.inkMuted),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: context.type.headline.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        goal.meta,
                        style: context.type.metaSmall.copyWith(
                          color: c.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SquareCheckbox(
                  value: selected,
                  onChanged: (_) => onToggle(goal.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
