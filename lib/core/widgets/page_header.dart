import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_spacing.dart";

/// Archival page header: "DAILY RECORD · Nº 0307" on the left, "P. 01 / 12" on the right.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.label, required this.page});

  final String label;
  final String page;

  @override
  Widget build(BuildContext context) {
    final style = context.type.metaSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageMargin,
        vertical: AppSpacing.m,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label.toUpperCase(), style: style)),
          const SizedBox(width: AppSpacing.m),
          Text(page.toUpperCase(), style: style),
        ],
      ),
    );
  }
}
