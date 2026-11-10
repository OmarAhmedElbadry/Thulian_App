import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_motion.dart";
import "../theme/tokens/app_spacing.dart";

/// Archival record header used by full-page flows (onboarding, auth):
/// a record label on the left, an optional centre reference, a page reference
/// on the right, and a full-width ink rule underneath.
class RecordHeader extends StatelessWidget {
  const RecordHeader({
    super.key,
    required this.label,
    required this.page,
    this.center,
  });

  final String label;

  /// Optional middle reference such as "NO 0307". When supplied the header is
  /// laid out in three equal columns, matching the dashboard mockup.
  final String? center;
  final String page;

  @override
  Widget build(BuildContext context) {
    final style = context.type.metaSmall.copyWith(
      color: context.colors.inkMuted,
    );
    final duration = AppMotion.resolve(context, AppMotion.fast);

    Widget animated(String value, {Key? key}) {
      return AnimatedSwitcher(
        duration: duration,
        switchInCurve: AppMotion.curve,
        switchOutCurve: AppMotion.curve,
        child: Text(
          value.toUpperCase(),
          key: key ?? ValueKey(value),
          style: style,
        ),
      );
    }

    final labelWidget = animated(label);
    final pageWidget = animated(page);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.l,
        AppSpacing.pageMargin,
        AppSpacing.m,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (center == null) ...[
                Flexible(child: labelWidget),
                const SizedBox(width: AppSpacing.m),
                pageWidget,
              ] else ...[
                Expanded(child: labelWidget),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: animated(center!, key: ValueKey(center)),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: pageWidget,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Container(height: 1, color: context.colors.ink),
        ],
      ),
    );
  }
}
