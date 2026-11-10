import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../services/key_value_store.dart";

/// Holds and persists the selected ThemeMode.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(KeyValueStore store)
    : _store = store,
      super(_decode(store.read<String>(storageKey)));

  static const storageKey = "theme_mode";
  final KeyValueStore _store;

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _store.write(storageKey, mode.name);
  }

  static ThemeMode _decode(String? raw) {
    for (final mode in ThemeMode.values) {
      if (mode.name == raw) return mode;
    }
    return ThemeMode.system;
  }
}
