import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/utils/format.dart";
import "../../../../core/widgets/hairline_divider.dart";
import "../../domain/entities/note.dart";
import "../note_format.dart";

/// A recent note: number, title, first tag, and a relative date.
class NoteRow extends StatelessWidget {
  const NoteRow({
    super.key,
    required this.number,
    required this.note,
    required this.now,
    required this.onTap,
  });

  final int number;
  final Note note;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final title = note.title.trim().isEmpty ? "Untitled" : note.title;
    final date = noteListDate(note.updatedAt, now);

    return Semantics(
      button: true,
      label: title,
      hint: date,
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
                        child: Text(two(number), style: t.metaSmall),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: t.title.copyWith(fontSize: 17),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (note.tags.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              "#${note.tags.first.toUpperCase()}",
                              style: t.metaSmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(date.toUpperCase(), style: t.metaSmall),
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
