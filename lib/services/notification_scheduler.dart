import "package:flutter/foundation.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter_timezone/flutter_timezone.dart";
import "package:timezone/data/latest.dart" as tz_data;
import "package:timezone/timezone.dart" as tz;

import "../core/log.dart";

@immutable
class ScheduledQuota {
  const ScheduledQuota({required this.at, required this.body});

  final DateTime at;
  final String body;
}

abstract interface class NotificationScheduler {
  Future<void> initialize();

  /// True when the user allowed notifications.
  Future<bool> requestPermission();

  /// Replaces every pending notification with [entries].
  Future<void> replaceAll(List<ScheduledQuota> entries);

  Future<void> cancelAll();
}

class LocalNotificationScheduler implements NotificationScheduler {
  static const int _idBase = 7000;
  static const String _channelId = "daily_quota";

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    tz_data.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
  }

  @override
  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, sound: true);
      // fallback: the plugin returns null when iOS cannot answer; treat as refused.
      return granted ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    // fallback: Android below 13 has no runtime permission, so null means allowed.
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> replaceAll(List<ScheduledQuota> entries) async {
    await _plugin.cancelAllPendingNotifications();
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      await _plugin.zonedSchedule(
        id: _idBase + index,
        title: "Ta lueur du jour",
        body: entry.body,
        scheduledDate: tz.TZDateTime.from(entry.at, tz.local),
        notificationDetails: const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            _channelId,
            "Quota quotidien",
            channelDescription: "Ton repère personnel chaque matin",
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
    logger.d("Scheduled ${entries.length} notifications");
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAllPendingNotifications();
}
