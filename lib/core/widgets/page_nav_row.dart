import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_sizes.dart";

/// "<- CANCEL" on the left and an optional status note on the right
/// ("DRAFT · UNSAVED", "MODIFIED 03.11 · 09:12").
class PageNavRow extends StatelessWidget {
  const PageNavRow({
    super.key,
    required this.backLabel,
    required this.onBack,
    this.trailing,
  });

  final String backLabel;
  final VoidCallback onBack;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.type.metaSmall;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Semantics(
          button: true,
          label: backLabel,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppSizes.minTouchTarget,
              ),
              alignment: Alignment.centerLeft,
              child: ExcludeSemantics(
                child: Text(
                  "\u2190 ${backLabel.toUpperCase()}",
                  style: style.copyWith(color: c.ink),
                ),
              ),
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              trailing!.toUpperCase(),
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ],
    );
  }
}
