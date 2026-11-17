import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../data/notes_mock_store.dart";
import "../../domain/entities/note.dart";
import "../../domain/note_filter.dart";
import "../../domain/repositories/notes_repository.dart";

enum NoteSaveStatus { saved, dirty, saving, error }

@immutable
class NoteEditorState {
  const NoteEditorState({
    required this.note,
    required this.status,
    this.loadError = false,
  });

  final Note note;
  final NoteSaveStatus status;
  final bool loadError;

  NoteEditorState copyWith({
    Note? note,
    NoteSaveStatus? status,
    bool? loadError,
  }) {
    return NoteEditorState(
      note: note ?? this.note,
      status: status ?? this.status,
      loadError: loadError ?? this.loadError,
    );
  }
}

/// Edits one note with debounced autosave. A brand-new note stays out of the
/// store until it has some content.
class NoteEditorCubit extends Cubit<NoteEditorState> {
  NoteEditorCubit({
    required String noteId,
    required NotesMockStore store,
    this.repository,
    Note? initialNote,
    DateTime Function()? clock,
    this.autosaveDelay = const Duration(milliseconds: 700),
  }) : _store = store,
       _clock = clock ?? DateTime.now,
       super(_initial(noteId, store, clock ?? DateTime.now, initialNote));

  final NotesMockStore _store;
  final NotesRepository? repository;
  final DateTime Function() _clock;
  final Duration autosaveDelay;
  Timer? _debounce;
  int _revision = 0;

  static NoteEditorState _initial(
    String noteId,
    NotesMockStore store,
    DateTime Function() clock,
    Note? initialNote,
  ) {
    final existing = initialNote ?? store.byId(noteId);
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
    _revision++;
    emit(state.copyWith(note: note, status: NoteSaveStatus.dirty));
    _debounce?.cancel();
    _debounce = Timer(autosaveDelay, () => saveNow());
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
  Future<bool> saveNow() async {
    _debounce?.cancel();
    _debounce = null;
    final revision = _revision;
    var note = state.note;
    if (!note.isBlank) {
      note = note.copyWith(updatedAt: _clock());
      final notesRepository = repository;
      if (notesRepository == null) {
        _store.upsert(note);
      } else {
        emit(state.copyWith(status: NoteSaveStatus.saving, loadError: false));
        try {
          await notesRepository.saveNote(note);
        } catch (_) {
          if (revision == _revision) {
            emit(state.copyWith(status: NoteSaveStatus.error));
          }
          return false;
        }
      }
    }
    if (revision == _revision) {
      emit(NoteEditorState(note: note, status: NoteSaveStatus.saved));
    }
    return true;
  }

  Future<void> loadNote(String id) async {
    final notesRepository = repository;
    if (notesRepository == null || id == "new") return;
    try {
      final note = await notesRepository.getNote(id);
      if (isClosed || note == null || _revision != 0) return;
      emit(NoteEditorState(note: note, status: NoteSaveStatus.saved));
    } catch (_) {
      if (isClosed || _revision != 0) return;
      emit(state.copyWith(loadError: true));
    }
  }

  Future<void> deleteNote() async {
    _revision++;
    _debounce?.cancel();
    _debounce = null;
    emit(state.copyWith(status: NoteSaveStatus.saved));
    final notesRepository = repository;
    if (notesRepository == null) {
      _store.notes.value = _store.notes.value
          .where((note) => note.id != state.note.id)
          .toList();
      return;
    }
    await notesRepository.deleteNote(state.note.id);
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    if (state.status == NoteSaveStatus.dirty ||
        state.status == NoteSaveStatus.error) {
      await saveNow();
    }
    await super.close();
  }
}
