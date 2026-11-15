import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";

/// Seven small squares representing the current week's completions.
/// Filled accent = done, outlined hairline = not done / future.
/// Matches the "■■□□□□□" pattern from the mockup.
class CompletionDots extends StatelessWidget {
  const CompletionDots({
    super.key,
    required this.completions,
    this.todayIndex = -1,
    this.onToggleToday,
  }) : assert(completions.length == 7);

  /// Seven booleans, Monday to Sunday.
  final List<bool> completions;
  final int todayIndex;
  final VoidCallback? onToggleToday;

  static const _size = 10.0;
  static const _gap = 3.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < completions.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          if (i == todayIndex && onToggleToday != null)
            Semantics(
              button: true,
              label: completions[i]
                  ? "Mark today incomplete"
                  : "Mark today complete",
              child: InkWell(
                onTap: onToggleToday,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: _CompletionSquare(done: completions[i], size: _size),
                  ),
                ),
              ),
            )
          else
            _CompletionSquare(done: completions[i], size: _size),
        ],
      ],
    );
  }
}

class _CompletionSquare extends StatelessWidget {
  const _CompletionSquare({required this.done, required this.size});

  final bool done;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: done ? c.accent : Colors.transparent,
        border: Border.all(color: done ? c.accent : c.hairline),
      ),
    );
  }
}
