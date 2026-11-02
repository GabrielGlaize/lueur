import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

import "../domain/settings.dart";
import "storage_exception.dart";

abstract interface class SettingsRepository {
  /// Null means the user has not completed onboarding yet.
  Settings? load();
  Future<void> save(Settings settings);
  Future<void> clear();
}

class PrefsSettingsRepository implements SettingsRepository {
  PrefsSettingsRepository(this._prefs);

  static const String key = "settings_v1";

  final SharedPreferences _prefs;

  @override
  Settings? load() {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return Settings.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on Object catch (error) {
      throw StorageCorruptedException(key, error);
    }
  }

  @override
  Future<void> save(Settings settings) =>
      _prefs.setString(key, jsonEncode(settings.toJson()));

  @override
  Future<void> clear() => _prefs.remove(key);
}
