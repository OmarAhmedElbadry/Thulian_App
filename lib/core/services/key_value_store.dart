import "package:hive_ce_flutter/hive_flutter.dart";

/// Minimal local key-value storage contract. Keeps Hive out of Cubits and makes tests easy.
abstract interface class KeyValueStore {
  T? read<T>(String key);
  Future<void> write(String key, Object? value);
}

class HiveKeyValueStore implements KeyValueStore {
  HiveKeyValueStore._(this._box);

  static const _boxName = "thulian_settings";
  final Box<dynamic> _box;

  static Future<HiveKeyValueStore> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>(_boxName);
    return HiveKeyValueStore._(box);
  }

  @override
  T? read<T>(String key) {
    final value = _box.get(key);
    return value is T ? value : null;
  }

  @override
  Future<void> write(String key, Object? value) => _box.put(key, value);
}
