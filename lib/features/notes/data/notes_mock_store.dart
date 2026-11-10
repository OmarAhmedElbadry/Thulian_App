import "package:flutter/foundation.dart";

import "../domain/entities/note.dart";
import "notes_mock_data.dart";

/// In-memory stand-in for the notes repository (Phase 2 only).
class NotesMockStore {
  NotesMockStore({List<Note>? seed, DateTime? now})
    : notes = ValueNotifier<List<Note>>(
        List.of(seed ?? NotesMockData.seed(now ?? DateTime.now())),
      );

  static final NotesMockStore instance = NotesMockStore();

  final ValueNotifier<List<Note>> notes;

  Note? byId(String id) {
    for (final note in notes.value) {
      if (note.id == id) return note;
    }
    return null;
  }

  void upsert(Note note) {
    final list = [...notes.value];
    final index = list.indexWhere((n) => n.id == note.id);
    if (index == -1) {
      list.add(note);
    } else {
      list[index] = note;
    }
    notes.value = list;
  }
}
