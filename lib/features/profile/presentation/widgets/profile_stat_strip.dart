import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";

/// Three-cell band under the identity: streak, habits filed, study hours.
class ProfileStatStrip extends StatelessWidget {
  const ProfileStatStrip({
    super.key,
    required this.streakDays,
    required this.habitsFiled,
    required this.studyHours,
  });

  final int streakDays;
  final int habitsFiled;
  final int studyHours;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: c.ink, width: AppBorders.hairline),
          bottom: BorderSide(color: c.ink, width: AppBorders.hairline),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Cell(label: "STREAK", value: "$streakDays", unit: "d"),
            ),
            Container(width: 1, color: c.hairline),
            Expanded(
              child: _Cell(label: "HABITS", value: "$habitsFiled"),
            ),
            Container(width: 1, color: c.hairline),
            Expanded(
              child: _Cell(label: "STUDY", value: "$studyHours", unit: "h"),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;

    return Semantics(
      label: "$label $value${unit ?? ""}",
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: t.metaSmall),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: t.stat.copyWith(fontSize: 30)),
                  if (unit != null) ...[
                    const SizedBox(width: 3),
                    Text(unit!, style: t.bodySmall.copyWith(color: c.inkMuted)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
