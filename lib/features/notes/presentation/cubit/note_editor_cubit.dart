import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../data/notes_mock_store.dart";
import "../../domain/entities/note.dart";
import "../../domain/note_filter.dart";

enum NoteSaveStatus { saved, dirty }

@immutable
class NoteEditorState {
  const NoteEditorState({required this.note, required this.status});

  final Note note;
  final NoteSaveStatus status;

  NoteEditorState copyWith({Note? note, NoteSaveStatus? status}) {
    return NoteEditorState(
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }
}

/// Edits one note with debounced autosave. A brand-new note stays out of the
/// store until it has some content.
class NoteEditorCubit extends Cubit<NoteEditorState> {
  NoteEditorCubit({
    required String noteId,
    required NotesMockStore store,
    DateTime Function()? clock,
    this.autosaveDelay = const Duration(milliseconds: 700),
  }) : _store = store,
       _clock = clock ?? DateTime.now,
       super(_initial(noteId, store, clock ?? DateTime.now));

  final NotesMockStore _store;
  final DateTime Function() _clock;
  final Duration autosaveDelay;
  Timer? _debounce;

  static NoteEditorState _initial(
    String noteId,
    NotesMockStore store,
    DateTime Function() clock,
  ) {
    final existing = store.byId(noteId);
    if (existing != null) {
      return NoteEditorState(note: existing, status: NoteSaveStatus.saved);
    }
    final now = clock();
    return NoteEditorState(
      note: Note(
        id: "note-${now.microsecondsSinceEpoch}",
        title: "",
        body: "",
        tags: const [],
        pinned: false,
        updatedAt: now,
      ),
      status: NoteSaveStatus.saved,
    );
  }

  void _touch(Note note) {
    emit(state.copyWith(note: note, status: NoteSaveStatus.dirty));
    _debounce?.cancel();
    _debounce = Timer(autosaveDelay, saveNow);
  }

  void setTitle(String value) => _touch(state.note.copyWith(title: value));

  void setBody(String value) => _touch(state.note.copyWith(body: value));

  void togglePin() => _touch(state.note.copyWith(pinned: !state.note.pinned));

  void addTag(String raw) {
    final tag = normalizeTag(raw);
    if (tag == null || state.note.tags.contains(tag)) return;
    _touch(state.note.copyWith(tags: [...state.note.tags, tag]));
  }

  void removeTag(String tag) {
    _touch(
      state.note.copyWith(
        tags: state.note.tags.where((t) => t != tag).toList(),
      ),
    );
  }

  /// Persists immediately (also used by the debounce timer).
  void saveNow() {
    _debounce?.cancel();
    _debounce = null;
    var note = state.note;
    if (!note.isBlank) {
      note = note.copyWith(updatedAt: _clock());
      _store.upsert(note);
    }
    emit(NoteEditorState(note: note, status: NoteSaveStatus.saved));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    if (state.status == NoteSaveStatus.dirty) saveNow();
    return super.close();
  }
}
