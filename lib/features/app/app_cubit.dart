import "package:flutter_bloc/flutter_bloc.dart";

import "../../core/log.dart";
import "../../data/day_repository.dart";
import "../../data/settings_repository.dart";
import "../../data/storage_exception.dart";
import "../../domain/settings.dart";
import "../../services/day_planner.dart";
import "../../services/notification_scheduler.dart";
import "app_state.dart";

/// Holds the user's settings and decides whether onboarding is needed.
class AppCubit extends Cubit<AppState> {
  AppCubit({
    required SettingsRepository settings,
    required DayRepository days,
    required DayPlanner planner,
    required NotificationScheduler notifications,
  }) : _settings = settings,
       _days = days,
       _planner = planner,
       _notifications = notifications,
       super(const AppLoading());

  final SettingsRepository _settings;
  final DayRepository _days;
  final DayPlanner _planner;
  final NotificationScheduler _notifications;

  Future<void> start() async {
    try {
      await _notifications.initialize();
      final stored = _settings.load();
      if (stored == null) {
        emit(const AppNeedsOnboarding());
        return;
      }
      await _planner.plan(stored);
      emit(AppReady(stored));
    } on StorageCorruptedException catch (error) {
      logger.e("Corrupted storage", error: error);
      emit(const AppStorageCorrupted());
    }
  }

  /// Saves the onboarding choices. Notifications stay on only if the system
  /// permission is granted; the returned flag tells the caller.
  Future<bool> completeOnboarding(Settings chosen) async {
    final applied = await _withPermission(chosen);
    await _settings.save(applied);
    await _planner.plan(applied, redraw: true);
    emit(AppReady(applied));
    return applied.notificationsEnabled == chosen.notificationsEnabled;
  }

  Future<bool> updateSettings(Settings chosen) async {
    final current = state;
    if (current is! AppReady) {
      throw StateError("Settings can only change once the app is ready");
    }
    final turnedOn =
        chosen.notificationsEnabled && !current.settings.notificationsEnabled;
    final applied = turnedOn ? await _withPermission(chosen) : chosen;
    await _settings.save(applied);
    await _planner.plan(
      applied,
      redraw: applied.drawsDifferentlyFrom(current.settings),
    );
    emit(AppReady(applied));
    return applied.notificationsEnabled == chosen.notificationsEnabled;
  }

  /// Erases every stored value and goes back to onboarding.
  Future<void> resetEverything() async {
    await _notifications.cancelAll();
    await _settings.clear();
    await _days.clear();
    emit(const AppNeedsOnboarding());
  }

  Future<Settings> _withPermission(Settings chosen) async {
    if (!chosen.notificationsEnabled) return chosen;
    final granted = await _notifications.requestPermission();
    return chosen.copyWith(notificationsEnabled: granted);
  }
}
