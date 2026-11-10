import "package:flutter_test/flutter_test.dart";
import "package:thulian/features/study_rooms/data/rooms_mock_data.dart";
import "package:thulian/features/study_rooms/data/rooms_mock_store.dart";
import "package:thulian/features/study_rooms/domain/entities/study_room.dart";
import "package:thulian/features/study_rooms/domain/entities/study_session.dart";
import "package:thulian/features/study_rooms/presentation/cubit/session_cubit.dart";

void main() {
  final live = RoomsMockData.rooms.first; // 50-minute blocks, live
  final idle = RoomsMockData.rooms.last;

  SessionCubit make(StudyRoom room) {
    final cubit = SessionCubit(room, tickEvery: const Duration(hours: 1));
    addTearDown(cubit.close);
    return cubit;
  }

  group("SessionCubit", () {
    test("a live room starts running with 17:42 remaining", () {
      final cubit = make(live);
      expect(cubit.state.status, SessionStatus.running);
      expect(cubit.state.remainingSeconds, 1062);
      expect(cubit.state.blockIndex, 3);
    });

    test("tick advances the clock and only focusing people gain time", () {
      final cubit = make(live);
      final lenaBefore = cubit.state.participants
          .firstWhere((p) => p.id == "lena")
          .focusSeconds;
      final youBefore = cubit.state.participants
          .firstWhere((p) => p.isYou)
          .focusSeconds;
      cubit.tick();
      expect(cubit.state.remainingSeconds, 1061);
      expect(
        cubit.state.participants.firstWhere((p) => p.id == "lena").focusSeconds,
        lenaBefore,
      );
      expect(
        cubit.state.participants.firstWhere((p) => p.isYou).focusSeconds,
        youBefore + 1,
      );
    });

    test("pause freezes the clock and resume continues it", () {
      final cubit = make(live)..pause();
      expect(cubit.state.status, SessionStatus.paused);
      final remaining = cubit.state.remainingSeconds;
      cubit.tick();
      expect(cubit.state.remainingSeconds, remaining);
      cubit
        ..resume()
        ..tick();
      expect(cubit.state.remainingSeconds, remaining - 1);
    });

    test("an idle room waits for start, then runs from zero", () {
      final cubit = make(idle);
      expect(cubit.state.status, SessionStatus.idle);
      cubit.tick();
      expect(cubit.state.elapsedSeconds, 0);
      cubit.start();
      expect(cubit.state.status, SessionStatus.running);
      cubit.tick();
      expect(cubit.state.elapsedSeconds, 1);
    });

    test("the block finishes when time runs out", () {
      final cubit = make(live);
      for (var i = 0; i < 1062; i++) {
        cubit.tick();
      }
      expect(cubit.state.status, SessionStatus.finished);
      expect(cubit.state.remainingSeconds, 0);
      expect(cubit.state.progress, 1.0);
    });

    test("leaderboard is ordered by focus time", () {
      final board = make(live).state.leaderboard;
      expect(board.map((p) => p.name), ["Karim", "Lena", "Amira", "Tomas"]);
    });
  });

  group("RoomsMockStore", () {
    test("finds rooms by code, ignoring case and dashes", () {
      final store = RoomsMockStore();
      expect(store.byCode("kx-4821")?.id, "library-3f");
      expect(store.byCode("KX4821")?.id, "library-3f");
      expect(store.byCode("ZZZZ"), isNull);
      expect(store.byCode(""), isNull);
    });

    test("create adds an idle room with a unique 6-character code", () {
      final store = RoomsMockStore();
      final room = store.create(
        name: "Deep Work",
        visibility: RoomVisibility.public,
        blockMinutes: 90,
      );
      expect(room.status, RoomStatus.idle);
      expect(room.isOwner, true);
      expect(room.inviteCode, hasLength(6));
      expect(store.rooms.value.first.id, room.id);
      expect(store.byCode(room.inviteCode)?.id, room.id);
      expect(room.number, greaterThan(114));
    });
  });
}
