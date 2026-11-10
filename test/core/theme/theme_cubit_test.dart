import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:thulian/core/services/key_value_store.dart";
import "package:thulian/core/theme/theme_cubit.dart";
import "package:thulian/core/theme/tokens/thulian_colors.dart";

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
  group("ThemeCubit", () {
    test("defaults to system when nothing is stored", () {
      expect(ThemeCubit(_MemoryStore()).state, ThemeMode.system);
    });

    test("restores a stored mode", () {
      final store = _MemoryStore()..data[ThemeCubit.storageKey] = "dark";
      expect(ThemeCubit(store).state, ThemeMode.dark);
    });

    test("ignores an invalid stored value", () {
      final store = _MemoryStore()..data[ThemeCubit.storageKey] = "purple";
      expect(ThemeCubit(store).state, ThemeMode.system);
    });

    test("setMode emits and persists", () async {
      final store = _MemoryStore();
      final cubit = ThemeCubit(store);
      await cubit.setMode(ThemeMode.light);
      expect(cubit.state, ThemeMode.light);
      expect(store.data[ThemeCubit.storageKey], "light");
    });
  });

  group("ThulianColors", () {
    test("light accent is deep magenta, dark accent is light magenta", () {
      expect(ThulianColors.light.accent, const Color(0xFFC0136F));
      expect(ThulianColors.dark.accent, const Color(0xFFF2BDD9));
    });
  });
}
