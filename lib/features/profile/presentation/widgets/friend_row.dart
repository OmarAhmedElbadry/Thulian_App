import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/utils/format.dart";
import "../../../../core/widgets/hairline_divider.dart";
import "../../domain/entities/profile_snapshot.dart";

/// One friend in the weekly focus ranking: number, name, hours:minutes.
class FriendRow extends StatelessWidget {
  const FriendRow({super.key, required this.number, required this.friend});

  final int number;
  final FriendStat friend;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final time =
        "${two(friend.focusMinutes ~/ 60)}:${two(friend.focusMinutes % 60)} h";

    return Semantics(
      label: "${friend.name}, $time this week",
      child: ExcludeSemantics(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(two(number), style: t.metaSmall),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      friend.name,
                      style: t.title.copyWith(fontSize: 17),
                    ),
                  ),
                  Text(time, style: t.meta.copyWith(letterSpacing: 0)),
                ],
              ),
            ),
            const HairlineDivider(),
          ],
        ),
      ),
    );
  }
}
