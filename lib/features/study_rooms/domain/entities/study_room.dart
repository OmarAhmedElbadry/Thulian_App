import "package:flutter/foundation.dart";

enum RoomVisibility { public, private }

enum RoomStatus { live, idle }

/// A study room as listed on the rooms index (Phase 2 mock entity).
@immutable
class StudyRoom {
  const StudyRoom({
    required this.id,
    required this.number,
    required this.name,
    required this.visibility,
    required this.insideCount,
    required this.blockMinutes,
    required this.status,
    required this.inviteCode,
    this.opensAt,
    this.isOwner = false,
  });

  final String id;

  /// Archival record number ("ROOM N 114").
  final int number;
  final String name;
  final RoomVisibility visibility;
  final int insideCount;

  /// Length of one focus block, in minutes.
  final int blockMinutes;
  final RoomStatus status;

  /// Upper-case code without separators, e.g. "KX4821".
  final String inviteCode;

  /// Opening time for a scheduled room, e.g. "22:00".
  final String? opensAt;
  final bool isOwner;

  bool get isLive => status == RoomStatus.live;

  /// "KX-4821"
  String get displayCode => inviteCode.length == 6
      ? "${inviteCode.substring(0, 2)}-${inviteCode.substring(2)}"
      : inviteCode;
}
