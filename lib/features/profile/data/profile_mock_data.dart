import "../domain/entities/profile_snapshot.dart";

/// Hand-authored mock data matching the approved profile mockup.
/// Removed when profile data moves to Firestore in Phase 5.
abstract final class ProfileMockData {
  static const snapshot = ProfileSnapshot(
    name: "Amira Khalil",
    handle: "amira.k",
    email: "amira@mail.com",
    level: 12,
    xp: 2480,
    xpForNext: 3000,
    streakDays: 14,
    habitsFiled: 612,
    studyHours: 184,
    weekActivity: [62, 100, 34, 72, 28, 55, 14],
    weekHighlightIndex: 1,
    stampsTotal: 12,
    stamps: [
      Stamp(value: "14", label: "Streak"),
      Stamp(value: "06", label: "Early bird"),
      Stamp(value: "\u2014", label: "Locked", unlocked: false),
    ],
    friends: [
      FriendStat(name: "Karim", focusMinutes: 1268),
      FriendStat(name: "Lena", focusMinutes: 1050),
    ],
  );
}
