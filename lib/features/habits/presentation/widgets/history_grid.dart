import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/section_header.dart";

/// 4-week (28-day) completion grid: 7 columns × 4 rows of small squares.
/// Filled ink = completed, outlined hairline = missed.
/// Shown under the expanded first habit as "HISTORY · LAST 4 WEEKS".
class HistoryGrid extends StatelessWidget {
  const HistoryGrid({super.key, required this.grid})
    : assert(grid.length == 28);

  /// 28 booleans, oldest week first, Monday → Sunday per row.
  final List<bool> grid;

  static const _cellSize = 18.0;
  static const _gap = 4.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          number: "",
          title: "History",
          trailing: "Last 4 weeks",
        ),
        const SizedBox(height: AppSpacing.s),
        Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (var i = 0; i < grid.length; i++)
              Container(
                width: _cellSize,
                height: _cellSize,
                decoration: BoxDecoration(
                  color: grid[i] ? c.ink : Colors.transparent,
                  border: Border.all(color: grid[i] ? c.ink : c.hairline),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
