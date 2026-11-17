import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import "../domain/entities/note.dart";
import "../domain/repositories/notes_repository.dart";

class FirebaseNotesRepository implements NotesRepository {
  FirebaseNotesRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _notes {
    final user = _auth.currentUser;
    if (user == null) throw StateError("Sign in to access your notes.");
    return _firestore.collection("users").doc(user.uid).collection("notes");
  }

  @override
  Stream<List<Note>> watchNotes() {
    try {
      return _notes.snapshots().map((snapshot) {
        final notes = snapshot.docs.map(_fromDocument).toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return notes;
      });
    } catch (error, stackTrace) {
      return Stream.error(error, stackTrace);
    }
  }

  @override
  Future<Note?> getNote(String id) async {
    final snapshot = await _notes.doc(id).get();
    if (!snapshot.exists) return null;
    return _fromDocument(snapshot);
  }

  @override
  Future<void> saveNote(Note note) async {
    final reference = _notes.doc(note.id);
    final existing = await reference.get();
    await reference.set({
      "title": note.title,
      "body": note.body,
      "tags": note.tags,
      "pinned": note.pinned,
      if (!existing.exists) "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteNote(String id) => _notes.doc(id).delete();

  Note _fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? const <String, dynamic>{};
    return Note(
      id: document.id,
      title: data["title"] as String? ?? "",
      body: data["body"] as String? ?? "",
      tags: (data["tags"] as List<dynamic>? ?? const []).cast<String>(),
      pinned: data["pinned"] as bool? ?? false,
      updatedAt: _date(data["updatedAt"]),
    );
  }

  DateTime _date(Object? value) =>
      value is Timestamp ? value.toDate() : DateTime.now();
}
