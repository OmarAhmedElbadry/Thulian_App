import "package:flutter/foundation.dart";

import "habit_entry.dart";

/// A habit being composed on the "File a new habit" page. Pure Dart: times are
/// kept as minutes since midnight so the domain never depends on Flutter.
@immutable
class HabitDraft {
  const HabitDraft({
    this.name = "",
    this.category = HabitCategory.mind,
    this.frequency = HabitFrequency.daily,
    this.weeklyDays = const [1, 3, 5],
    this.reminderMinutes = 21 * 60 + 30,
    this.targetMinutes = 15,
  });

  static const minTarget = 5;
  static const maxTarget = 240;
  static const targetStep = 5;

  final String name;
  final HabitCategory category;
  final HabitFrequency frequency;

  /// 1-based weekdays (1 = Monday) used when [frequency] is weekly.
  final List<int> weeklyDays;

  final int reminderMinutes;
  final int targetMinutes;

  bool get hasName => name.trim().isNotEmpty;

  bool get isValid =>
      hasName && (frequency == HabitFrequency.daily || weeklyDays.isNotEmpty);

  HabitDraft copyWith({
    String? name,
    HabitCategory? category,
    HabitFrequency? frequency,
    List<int>? weeklyDays,
    int? reminderMinutes,
    int? targetMinutes,
  }) {
    return HabitDraft(
      name: name ?? this.name,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      targetMinutes: targetMinutes ?? this.targetMinutes,
    );
  }
}
