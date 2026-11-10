import "../../../core/services/key_value_store.dart";
import "../domain/entities/onboarding_draft.dart";

class OnboardingLocalDataSource {
  const OnboardingLocalDataSource(this._store);

  static const completeKey = "onboarding_complete";
  static const nameKey = "display_name";
  static const goalsKey = "onboarding_goals";
  static const reminderKey = "daily_reminder_minutes";
  static const notificationsKey = "notifications_enabled";

  final KeyValueStore _store;

  bool isComplete() => _store.read<bool>(completeKey) ?? false;

  Future<void> saveCompleted(OnboardingDraft draft) async {
    await _store.write(completeKey, true);
    await _store.write(nameKey, draft.displayName);
    await _store.write(goalsKey, draft.goalIds.join(","));
    await _store.write(reminderKey, draft.reminderMinutes);
    await _store.write(notificationsKey, draft.notificationsEnabled);
  }
}
