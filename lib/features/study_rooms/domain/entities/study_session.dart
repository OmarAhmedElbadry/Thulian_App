import "package:flutter/foundation.dart";

import "study_room.dart";

enum SessionStatus { idle, running, paused, finished }

enum ParticipantStatus { focusing, onBreak }

@immutable
class SessionParticipant {
  const SessionParticipant({
    required this.id,
    required this.name,
    required this.focusSeconds,
    required this.status,
    this.isYou = false,
  });

  final String id;
  final String name;
  final int focusSeconds;
  final ParticipantStatus status;
  final bool isYou;

  SessionParticipant copyWith({int? focusSeconds, ParticipantStatus? status}) {
    return SessionParticipant(
      id: id,
      name: name,
      focusSeconds: focusSeconds ?? this.focusSeconds,
      status: status ?? this.status,
      isYou: isYou,
    );
  }
}

/// Everything the focus-session screen needs. Durations are display values:
/// in Phase 8 the server owns time and the client only renders it.
@immutable
class SessionState {
  const SessionState({
    required this.room,
    required this.status,
    required this.blockIndex,
    required this.blockCount,
    required this.blockSeconds,
    required this.elapsedSeconds,
    required this.participants,
  });

  final StudyRoom room;
  final SessionStatus status;

  /// 1-based index of the current block.
  final int blockIndex;
  final int blockCount;
  final int blockSeconds;
  final int elapsedSeconds;
  final List<SessionParticipant> participants;

  int get remainingSeconds {
    final remaining = blockSeconds - elapsedSeconds;
    if (remaining < 0) return 0;
    return remaining > blockSeconds ? blockSeconds : remaining;
  }

  double get progress {
    if (blockSeconds == 0) return 0.0;
    final value = elapsedSeconds / blockSeconds;
    return value < 0.0 ? 0.0 : (value > 1.0 ? 1.0 : value);
  }

  /// Participants ordered by focus time, highest first.
  List<SessionParticipant> get leaderboard {
    final sorted = [...participants];
    sorted.sort((a, b) => b.focusSeconds.compareTo(a.focusSeconds));
    return sorted;
  }

  SessionState copyWith({
    SessionStatus? status,
    int? elapsedSeconds,
    List<SessionParticipant>? participants,
  }) {
    return SessionState(
      room: room,
      status: status ?? this.status,
      blockIndex: blockIndex,
      blockCount: blockCount,
      blockSeconds: blockSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      participants: participants ?? this.participants,
    );
  }
}
