import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/app_link.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../../../../core/widgets/chip_filter.dart";
import "../../../../core/widgets/display_title.dart";
import "../../../../core/widgets/empty_state.dart";
import "../../../../core/widgets/journal_body.dart";
import "../../../../core/widgets/record_header.dart";
import "../../../../core/widgets/section_header.dart";
import "../../data/notes_mock_store.dart";
import "../../domain/entities/note.dart";
import "../../domain/note_filter.dart";
import "../widgets/note_row.dart";
import "../widgets/pinned_note_card.dart";

/// Notes index (P. 05 / 12): search, tag filters, pinned cards and recents.
class NotesPage extends StatefulWidget {
  const NotesPage({super.key, this.now});

  /// Injectable clock for the relative date labels.
  final DateTime? now;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  static const _recentLimit = 4;

  final _search = TextEditingController();
  String _query = "";
  String? _tag;
  bool _showAll = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(Note note) => context.push(AppRoutes.noteEditorPath(note.id));

  int _byNewest(Note a, Note b) => b.updatedAt.compareTo(a.updatedAt);

  @override
  Widget build(BuildContext context) {
    final now = widget.now ?? DateTime.now();

    return Column(
      children: [
        const RecordHeader(
          label: "NOTES INDEX \u00b7 N\u00ba 0311",
          page: "P. 05 / 12",
        ),
        Expanded(
          child: ValueListenableBuilder<List<Note>>(
            valueListenable: NotesMockStore.instance.notes,
            builder: (context, all, _) {
              final filtered = filterNotes(all, query: _query, tag: _tag);
              final pinned = filtered.where((n) => n.pinned).toList()
                ..sort(_byNewest);
              final recent = filtered.where((n) => !n.pinned).toList()
                ..sort(_byNewest);
              final visible = _showAll
                  ? recent
                  : recent.take(_recentLimit).toList();

              return JournalBody(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(child: DisplayTitle("Notes")),
                      AppButton(
                        label: "+ New",
                        showArrow: false,
                        onPressed: () => context.push(AppRoutes.noteNew),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  AppTextField(
                    label: "Search",
                    controller: _search,
                    hint: "Title, tag or text\u2026",
                    textInputAction: TextInputAction.search,
                    onChanged: (value) => setState(() {
                      _query = value;
                      _showAll = false;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Wrap(
                    spacing: AppSpacing.s,
                    runSpacing: AppSpacing.s,
                    children: [
                      ChipFilter(
                        label: "All",
                        selected: _tag == null,
                        onTap: () => setState(() => _tag = null),
                      ),
                      for (final tag in quickTags)
                        ChipFilter(
                          label: "#$tag",
                          selected: _tag == tag,
                          onTap: () => setState(() => _tag = tag),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  if (filtered.isEmpty)
                    const EmptyState(
                      label: "No matches",
                      title: "Nothing filed under that.",
                      message: "Try a different word or clear the filter.",
                    )
                  else ...[
                    if (pinned.isNotEmpty) ...[
                      SectionHeader(
                        number: "01",
                        title: "Pinned",
                        trailing: "${pinned.length}",
                        strong: true,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final width = (constraints.maxWidth - 8) / 2;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var i = 0; i < pinned.length; i++)
                                SizedBox(
                                  width: width,
                                  child: PinnedNoteCard(
                                    index: i + 1,
                                    note: pinned[i],
                                    onTap: () => _open(pinned[i]),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.l),
                    ],
                    if (recent.isNotEmpty) ...[
                      SectionHeader(
                        number: pinned.isEmpty ? "01" : "02",
                        title: "Recent",
                        trailing: "${visible.length} of ${filtered.length}",
                        strong: true,
                      ),
                      for (var i = 0; i < visible.length; i++)
                        NoteRow(
                          number: pinned.length + i + 1,
                          note: visible[i],
                          now: now,
                          onTap: () => _open(visible[i]),
                        ),
                      if (recent.length > _recentLimit)
                        AppLink(
                          label: _showAll ? "Show fewer" : "Show all",
                          onTap: () => setState(() => _showAll = !_showAll),
                        ),
                    ],
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
