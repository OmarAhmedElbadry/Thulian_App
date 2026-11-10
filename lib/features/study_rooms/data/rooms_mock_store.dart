import "package:flutter/foundation.dart";

import "../domain/entities/study_room.dart";
import "rooms_mock_data.dart";

/// In-memory stand-in for the rooms repository (Phase 2 only).
class RoomsMockStore {
  RoomsMockStore({List<StudyRoom>? seed})
    : rooms = ValueNotifier<List<StudyRoom>>(
        List.of(seed ?? RoomsMockData.rooms),
      );

  static final RoomsMockStore instance = RoomsMockStore();

  final ValueNotifier<List<StudyRoom>> rooms;

  StudyRoom? byId(String id) {
    for (final room in rooms.value) {
      if (room.id == id) return room;
    }
    return null;
  }

  /// Looks a room up by invite code; case and dashes are ignored.
  StudyRoom? byCode(String code) {
    final normalized = code.replaceAll("-", "").trim().toUpperCase();
    if (normalized.isEmpty) return null;
    for (final room in rooms.value) {
      if (room.inviteCode == normalized) return room;
    }
    return null;
  }

  StudyRoom create({
    required String name,
    required RoomVisibility visibility,
    required int blockMinutes,
  }) {
    final number =
        rooms.value.fold<int>(0, (max, r) => r.number > max ? r.number : max) +
        1;
    final room = StudyRoom(
      id: "room-$number",
      number: number,
      name: name.trim(),
      visibility: visibility,
      insideCount: 0,
      blockMinutes: blockMinutes,
      status: RoomStatus.idle,
      inviteCode: _uniqueCode(name),
      isOwner: true,
    );
    rooms.value = [room, ...rooms.value];
    return room;
  }

  String _uniqueCode(String name) {
    final letters = name.toUpperCase().replaceAll(RegExp("[^A-Z]"), "");
    final prefix = "${letters}XX".substring(0, 2);
    var seed = name.hashCode.abs();
    while (true) {
      final digits = (1000 + seed % 9000).toString();
      final code = "$prefix$digits";
      if (byCode(code) == null) return code;
      seed += 7;
    }
  }
}
