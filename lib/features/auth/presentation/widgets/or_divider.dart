import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/hairline_divider.dart";

/// "OR" rule used between the email form and the Google option.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label = "OR"});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: HairlineDivider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Text(label.toUpperCase(), style: context.type.metaSmall),
        ),
        const Expanded(child: HairlineDivider()),
      ],
    );
  }
}
