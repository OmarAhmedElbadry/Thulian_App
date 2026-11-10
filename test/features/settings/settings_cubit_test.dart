import "package:flutter_test/flutter_test.dart";
import "package:thulian/core/services/key_value_store.dart";
import "package:thulian/features/settings/presentation/cubit/settings_cubit.dart";

class _MemoryStore implements KeyValueStore {
  final Map<String, Object?> data = {};

  @override
  T? read<T>(String key) {
    final value = data[key];
    return value is T ? value : null;
  }

  @override
  Future<void> write(String key, Object? value) async => data[key] = value;
}

void main() {
  test("starts with sensible defaults", () {
    final s = SettingsCubit(_MemoryStore()).state;
    expect(s.dailyReminder, true);
    expect(s.roomInvitations, true);
    expect(s.weeklyDigest, false);
    expect(s.sound, true);
    expect(s.reduceMotion, false);
  });

  test("changes are emitted and persisted", () async {
    final store = _MemoryStore();
    final cubit = SettingsCubit(store);
    await cubit.setReduceMotion(true);
    await cubit.setWeeklyDigest(true);
    expect(cubit.state.reduceMotion, true);
    expect(store.data[SettingsCubit.reduceMotionKey], true);

    final reloaded = SettingsCubit(store).state;
    expect(reloaded.reduceMotion, true);
    expect(reloaded.weeklyDigest, true);
    expect(reloaded.sound, true);
  });
}
