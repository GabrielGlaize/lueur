import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

import "../domain/day_record.dart";
import "storage_exception.dart";

abstract interface class DayRepository {
  /// Records keyed by `yyyy-MM-dd`. Empty on first launch.
  Map<String, DayRecord> load();
  Future<void> save(Map<String, DayRecord> days);
  Future<void> clear();
}

class PrefsDayRepository implements DayRepository {
  PrefsDayRepository(this._prefs);

  static const String key = "days_v1";

  final SharedPreferences _prefs;

  @override
  Map<String, DayRecord> load() {
    final raw = _prefs.getString(key);
    if (raw == null) return {};
    try {
      final list = (jsonDecode(raw) as List<Object?>)
          .cast<Map<String, Object?>>();
      return {
        for (final item in list)
          DayRecord.fromJson(item).dateKey: DayRecord.fromJson(item),
      };
    } on Object catch (error) {
      throw StorageCorruptedException(key, error);
    }
  }

  @override
  Future<void> save(Map<String, DayRecord> days) => _prefs.setString(
    key,
    jsonEncode(days.values.map((day) => day.toJson()).toList()),
  );

  @override
  Future<void> clear() => _prefs.remove(key);
}
