import "package:flutter_bloc/flutter_bloc.dart";

import "../../../../core/services/key_value_store.dart";
import "../../domain/entities/app_settings.dart";

/// Holds and persists [AppSettings] through the local key-value store.
class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(KeyValueStore store) : _store = store, super(_load(store));

  final KeyValueStore _store;

  static const dailyReminderKey = "settings_daily_reminder";
  static const roomInvitationsKey = "settings_room_invitations";
  static const weeklyDigestKey = "settings_weekly_digest";
  static const soundKey = "settings_sound";
  static const reduceMotionKey = "settings_reduce_motion";

  static AppSettings _load(KeyValueStore store) {
    const defaults = AppSettings();
    return AppSettings(
      dailyReminder:
          store.read<bool>(dailyReminderKey) ?? defaults.dailyReminder,
      roomInvitations:
          store.read<bool>(roomInvitationsKey) ?? defaults.roomInvitations,
      weeklyDigest: store.read<bool>(weeklyDigestKey) ?? defaults.weeklyDigest,
      sound: store.read<bool>(soundKey) ?? defaults.sound,
      reduceMotion: store.read<bool>(reduceMotionKey) ?? defaults.reduceMotion,
    );
  }

  Future<void> _set(String key, bool value, AppSettings next) async {
    emit(next);
    await _store.write(key, value);
  }

  Future<void> setDailyReminder(bool value) =>
      _set(dailyReminderKey, value, state.copyWith(dailyReminder: value));

  Future<void> setRoomInvitations(bool value) =>
      _set(roomInvitationsKey, value, state.copyWith(roomInvitations: value));

  Future<void> setWeeklyDigest(bool value) =>
      _set(weeklyDigestKey, value, state.copyWith(weeklyDigest: value));

  Future<void> setSound(bool value) =>
      _set(soundKey, value, state.copyWith(sound: value));

  Future<void> setReduceMotion(bool value) =>
      _set(reduceMotionKey, value, state.copyWith(reduceMotion: value));
}
