import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../../../../core/di/injection.dart";
import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_sizes.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/app_dialog.dart";
import "../../../../core/widgets/hairline_divider.dart";
import "../../../../core/widgets/page_nav_row.dart";
import "../../../../core/widgets/pinned_footer.dart";
import "../../../../core/widgets/record_header.dart";
import "../../data/notes_mock_store.dart";
import "../../domain/entities/note.dart";
import "../../domain/repositories/notes_repository.dart";
import "../cubit/note_editor_cubit.dart";
import "../note_format.dart";
import "../widgets/tags_sheet.dart";

/// Note editor (P. 06 / 12). Autosaves through [NoteEditorCubit]; "SAVE NOTE"
/// flushes immediately and returns to the index. [noteId] of "new" opens a
/// blank note.
class NoteEditorPage extends StatelessWidget {
  const NoteEditorPage({super.key, required this.noteId, this.initialNote});

  final String noteId;
  final Note? initialNote;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteEditorCubit>(
      create: (_) {
        final cubit = NoteEditorCubit(
          noteId: noteId,
          store: NotesMockStore.instance,
          repository: sl.isRegistered<NotesRepository>()
              ? sl<NotesRepository>()
              : null,
          initialNote: initialNote,
        );
        if (initialNote == null) cubit.loadNote(noteId);
        return cubit;
      },
      child: _NoteEditorView(existing: noteId != "new"),
    );
  }
}

class _NoteEditorView extends StatefulWidget {
  const _NoteEditorView({required this.existing});

  final bool existing;

  @override
  State<_NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<_NoteEditorView> {
  late final TextEditingController _title;
  late final TextEditingController _body;

  @override
  void initState() {
    super.initState();
    final note = context.read<NoteEditorCubit>().state.note;
    _title = TextEditingController(text: note.title);
    _body = TextEditingController(text: note.body);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.notes);
    }
  }

  Future<void> _back() async {
    final saved = await context.read<NoteEditorCubit>().saveNow();
    if (!mounted) return;
    if (!saved) {
      _toast("Could not save your note. Check your connection and retry.");
      return;
    }
    _close();
  }

  Future<void> _save() async {
    final cubit = context.read<NoteEditorCubit>();
    final saved = await cubit.saveNow();
    if (!mounted) return;
    if (!saved) {
      _toast("Could not save your note. Check your connection and retry.");
      return;
    }
    if (!cubit.state.note.isBlank) {
      _toast("Note filed.");
    }
    _close();
  }

  Future<void> _delete(Note note) async {
    final confirmed = await showAppDialog(
      context,
      recordLabel: "NOTE · ${note.title.isEmpty ? 'UNTITLED' : note.title}",
      title: "Delete this note?",
      message: "This note will be permanently removed.",
      confirmLabel: "Delete",
      cancelLabel: "Keep note",
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<NoteEditorCubit>().deleteNote();
      if (!mounted) return;
      _close();
    } catch (_) {
      if (mounted) _toast("Could not delete this note. Try again.");
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;
    final cubit = context.read<NoteEditorCubit>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: BlocListener<NoteEditorCubit, NoteEditorState>(
          listenWhen: (previous, next) => previous.note.id != next.note.id,
          listener: (context, state) {
            _title.value = TextEditingValue(text: state.note.title);
            _body.value = TextEditingValue(text: state.note.body);
          },
          child: BlocBuilder<NoteEditorCubit, NoteEditorState>(
            builder: (context, state) {
              final note = state.note;
              final label = [
                if (note.tags.isNotEmpty)
                  note.tags.first.toUpperCase()
                else
                  "NOTE",
                if (note.pinned) "PINNED",
              ].join(" \u00b7 ");
              final saving =
                  state.status == NoteSaveStatus.dirty ||
                  state.status == NoteSaveStatus.saving;

              return Column(
                children: [
                  const RecordHeader(
                    label: "NOTE N\u00ba 0312",
                    page: "P. 06 / 12",
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSizes.maxContentWidth,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageMargin,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PageNavRow(
                                backLabel: "Notes",
                                onBack: _back,
                                trailing: state.loadError
                                    ? "COULD NOT LOAD"
                                    : state.status == NoteSaveStatus.error
                                    ? "SAVE FAILED"
                                    : modifiedLabel(note.updatedAt),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.l),
                                  decoration: BoxDecoration(
                                    color: dark ? c.surface : c.background,
                                    border: Border.all(color: c.ink),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
                                          style: t.metaSmall.copyWith(
                                            color: c.accent,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.m),
                                        TextField(
                                          controller: _title,
                                          onChanged: cubit.setTitle,
                                          maxLines: null,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          cursorColor: c.accent,
                                          style: t.display.copyWith(
                                            fontSize: 26,
                                          ),
                                          decoration: InputDecoration.collapsed(
                                            hintText: "Untitled",
                                            hintStyle: t.display.copyWith(
                                              fontSize: 26,
                                              color: c.inkMuted,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.m),
                                        const HairlineDivider(),
                                        const SizedBox(height: AppSpacing.m),
                                        TextField(
                                          controller: _body,
                                          onChanged: cubit.setBody,
                                          minLines: 10,
                                          maxLines: null,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          keyboardType: TextInputType.multiline,
                                          cursorColor: c.accent,
                                          style: t.body,
                                          decoration: InputDecoration.collapsed(
                                            hintText: "Start writing\u2026",
                                            hintStyle: t.body.copyWith(
                                              color: c.inkMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.m),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () =>
                                          showTagsSheet(context, cubit),
                                      child: Semantics(
                                        button: true,
                                        label: "Edit tags",
                                        child: ExcludeSemantics(
                                          child: Wrap(
                                            spacing: 10,
                                            children: [
                                              for (final tag in note.tags)
                                                Text(
                                                  "#${tag.toUpperCase()}",
                                                  style: t.metaSmall.copyWith(
                                                    color: c.ink,
                                                  ),
                                                ),
                                              Text("+ TAG", style: t.metaSmall),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.m),
                                  Text(
                                    "${note.wordCount} WORDS"
                                    "${saving ? " \u00b7 SAVING" : ""}",
                                    style: t.metaSmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.m),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  PinnedFooter(
                    child: Row(
                      children: [
                        if (widget.existing) ...[
                          IconButton(
                            tooltip: "Delete note",
                            onPressed: () => _delete(note),
                            icon: Icon(Icons.delete_outline, color: c.ink),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            label: note.pinned ? "Unpin" : "Pin",
                            variant: AppButtonVariant.ghost,
                            showArrow: false,
                            onPressed: cubit.togglePin,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          flex: 3,
                          child: AppButton(
                            label: "Save note",
                            loading: state.status == NoteSaveStatus.saving,
                            onPressed: _save,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
