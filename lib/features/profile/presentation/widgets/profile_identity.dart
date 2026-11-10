import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../domain/entities/profile_snapshot.dart";
import "../profile_format.dart";

/// Avatar plate, handle and name, plus the level line with an XP rule.
class ProfileIdentity extends StatelessWidget {
  const ProfileIdentity({super.key, required this.profile});

  final ProfileSnapshot profile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              color: c.accentSoft,
              child: Text(
                profile.initial,
                style: t.display.copyWith(
                  fontSize: 32,
                  color: const Color(0xFF2F2F2F),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("@${profile.handle.toUpperCase()}", style: t.metaSmall),
                  const SizedBox(height: 4),
                  Text(
                    profile.name,
                    style: t.display.copyWith(fontSize: 30, height: 1.0),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "LEVEL ${profile.level}",
              style: t.metaSmall.copyWith(
                color: c.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${formatThousands(profile.xp)} / "
              "${formatThousands(profile.xpForNext)} XP",
              style: t.metaSmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Semantics(
          label:
              "Level ${profile.level}, ${(profile.levelProgress * 100).round()} percent to next level",
          child: ExcludeSemantics(
            child: SizedBox(
              height: 3,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: c.hairline),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: profile.levelProgress,
                    child: ColoredBox(color: c.accent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
