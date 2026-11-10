import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";

/// MON–SUN day strip with numbers. Today is highlighted in accent + bold.
/// Mirrors the mockup header: "MON  TUE  WED  THU  FRI  SAT  SUN"
///                              02   03   04   05   06   07   08
class WeekDayStrip extends StatelessWidget {
  const WeekDayStrip({
    super.key,
    required this.weekStartDate,
    required this.todayIndex,
  });

  /// The Monday [DateTime] that starts the displayed week.
  final DateTime weekStartDate;

  /// Zero-based index of today within the week (0 = Monday … 6 = Sunday).
  final int todayIndex;

  static const _labels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        children: List.generate(7, (i) {
          final isToday = i == todayIndex;
          final dayNumber = weekStartDate.day + i;

          final labelStyle = t.metaSmall.copyWith(
            color: isToday ? c.accent : c.inkMuted,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
          );

          final numberStyle = t.meta.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: isToday ? c.accent : c.ink,
          );

          return Expanded(
            child: Column(
              children: [
                Text(_labels[i], style: labelStyle),
                const SizedBox(height: AppSpacing.xs),
                Text(dayNumber.toString().padLeft(2, "0"), style: numberStyle),
              ],
            ),
          );
        }),
      ),
    );
  }
}
