import "dart:math" as math;

import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../dashboard_format.dart";

/// The three-cell stat band under the habit list: streak, focus and week.
/// Ink rules top and bottom, hairline dividers, and a seven-bar week chart.
class StatStrip extends StatelessWidget {
  const StatStrip({
    super.key,
    required this.streakDays,
    required this.focusMinutes,
    required this.weekDone,
    required this.weekTotal,
    required this.weekActivity,
    required this.weekHighlightIndex,
  });

  final int streakDays;
  final int focusMinutes;
  final int weekDone;
  final int weekTotal;
  final List<int> weekActivity;
  final int weekHighlightIndex;

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
              flex: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _StreakCell(streakDays: streakDays),
              ),
            ),
            Container(width: 1, color: c.hairline),
            Expanded(
              flex: 124,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                child: _FocusCell(focusMinutes: focusMinutes),
              ),
            ),
            Container(width: 1, color: c.hairline),
            Expanded(
              flex: 121,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                child: _WeekCell(
                  weekDone: weekDone,
                  weekTotal: weekTotal,
                  activity: weekActivity,
                  highlightIndex: weekHighlightIndex,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.type.metaSmall.copyWith(color: context.colors.inkMuted),
    );
  }
}

class _StreakCell extends StatelessWidget {
  const _StreakCell({required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label("02 \u2014 STREAK"),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "$streakDays",
                style: context.type.stat.copyWith(fontSize: 34),
              ),
              const SizedBox(width: 10),
              Text(
                "days",
                style: context.type.bodySmall.copyWith(color: c.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FocusCell extends StatelessWidget {
  const _FocusCell({required this.focusMinutes});

  final int focusMinutes;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label("03 \u2014 FOCUS"),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                focusClock(focusMinutes),
                style: context.type.stat.copyWith(fontSize: 26),
              ),
              const SizedBox(width: 5),
              Text(
                "h",
                style: context.type.bodySmall.copyWith(color: c.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekCell extends StatelessWidget {
  const _WeekCell({
    required this.weekDone,
    required this.weekTotal,
    required this.activity,
    required this.highlightIndex,
  });

  final int weekDone;
  final int weekTotal;
  final List<int> activity;
  final int highlightIndex;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const _Label("04 \u2014 WEEK"),
              const SizedBox(width: 6),
              Text(
                "$weekDone/$weekTotal",
                style: context.type.metaSmall.copyWith(color: c.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 34,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 3.0;
              final barWidth = math
                  .max(2.0, (constraints.maxWidth - gap * 6) / 7)
                  .toDouble();
              return Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < activity.length; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      Container(
                        width: barWidth,
                        height: math
                            .max(3.0, 34 * (activity[i].clamp(0, 100) / 100))
                            .toDouble(),
                        color: i < highlightIndex
                            ? c.ink
                            : i == highlightIndex
                            ? c.accent
                            : c.hairline,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
