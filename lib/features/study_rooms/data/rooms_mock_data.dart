import "../domain/entities/study_room.dart";
import "../domain/entities/study_session.dart";

/// Hand-authored mock data matching the approved rooms and session mockups.
/// Removed when rooms move to Firestore and Cloud Functions in Phase 8.
abstract final class RoomsMockData {
  static const rooms = [
    StudyRoom(
      id: "library-3f",
      number: 114,
      name: "Library, 3rd floor",
      visibility: RoomVisibility.private,
      insideCount: 4,
      blockMinutes: 50,
      status: RoomStatus.live,
      inviteCode: "KX4821",
      isOwner: true,
    ),
    StudyRoom(
      id: "quiet-hours",
      number: 112,
      name: "Quiet Hours",
      visibility: RoomVisibility.public,
      insideCount: 12,
      blockMinutes: 25,
      status: RoomStatus.live,
      inviteCode: "QH2501",
    ),
    StudyRoom(
      id: "thesis-club",
      number: 109,
      name: "Thesis Club",
      visibility: RoomVisibility.public,
      insideCount: 7,
      blockMinutes: 90,
      status: RoomStatus.live,
      inviteCode: "TC9004",
    ),
    StudyRoom(
      id: "night-owls",
      number: 97,
      name: "Night Owls",
      visibility: RoomVisibility.public,
      insideCount: 0,
      blockMinutes: 50,
      status: RoomStatus.idle,
      inviteCode: "NO2200",
      opensAt: "22:00",
    ),
    StudyRoom(
      id: "exam-week",
      number: 93,
      name: "Exam Week",
      visibility: RoomVisibility.private,
      insideCount: 2,
      blockMinutes: 50,
      status: RoomStatus.idle,
      inviteCode: "EW1100",
    ),
  ];

  static const blockCount = 4;

  /// A live room is shown 64.6 % through its block (32:18 of 50:00).
  static const liveProgress = 0.646;

  static const liveParticipants = [
    SessionParticipant(
      id: "karim",
      name: "Karim",
      focusSeconds: 9668,
      status: ParticipantStatus.focusing,
    ),
    SessionParticipant(
      id: "lena",
      name: "Lena",
      focusSeconds: 7950,
      status: ParticipantStatus.onBreak,
    ),
    SessionParticipant(
      id: "you",
      name: "Amira",
      focusSeconds: 7124,
      status: ParticipantStatus.focusing,
      isYou: true,
    ),
    SessionParticipant(
      id: "tomas",
      name: "Tomas",
      focusSeconds: 2832,
      status: ParticipantStatus.focusing,
    ),
  ];
}
