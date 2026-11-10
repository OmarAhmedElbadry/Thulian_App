import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/widgets/dashed_border.dart";
import "../../domain/entities/profile_snapshot.dart";

/// A dashed-outline achievement stamp ("14 / STREAK"). Locked stamps are muted.
class StampTile extends StatelessWidget {
  const StampTile({super.key, required this.stamp});

  final Stamp stamp;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;

    return Semantics(
      label: stamp.unlocked
          ? "${stamp.label}, ${stamp.value}"
          : "Locked achievement",
      child: ExcludeSemantics(
        child: DashedBorder(
          color: stamp.unlocked ? c.ink : c.inkMuted,
          child: Container(
            height: 76,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stamp.value,
                  style: t.stat.copyWith(
                    fontSize: 26,
                    color: stamp.unlocked ? c.accent : c.inkMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stamp.label.toUpperCase(),
                  style: t.metaSmall.copyWith(
                    color: stamp.unlocked ? c.ink : c.inkMuted,
                  ),
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
