import "../repositories/habits_repository.dart";

class SetHabitCompletion {
  const SetHabitCompletion(this._repository);

  final HabitsRepository _repository;

  Future<void> call({
    required String habitId,
    required DateTime date,
    required bool completed,
  }) => _repository.setCompletion(habitId, date, completed: completed);
}
