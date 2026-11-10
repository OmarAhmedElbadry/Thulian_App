import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_spacing.dart";
import "display_title.dart";
import "page_header.dart";

/// Temporary screen body used until each feature UI is built in Phase 2.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.recordLabel,
    required this.page,
    required this.title,
    this.footer,
  });

  final String recordLabel;
  final String page;
  final String title;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(label: recordLabel, page: page),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.xl,
            AppSpacing.pageMargin,
            AppSpacing.s,
          ),
          child: DisplayTitle(title),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageMargin,
          ),
          child: Text(
            "PLACEHOLDER \u00b7 BUILT IN PHASE 2",
            style: context.type.metaSmall,
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
            ),
            child: footer,
          ),
        ],
      ],
    );
  }
}
