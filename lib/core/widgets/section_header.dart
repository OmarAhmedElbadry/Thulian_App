import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_spacing.dart";
import "hairline_divider.dart";

/// Numbered section label: "01 - TODAY'S HABITS" with an optional trailing note.
/// The dashboard variant uses a full-ink rule ([strong]).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.number,
    required this.title,
    this.trailing,
    this.strong = false,
  });

  final String number;
  final String title;
  final String? trailing;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = context.type.metaSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HairlineDivider(strong: strong),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$number \u2014 ${title.toUpperCase()}", style: style),
              if (trailing != null) Text(trailing!.toUpperCase(), style: style),
            ],
          ),
        ),
      ],
    );
  }
}
