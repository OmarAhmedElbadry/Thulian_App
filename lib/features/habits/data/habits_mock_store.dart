import "package:flutter/foundation.dart";

import "../domain/entities/habit_draft.dart";
import "../domain/entities/habit_entry.dart";
import "habits_mock_data.dart";

/// In-memory stand-in for the habits repository (Phase 2 only). It lets the
/// create-habit page and the habit register share state without Firebase.
/// Replaced by the habits repository and cubit in Phase 4.
class HabitsMockStore {
  HabitsMockStore({List<HabitEntry>? seed})
    : habits = ValueNotifier<List<HabitEntry>>(
        List.of(seed ?? HabitsMockData.habits),
      );

  static final HabitsMockStore instance = HabitsMockStore();

  final ValueNotifier<List<HabitEntry>> habits;

  /// Draft saved with "SAVE DRAFT"; restored the next time the page opens.
  final ValueNotifier<HabitDraft?> draft = ValueNotifier<HabitDraft?>(null);

  void saveDraft(HabitDraft value) => draft.value = value;

  void clearDraft() => draft.value = null;

  /// Files a new habit into the register and discards any saved draft.
  HabitEntry file(HabitDraft value) {
    final days = [...value.weeklyDays]..sort();
    final entry = HabitEntry(
      id: "habit-${DateTime.now().microsecondsSinceEpoch}",
      title: value.name.trim(),
      category: value.category,
      frequency: value.frequency,
      weeklyDays: value.frequency == HabitFrequency.weekly ? days : const [],
      streakDays: 0,
      weekCompletions: List<bool>.filled(7, false),
      historyGrid: List<bool>.filled(28, false),
      bestStreak: 0,
      totalCompletions: 0,
      completionRate: 0,
      reminderMinutes: value.reminderMinutes,
      targetMinutes: value.targetMinutes,
    );
    habits.value = [...habits.value, entry];
    clearDraft();
    return entry;
  }
}
