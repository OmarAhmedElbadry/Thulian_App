import "../entities/habit_draft.dart";
import "../entities/habit_entry.dart";

abstract interface class HabitsRepository {
  Stream<List<HabitEntry>> watchHabits();

  Future<HabitEntry> createHabit(HabitDraft draft);

  Future<void> updateHabit(String id, HabitDraft draft);

  Future<void> archiveHabit(String id);

  Stream<List<DateTime>> watchCompletions(String habitId);

  Future<void> setCompletion(
    String habitId,
    DateTime date, {
    required bool completed,
  });
}
