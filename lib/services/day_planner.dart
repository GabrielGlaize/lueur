import "../core/dates.dart";
import "../data/day_repository.dart";
import "../domain/day_record.dart";
import "../domain/enums.dart";
import "../domain/quota_copy.dart";
import "../domain/quota_drawer.dart";
import "../domain/settings.dart";
import "notification_scheduler.dart";

/// Owns the day records: draws quotas ahead, keeps the notification window
/// current and applies the user's smoking count.
class DayPlanner {
  DayPlanner({
    required DayRepository days,
    required QuotaDrawer drawer,
    required NotificationScheduler notifications,
    required DateTime Function() clock,
  }) : _days = days,
       _drawer = drawer,
       _notifications = notifications,
       _clock = clock;

  /// Days drawn ahead; also the number of scheduled notifications.
  static const int horizonDays = 30;
  static const int retentionDays = 90;

  final DayRepository _days;
  final QuotaDrawer _drawer;
  final NotificationScheduler _notifications;
  final DateTime Function() _clock;

  /// Makes sure today and the next days have a quota, marks today as seen and
  /// refreshes the notifications. With [redraw], future days are drawn again
  /// and so is today when the policy is [DrawPolicy.recalculating].
  Future<Map<String, DayRecord>> plan(
    Settings settings, {
    bool redraw = false,
  }) async {
    final now = _clock();
    final today = dayStart(now);
    final days = _days.load();

    for (var offset = 0; offset < horizonDays; offset++) {
      final key = dateKeyOf(addDays(today, offset));
      final existing = days[key];
      final drawAgain =
          existing == null ||
          (redraw &&
              (offset > 0 || settings.drawPolicy == DrawPolicy.recalculating));
      if (drawAgain) {
        days[key] = DayRecord(
          dateKey: key,
          quota: _drawer.draw(settings),
          smoked: existing?.smoked ?? 0,
          seen: existing?.seen ?? false,
        );
      }
    }
    final todayKey = dateKeyOf(today);
    days[todayKey] = days[todayKey]!.copyWith(seen: true);

    final oldest = dateKeyOf(addDays(today, -retentionDays));
    days.removeWhere((key, _) => key.compareTo(oldest) < 0);

    await _days.save(days);
    await _syncNotifications(settings, days, now);
    return days;
  }

  /// Adds [delta] (+1 or -1) to today's count, bounded to a valid range.
  Future<Map<String, DayRecord>> adjustToday(int delta) async {
    final days = _days.load();
    final key = dateKeyOf(_clock());
    final today = days[key];
    if (today == null) {
      throw StateError("Today has no record; call plan() first");
    }
    final smoked = (today.smoked + delta).clamp(0, DayRecord.maxSmoked);
    days[key] = today.copyWith(smoked: smoked, seen: true);
    await _days.save(days);
    return days;
  }

  Future<void> disableNotifications() => _notifications.cancelAll();

  Future<void> _syncNotifications(
    Settings settings,
    Map<String, DayRecord> days,
    DateTime now,
  ) async {
    if (!settings.notificationsEnabled) {
      await _notifications.cancelAll();
      return;
    }
    final entries = <ScheduledQuota>[];
    for (var offset = 0; offset < horizonDays; offset++) {
      final date = addDays(dayStart(now), offset);
      final at = DateTime(
        date.year,
        date.month,
        date.day,
        settings.notificationHour,
        settings.notificationMinute,
      );
      if (!at.isAfter(now)) continue;
      entries.add(
        ScheduledQuota(
          at: at,
          body: QuotaCopy.notificationBody(
            days[dateKeyOf(date)]!.quota,
            settings,
          ),
        ),
      );
    }
    await _notifications.replaceAll(entries);
  }
}
