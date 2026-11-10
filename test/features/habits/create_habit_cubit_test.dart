import "package:flutter_test/flutter_test.dart";
import "package:thulian/features/habits/data/habits_mock_store.dart";
import "package:thulian/features/habits/domain/entities/habit_draft.dart";
import "package:thulian/features/habits/domain/entities/habit_entry.dart";
import "package:thulian/features/habits/presentation/cubit/create_habit_cubit.dart";

void main() {
  late HabitsMockStore store;

  setUp(() => store = HabitsMockStore(seed: const []));

  group("HabitDraft", () {
    test("needs a name; weekly needs at least one day", () {
      expect(const HabitDraft().isValid, false);
      expect(const HabitDraft(name: " Read ").isValid, true);
      expect(
        const HabitDraft(
          name: "Run",
          frequency: HabitFrequency.weekly,
          weeklyDays: [],
        ).isValid,
        false,
      );
    });
  });

  group("CreateHabitCubit", () {
    test("filing without a name shows the error and files nothing", () {
      final cubit = CreateHabitCubit(store);
      expect(cubit.file(), false);
      expect(cubit.state.showNameError, true);
      expect(store.habits.value, isEmpty);
    });

    test("filing a valid draft adds the habit and clears the saved draft", () {
      final cubit = CreateHabitCubit(store)
        ..setName("  Evening journal ")
        ..setCategory(HabitCategory.mind)
        ..adjustTarget(10);
      cubit.saveDraft();
      expect(store.draft.value, isNotNull);

      expect(cubit.file(), true);
      expect(cubit.state.filed, true);
      expect(store.habits.value, hasLength(1));
      final habit = store.habits.value.single;
      expect(habit.title, "Evening journal");
      expect(habit.targetMinutes, 25);
      expect(habit.weekCompletions, everyElement(false));
      expect(store.draft.value, isNull);
    });

    test("weekly days toggle and stay sorted", () {
      final cubit = CreateHabitCubit(store)
        ..setFrequency(HabitFrequency.weekly)
        ..toggleDay(2);
      expect(cubit.state.draft.weeklyDays, [1, 2, 3, 5]);
      cubit.toggleDay(3);
      expect(cubit.state.draft.weeklyDays, [1, 2, 5]);
    });

    test("target stays within its bounds", () {
      final cubit = CreateHabitCubit(store);
      for (var i = 0; i < 100; i++) {
        cubit.adjustTarget(-HabitDraft.targetStep);
      }
      expect(cubit.state.draft.targetMinutes, HabitDraft.minTarget);
      for (var i = 0; i < 100; i++) {
        cubit.adjustTarget(HabitDraft.targetStep);
      }
      expect(cubit.state.draft.targetMinutes, HabitDraft.maxTarget);
    });

    test("a saved draft is restored by a new cubit", () {
      CreateHabitCubit(store)
        ..setName("Stretch")
        ..saveDraft();
      final restored = CreateHabitCubit(store);
      expect(restored.state.draft.name, "Stretch");
      expect(restored.state.saved, true);
      expect(restored.state.dirty, false);
    });
  });
}
