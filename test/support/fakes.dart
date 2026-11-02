import "package:lueur/data/day_repository.dart";
import "package:lueur/data/settings_repository.dart";
import "package:lueur/domain/day_record.dart";
import "package:lueur/domain/settings.dart";
import "package:lueur/services/notification_scheduler.dart";

class FakeDayRepository implements DayRepository {
  Map<String, DayRecord> stored = {};

  @override
  Map<String, DayRecord> load() => Map.of(stored);

  @override
  Future<void> save(Map<String, DayRecord> days) async => stored = Map.of(days);

  @override
  Future<void> clear() async => stored = {};
}

class FakeSettingsRepository implements SettingsRepository {
  Settings? stored;

  @override
  Settings? load() => stored;

  @override
  Future<void> save(Settings settings) async => stored = settings;

  @override
  Future<void> clear() async => stored = null;
}

class FakeNotificationScheduler implements NotificationScheduler {
  bool permission = true;
  List<ScheduledQuota> scheduled = [];
  int cancelCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> replaceAll(List<ScheduledQuota> entries) async =>
      scheduled = entries;

  @override
  Future<void> cancelAll() async {
    cancelCount++;
    scheduled = [];
  }
}
