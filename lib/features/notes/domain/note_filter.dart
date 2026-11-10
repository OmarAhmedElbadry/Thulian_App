import "entities/note.dart";

/// Tags offered as quick filters on the notes index.
const quickTags = ["study", "ideas", "log"];

/// Filters [notes] by free-text [query] (title, body or tag; a leading "#" is
/// ignored) and an optional exact [tag].
List<Note> filterNotes(List<Note> notes, {String query = "", String? tag}) {
  var needle = query.trim().toLowerCase();
  final tagOnly = needle.startsWith("#");
  if (tagOnly) needle = needle.substring(1);

  return notes.where((note) {
    if (tag != null && !note.tags.contains(tag)) return false;
    if (needle.isEmpty) return true;
    if (tagOnly) return note.tags.any((t) => t.contains(needle));
    return note.title.toLowerCase().contains(needle) ||
        note.body.toLowerCase().contains(needle) ||
        note.tags.any((t) => t.contains(needle));
  }).toList();
}

/// Lower-cases, strips "#" and whitespace. Returns null when nothing is left.
String? normalizeTag(String raw) {
  final cleaned = raw
      .trim()
      .toLowerCase()
      .replaceAll("#", "")
      .replaceAll(RegExp(r"\s+"), "");
  return cleaned.isEmpty ? null : cleaned;
}
