import "package:flutter/material.dart";

import "../theme/tokens/app_spacing.dart";
import "chip_filter.dart";

/// A single-choice row of square chips (category, frequency, theme, room
/// visibility). With [expand] the options share the full width equally.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.expand = true,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      for (final (optionValue, label) in options)
        ChipFilter(
          label: label,
          selected: optionValue == value,
          onTap: () => onChanged(optionValue),
        ),
    ];

    if (!expand) {
      return Wrap(
        spacing: AppSpacing.s,
        runSpacing: AppSpacing.s,
        children: chips,
      );
    }

    return Row(
      children: [
        for (var i = 0; i < chips.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.s),
          Expanded(child: chips[i]),
        ],
      ],
    );
  }
}
