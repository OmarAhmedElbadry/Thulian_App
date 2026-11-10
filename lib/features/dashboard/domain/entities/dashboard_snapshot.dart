import "package:flutter/foundation.dart";

/// A habit as it appears on the daily dashboard. This is deliberately smaller
/// than the full habit entity that arrives in Phase 4: the dashboard only needs
/// a title, the current streak and today's completion state.
@immutable
class HabitBrief {
  const HabitBrief({
    required this.id,
    required this.title,
    required this.streakDays,
    required this.done,
  });

  final String id;
  final String title;

  /// Consecutive days this habit has been filed. Zero for a new habit.
  final int streakDays;
  final bool done;

  HabitBrief copyWith({bool? done}) {
    return HabitBrief(
      id: id,
      title: title,
      streakDays: streakDays,
      done: done ?? this.done,
    );
  }
}

/// Everything the home page needs for one day, with no repository attached
/// yet. Phase 5 replaces [DashboardMockData.snapshot] with real state.
@immutable
class DashboardSnapshot {
  const DashboardSnapshot({
    required this.displayName,
    required this.streakDays,
    required this.focusMinutes,
    required this.weekDone,
    required this.weekTotal,
    required this.weekActivity,
    required this.weekHighlightIndex,
    required this.roomsLive,
    required this.notesCount,
    required this.habits,
  }) : assert(weekHighlightIndex >= 0 && weekHighlightIndex < 7);

  final String displayName;

  /// Overall daily streak shown in the stat row.
  final int streakDays;

  /// Minutes of focus filed today (402 -> "06:42").
  final int focusMinutes;

  /// Days filed this week, e.g. 5 of 7.
  final int weekDone;
  final int weekTotal;

  /// Seven 0-100 values, Monday to Sunday, used to draw the week chart.
  final List<int> weekActivity;

  /// Zero-based index of the highlighted (today) bar in [weekActivity].
  final int weekHighlightIndex;

  final int roomsLive;
  final int notesCount;
  final List<HabitBrief> habits;

  int get completedHabits => habits.where((habit) => habit.done).length;

  int get remainingHabits => habits.length - completedHabits;

  bool get allComplete => habits.isNotEmpty && remainingHabits == 0;

  /// Rounded completion percentage, e.g. 2 of 3 -> 67.
  int get completionPercent {
    if (habits.isEmpty) return 0;
    return (completedHabits / habits.length * 100).round();
  }
}
