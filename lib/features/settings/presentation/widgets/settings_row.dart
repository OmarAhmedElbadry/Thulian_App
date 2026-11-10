import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/hairline_divider.dart";

/// A settings line: serif title, mono sub-label, trailing control, hairline.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.type;

    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.title.copyWith(fontSize: 17)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!.toUpperCase(), style: t.metaSmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              trailing,
            ],
          ),
        ),
        const HairlineDivider(),
      ],
    );

    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: title,
      hint: subtitle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(child: content),
      ),
    );
  }
}
