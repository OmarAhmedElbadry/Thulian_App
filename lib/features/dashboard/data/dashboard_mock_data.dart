import "../domain/entities/dashboard_snapshot.dart";

/// Hand-authored mock data for Phase 2. Removed when the dashboard cubit and
/// Firestore repositories land in Phase 5.
///
/// Values mirror the approved home mockup: Tuesday 03/11/2026, 2 of 3 habits
/// filed (67 %), a 14-day streak, 06:42 of focus and 5 of 7 days filed.
abstract final class DashboardMockData {
  static const snapshot = DashboardSnapshot(
    displayName: "Amira",
    streakDays: 14,
    focusMinutes: 402,
    weekDone: 5,
    weekTotal: 7,
    weekActivity: [69, 100, 54, 83, 66, 14, 14],
    weekHighlightIndex: 4,
    roomsLive: 3,
    notesCount: 12,
    habits: [
      HabitBrief(
        id: "read-twenty",
        title: "Read 20 pages",
        streakDays: 14,
        done: true,
      ),
      HabitBrief(
        id: "morning-stretch",
        title: "Morning stretch",
        streakDays: 31,
        done: true,
      ),
      HabitBrief(
        id: "focus-block",
        title: "Focus block, 90 min",
        streakDays: 0,
        done: false,
      ),
    ],
  );
}
