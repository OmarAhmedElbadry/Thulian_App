import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_spacing.dart";

/// 1px rule. `strong` uses full ink colour instead of the soft hairline.
class HairlineDivider extends StatelessWidget {
  const HairlineDivider({super.key, this.strong = false});

  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: AppBorders.hairline,
      width: double.infinity,
      child: ColoredBox(color: strong ? c.ink : c.hairline),
    );
  }
}
