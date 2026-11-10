import "package:flutter/foundation.dart";

/// Category for a habit.
enum HabitCategory { mind, body, work, social }

/// Frequency for a habit.
enum HabitFrequency { daily, weekly }

/// A habit as it appears in the habit register (Phase 2 mock-data entity).
/// Richer than [HabitBrief] on the dashboard: includes category, frequency,
/// weekly completion history and aggregate stats.
@immutable
class HabitEntry {
  const HabitEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.frequency,
    this.weeklyDays = const [],
    required this.streakDays,
    required this.weekCompletions,
    required this.historyGrid,
    required this.bestStreak,
    required this.totalCompletions,
    required this.completionRate,
    this.reminderMinutes = 21 * 60 + 30,
    this.targetMinutes = 15,
  });

  final String id;
  final String title;
  final HabitCategory category;
  final HabitFrequency frequency;

  /// When [frequency] is [HabitFrequency.weekly], the 1-based weekdays
  /// (1 = Monday … 7 = Sunday) the habit is scheduled on.
  final List<int> weeklyDays;

  /// Current consecutive-day streak.
  final int streakDays;

  /// Boolean flags for the 7 days of the current week (Mon → Sun).
  /// `true` = completed, `false` = missed / not yet.
  final List<bool> weekCompletions;

  /// 28 booleans representing the last 4 weeks (Mon → Sun, oldest first).
  /// Used by the history grid.
  final List<bool> historyGrid;

  final int bestStreak;
  final int totalCompletions;

  /// 0–100, e.g. 92 means 92 %.
  final int completionRate;
  final int reminderMinutes;
  final int targetMinutes;

  /// Label shown below the title in the list, e.g. "MIND · DAILY".
  String get subtitle {
    final cat = category.name.toUpperCase();
    if (frequency == HabitFrequency.daily) return "$cat · DAILY";
    final count = weeklyDays.length;
    return "$cat · $count× WEEKLY";
  }

  HabitEntry copyWith({List<bool>? weekCompletions}) {
    return HabitEntry(
      id: id,
      title: title,
      category: category,
      frequency: frequency,
      weeklyDays: weeklyDays,
      streakDays: streakDays,
      weekCompletions: weekCompletions ?? this.weekCompletions,
      historyGrid: historyGrid,
      bestStreak: bestStreak,
      totalCompletions: totalCompletions,
      completionRate: completionRate,
      reminderMinutes: reminderMinutes,
      targetMinutes: targetMinutes,
    );
  }
}
