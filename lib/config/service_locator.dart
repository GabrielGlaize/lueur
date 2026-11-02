import "dart:math";

import "package:get_it/get_it.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../core/dates.dart";
import "../data/day_repository.dart";
import "../data/settings_repository.dart";
import "../domain/quota_drawer.dart";
import "../features/app/app_cubit.dart";
import "../services/day_planner.dart";
import "../services/notification_scheduler.dart";

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  getIt
    ..registerSingleton<Clock>(DateTime.now)
    ..registerSingleton<SettingsRepository>(PrefsSettingsRepository(prefs))
    ..registerSingleton<DayRepository>(PrefsDayRepository(prefs))
    ..registerSingleton<NotificationScheduler>(LocalNotificationScheduler())
    ..registerSingleton<DayPlanner>(
      DayPlanner(
        days: getIt<DayRepository>(),
        drawer: QuotaDrawer(Random.secure()),
        notifications: getIt<NotificationScheduler>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerSingleton<AppCubit>(
      AppCubit(
        settings: getIt<SettingsRepository>(),
        days: getIt<DayRepository>(),
        planner: getIt<DayPlanner>(),
        notifications: getIt<NotificationScheduler>(),
      ),
    );
}
