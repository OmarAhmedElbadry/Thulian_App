import "../entities/note.dart";

abstract interface class NotesRepository {
  Stream<List<Note>> watchNotes();
  Future<Note?> getNote(String id);
  Future<void> saveNote(Note note);
  Future<void> deleteNote(String id);
}
