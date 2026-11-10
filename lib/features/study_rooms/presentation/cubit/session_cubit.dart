import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";

import "../../data/rooms_mock_data.dart";
import "../../domain/entities/study_room.dart";
import "../../domain/entities/study_session.dart";

/// Drives the focus-session screen from a local clock. This is a Phase 2
/// stand-in: in Phase 8 the state comes from server timestamps and the timer
/// is display-only.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(StudyRoom room, {this.tickEvery = const Duration(seconds: 1)})
    : super(_initial(room)) {
    if (state.status == SessionStatus.running) _startTimer();
  }

  final Duration tickEvery;
  Timer? _timer;

  static SessionState _initial(StudyRoom room) {
    final blockSeconds = room.blockMinutes * 60;
    if (room.isLive) {
      return SessionState(
        room: room,
        status: SessionStatus.running,
        blockIndex: 3,
        blockCount: RoomsMockData.blockCount,
        blockSeconds: blockSeconds,
        elapsedSeconds: (blockSeconds * RoomsMockData.liveProgress).round(),
        participants: RoomsMockData.liveParticipants,
      );
    }
    return SessionState(
      room: room,
      status: SessionStatus.idle,
      blockIndex: 1,
      blockCount: RoomsMockData.blockCount,
      blockSeconds: blockSeconds,
      elapsedSeconds: 0,
      participants: const [
        SessionParticipant(
          id: "you",
          name: "Amira",
          focusSeconds: 0,
          status: ParticipantStatus.focusing,
          isYou: true,
        ),
      ],
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(tickEvery, (_) => tick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void start() {
    if (state.status != SessionStatus.idle) return;
    emit(state.copyWith(status: SessionStatus.running, elapsedSeconds: 0));
    _startTimer();
  }

  void pause() {
    if (state.status != SessionStatus.running) return;
    _stopTimer();
    emit(state.copyWith(status: SessionStatus.paused));
  }

  void resume() {
    if (state.status != SessionStatus.paused) return;
    emit(state.copyWith(status: SessionStatus.running));
    _startTimer();
  }

  /// Advances the clock by one second. Public so tests can drive it.
  void tick() {
    if (state.status != SessionStatus.running) return;

    final participants = [
      for (final p in state.participants)
        p.status == ParticipantStatus.focusing
            ? p.copyWith(focusSeconds: p.focusSeconds + 1)
            : p,
    ];
    final elapsed = state.elapsedSeconds + 1;

    if (elapsed >= state.blockSeconds) {
      _stopTimer();
      emit(
        state.copyWith(
          status: SessionStatus.finished,
          elapsedSeconds: state.blockSeconds,
          participants: participants,
        ),
      );
      return;
    }
    emit(state.copyWith(elapsedSeconds: elapsed, participants: participants));
  }

  void leave() => _stopTimer();

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
