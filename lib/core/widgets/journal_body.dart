import "package:flutter/material.dart";

import "../theme/tokens/app_sizes.dart";
import "../theme/tokens/app_spacing.dart";
import "reveal.dart";

/// Scrolling editorial body used under a [RecordHeader]: page margins, a
/// capped content width and the quiet reveal cascade. Wrap in `Expanded`.
class JournalBody extends StatelessWidget {
  const JournalBody({super.key, required this.children, this.topPadding = 0});

  final List<Widget> children;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          topPadding,
          AppSpacing.pageMargin,
          AppSpacing.xl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
          child: RevealGroup(children: children),
        ),
      ),
    );
  }
}
