import "package:flutter/foundation.dart";

@immutable
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.pinned,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;

  /// Lower-case tags without the leading "#".
  final List<String> tags;
  final bool pinned;
  final DateTime updatedAt;

  bool get isBlank => title.trim().isEmpty && body.trim().isEmpty;

  int get wordCount {
    final text = body.trim();
    return text.isEmpty ? 0 : text.split(RegExp(r"\s+")).length;
  }

  Note copyWith({
    String? title,
    String? body,
    List<String>? tags,
    bool? pinned,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      pinned: pinned ?? this.pinned,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
