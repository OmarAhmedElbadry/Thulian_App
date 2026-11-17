import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../../core/services/habit_reminder_service.dart";
import "../../data/habits_mock_store.dart";
import "../../domain/entities/habit_draft.dart";
import "../../domain/entities/habit_entry.dart";
import "../../domain/repositories/habits_repository.dart";

@immutable
class CreateHabitState {
  const CreateHabitState({
    required this.draft,
    this.showNameError = false,
    this.dirty = false,
    this.saved = false,
    this.savedTick = 0,
    this.filed = false,
    this.filing = false,
    this.errorMessage,
  });

  final HabitDraft draft;

  /// Set after a failed "FILE HABIT" so the name field can show its error.
  final bool showNameError;

  /// True once the user has edited anything since the last save.
  final bool dirty;

  /// True when a draft exists in the store (restored or saved).
  final bool saved;

  /// Increments on every "SAVE DRAFT" so the page can show a confirmation.
  final int savedTick;

  final bool filed;
  final bool filing;
  final String? errorMessage;

  CreateHabitState copyWith({
    HabitDraft? draft,
    bool? showNameError,
    bool? dirty,
    bool? saved,
    int? savedTick,
    bool? filed,
    bool? filing,
    String? errorMessage,
  }) {
    return CreateHabitState(
      draft: draft ?? this.draft,
      showNameError: showNameError ?? this.showNameError,
      dirty: dirty ?? this.dirty,
      saved: saved ?? this.saved,
      savedTick: savedTick ?? this.savedTick,
      filed: filed ?? this.filed,
      filing: filing ?? this.filing,
      errorMessage: errorMessage,
    );
  }
}

class CreateHabitCubit extends Cubit<CreateHabitState> {
  CreateHabitCubit(
    HabitsMockStore store, {
    this.repository,
    this.reminders,
    HabitEntry? initialHabit,
  }) : _store = store,
       _habitId = initialHabit?.id,
       super(
         CreateHabitState(
           draft: initialHabit != null
               ? HabitDraft.fromEntry(initialHabit)
               : store.draft.value ?? const HabitDraft(),
           saved: initialHabit == null && store.draft.value != null,
         ),
       );

  final HabitsMockStore _store;
  final String? _habitId;
  final HabitsRepository? repository;
  final HabitReminderService? reminders;

  void _edit(HabitDraft draft) {
    emit(state.copyWith(draft: draft, dirty: true));
  }

  void setName(String value) {
    emit(
      state.copyWith(
        draft: state.draft.copyWith(name: value),
        dirty: true,
        showNameError: state.showNameError && value.trim().isEmpty,
      ),
    );
  }

  void setCategory(HabitCategory value) =>
      _edit(state.draft.copyWith(category: value));

  void setFrequency(HabitFrequency value) =>
      _edit(state.draft.copyWith(frequency: value));

  void toggleDay(int weekday) {
    final days = [...state.draft.weeklyDays];
    if (!days.remove(weekday)) days.add(weekday);
    days.sort();
    _edit(state.draft.copyWith(weeklyDays: days));
  }

  void setReminder(int minutesSinceMidnight) =>
      _edit(state.draft.copyWith(reminderMinutes: minutesSinceMidnight));

  void adjustTarget(int delta) {
    var next = state.draft.targetMinutes + delta;
    if (next < HabitDraft.minTarget) next = HabitDraft.minTarget;
    if (next > HabitDraft.maxTarget) next = HabitDraft.maxTarget;
    _edit(state.draft.copyWith(targetMinutes: next));
  }

  void saveDraft() {
    _store.saveDraft(state.draft);
    emit(
      state.copyWith(dirty: false, saved: true, savedTick: state.savedTick + 1),
    );
  }

  /// Returns true when the habit was filed.
  bool file() {
    if (!state.draft.isValid) {
      emit(state.copyWith(showNameError: true));
      return false;
    }
    _store.file(state.draft);
    emit(state.copyWith(filed: true, dirty: false));
    return true;
  }

  Future<void> fileHabit() async {
    if (!state.draft.isValid) {
      emit(state.copyWith(showNameError: true));
      return;
    }
    final habitsRepository = repository;
    if (habitsRepository == null) {
      file();
      return;
    }
    emit(state.copyWith(filing: true, errorMessage: null));
    try {
      if (_habitId == null) {
        await habitsRepository.createHabit(state.draft);
      } else {
        await habitsRepository.updateHabit(_habitId, state.draft);
      }
      try {
        await reminders?.syncFromRepository();
      } catch (_) {
        // A reminder scheduling issue should not undo a saved habit.
      }
      _store.clearDraft();
      emit(state.copyWith(filing: false, filed: true, dirty: false));
    } catch (_) {
      emit(
        state.copyWith(
          filing: false,
          errorMessage:
              "We couldn't save this habit. Check your connection and try again.",
        ),
      );
    }
  }

  /// Removes an edited habit from the active register while keeping its
  /// completion history available in the repository.
  Future<void> deleteHabit() async {
    final habitId = _habitId;
    if (habitId == null) return;
    final habitsRepository = repository;
    if (habitsRepository != null) {
      await habitsRepository.archiveHabit(habitId);
      try {
        await reminders?.syncFromRepository();
      } catch (_) {
        // The habit remains archived even if reminder cleanup fails.
      }
      return;
    }
    _store.habits.value = _store.habits.value
        .where((habit) => habit.id != habitId)
        .toList();
  }
}
