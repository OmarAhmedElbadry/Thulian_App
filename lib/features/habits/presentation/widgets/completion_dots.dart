import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";

/// Seven small squares representing the current week's completions.
/// Filled accent = done, outlined hairline = not done / future.
/// Matches the "■■□□□□□" pattern from the mockup.
class CompletionDots extends StatelessWidget {
  const CompletionDots({super.key, required this.completions})
    : assert(completions.length == 7);

  /// Seven booleans, Monday to Sunday.
  final List<bool> completions;

  static const _size = 10.0;
  static const _gap = 3.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < completions.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: completions[i] ? c.accent : Colors.transparent,
              border: Border.all(color: completions[i] ? c.accent : c.hairline),
            ),
          ),
        ],
      ],
    );
  }
}
