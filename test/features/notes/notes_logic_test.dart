import "package:flutter_test/flutter_test.dart";
import "package:thulian/features/notes/data/notes_mock_data.dart";
import "package:thulian/features/notes/data/notes_mock_store.dart";
import "package:thulian/features/notes/domain/entities/note.dart";
import "package:thulian/features/notes/domain/note_filter.dart";
import "package:thulian/features/notes/presentation/cubit/note_editor_cubit.dart";
import "package:thulian/features/notes/presentation/note_format.dart";

void main() {
  final now = DateTime(2026, 11, 3, 10, 0);
  final notes = NotesMockData.seed(now);

  group("filterNotes", () {
    test("seed has 12 notes, 2 pinned", () {
      expect(notes, hasLength(12));
      expect(notes.where((n) => n.pinned), hasLength(2));
    });

    test("matches title, body and tags", () {
      expect(
        filterNotes(notes, query: "thesis").map((n) => n.id),
        containsAll(["thesis-outline", "thesis-refs"]),
      );
      expect(filterNotes(notes, query: "retrieval").single.id, "lecture-07");
      expect(filterNotes(notes, query: "#memory").single.id, "lecture-07");
    });

    test("tag filter and query combine", () {
      final logs = filterNotes(notes, tag: "log");
      expect(logs.every((n) => n.tags.contains("log")), true);
      expect(filterNotes(notes, tag: "log", query: "gym"), hasLength(2));
      expect(filterNotes(notes, query: "zzzz"), isEmpty);
    });
  });

  test("normalizeTag", () {
    expect(normalizeTag("  #Deep Work "), "deepwork");
    expect(normalizeTag("###"), isNull);
  });

  group("note dates", () {
    test("today, this week, older", () {
      expect(noteListDate(DateTime(2026, 11, 3, 9, 12), now), "Today 09:12");
      expect(noteListDate(DateTime(2026, 11, 2, 7, 40), now), "Mon 02.11");
      expect(noteListDate(DateTime(2026, 10, 20, 7, 40), now), "20.10");
    });

    test("edited and modified labels", () {
      final d = DateTime(2026, 11, 2, 21, 14);
      expect(editedLabel(d), "Edited 02.11 \u00b7 21:14");
      expect(modifiedLabel(d), "Modified 02.11 \u00b7 21:14");
    });
  });

  test("word count ignores extra whitespace", () {
    final note = Note(
      id: "x",
      title: "",
      body: "  one two\n\nthree  ",
      tags: const [],
      pinned: false,
      updatedAt: now,
    );
    expect(note.wordCount, 3);
  });

  group("NoteEditorCubit", () {
    NoteEditorCubit make(NotesMockStore store, String id) {
      final cubit = NoteEditorCubit(
        noteId: id,
        store: store,
        clock: () => now,
        autosaveDelay: const Duration(hours: 1),
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test("a blank new note is never stored", () {
      final store = NotesMockStore(seed: const [], now: now);
      make(store, "new").saveNow();
      expect(store.notes.value, isEmpty);
    });

    test("typing marks the note dirty; saveNow stores it", () {
      final store = NotesMockStore(seed: const [], now: now);
      final cubit = make(store, "new")
        ..setTitle("Hello")
        ..setBody("two words");
      expect(cubit.state.status, NoteSaveStatus.dirty);
      cubit.saveNow();
      expect(cubit.state.status, NoteSaveStatus.saved);
      expect(store.notes.value.single.title, "Hello");
      expect(store.notes.value.single.wordCount, 2);
    });

    test("editing an existing note updates it in place", () {
      final store = NotesMockStore(seed: notes, now: now);
      make(store, "gym-v2")
        ..togglePin()
        ..addTag("#Fitness")
        ..addTag("fitness")
        ..saveNow();
      final updated = store.byId("gym-v2")!;
      expect(updated.pinned, true);
      expect(updated.tags, ["log", "fitness"]);
      expect(store.notes.value, hasLength(12));
    });
  });
}
