import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/utils/format.dart";
import "../../../../core/widgets/hairline_divider.dart";
import "../../domain/entities/study_room.dart";

/// One room in the index: number, name, meta line and a LIVE / IDLE marker.
class RoomRow extends StatelessWidget {
  const RoomRow({
    super.key,
    required this.index,
    required this.room,
    required this.onTap,
  });

  final int index;
  final StudyRoom room;
  final VoidCallback onTap;

  String get _meta {
    final visibility = room.visibility.name.toUpperCase();
    final tail = room.opensAt != null
        ? "OPENS ${room.opensAt}"
        : "${room.blockMinutes} MIN BLOCKS";
    return "$visibility \u00b7 ${room.insideCount} INSIDE \u00b7 $tail";
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;

    return Semantics(
      button: true,
      label: room.name,
      hint: "${room.isLive ? "Live" : "Idle"}, $_meta",
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(two(index), style: t.metaSmall),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: t.title.copyWith(fontSize: 17),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(_meta, style: t.metaSmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: room.isLive
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6, height: 6, color: c.accent),
                                const SizedBox(width: 6),
                                Text(
                                  "LIVE",
                                  style: t.metaSmall.copyWith(
                                    color: c.accent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : Text("IDLE", style: t.metaSmall),
                    ),
                  ],
                ),
              ),
              const HairlineDivider(),
            ],
          ),
        ),
      ),
    );
  }
}
