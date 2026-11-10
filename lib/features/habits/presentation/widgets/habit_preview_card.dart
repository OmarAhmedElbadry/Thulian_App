import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/square_checkbox.dart";

/// "PREVIEW · HOW IT WILL BE FILED": the new habit as a register row.
class HabitPreviewCard extends StatelessWidget {
  const HabitPreviewCard({super.key, required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;

    return Semantics(
      label: "Preview: $title, $meta",
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(border: Border.all(color: c.ink)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("PREVIEW \u00b7 HOW IT WILL BE FILED", style: t.metaSmall),
              const SizedBox(height: 10),
              Row(
                children: [
                  const SquareCheckbox(value: false, onChanged: null),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      title,
                      style: t.title.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(meta, style: t.metaSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
