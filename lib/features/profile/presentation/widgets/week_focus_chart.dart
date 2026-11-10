import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";

/// Seven-bar weekly chart with M T W T F S S labels. The highlighted day uses
/// the accent colour.
class WeekFocusChart extends StatelessWidget {
  const WeekFocusChart({
    super.key,
    required this.activity,
    required this.highlightIndex,
  }) : assert(activity.length == 7);

  final List<int> activity;
  final int highlightIndex;

  static const _labels = ["M", "T", "W", "T", "F", "S", "S"];
  static const _height = 84.0;

  static double _barHeight(int value) {
    final fraction = (value < 0 ? 0 : (value > 100 ? 100 : value)) / 100;
    final height = _height * fraction;
    return height < 3.0 ? 3.0 : height;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;

    return Semantics(
      label: "Weekly focus chart",
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: _height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          height: _barHeight(activity[i]),
                          color: i == highlightIndex ? c.accent : c.ink,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        _labels[i],
                        style: t.metaSmall.copyWith(
                          color: i == highlightIndex ? c.accent : c.inkMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
