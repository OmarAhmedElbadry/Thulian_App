import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/utils/format.dart";
import "../../domain/entities/note.dart";
import "../note_format.dart";

/// Bordered card for a pinned note ("PIN 01", title, edited stamp).
class PinnedNoteCard extends StatelessWidget {
  const PinnedNoteCard({
    super.key,
    required this.index,
    required this.note,
    required this.onTap,
  });

  final int index;
  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;
    final title = note.title.trim().isEmpty ? "Untitled" : note.title;

    return Semantics(
      button: true,
      label: "Pinned note: $title",
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: c.ink)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("PIN ${two(index)}", style: t.metaSmall),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: t.title.copyWith(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(editedLabel(note.updatedAt), style: t.metaSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
