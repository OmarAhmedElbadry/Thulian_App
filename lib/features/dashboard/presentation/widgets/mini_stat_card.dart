import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";

/// Small outlined shortcut card at the bottom of the dashboard
/// ("05 — STUDY ROOMS / 3 LIVE NOW").
class MiniStatCard extends StatelessWidget {
  const MiniStatCard({
    super.key,
    required this.number,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String number;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.type.metaSmall;

    return Semantics(
      button: true,
      label: "$number $title, $value",
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
            decoration: BoxDecoration(border: Border.all(color: c.ink)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: style,
                    children: [
                      TextSpan(
                        text: "$number \u2014 ",
                        style: TextStyle(color: c.accent),
                      ),
                      TextSpan(text: title.toUpperCase()),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value.toUpperCase(),
                  style: style.copyWith(color: c.inkMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
