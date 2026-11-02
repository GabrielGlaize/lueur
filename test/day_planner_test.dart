import "dart:math";

import "package:flutter_test/flutter_test.dart";
import "package:lueur/core/dates.dart";
import "package:lueur/domain/enums.dart";
import "package:lueur/domain/quota_drawer.dart";
import "package:lueur/domain/settings.dart";
import "package:lueur/services/day_planner.dart";

import "support/fakes.dart";

void main() {
  late FakeDayRepository days;
  late FakeNotificationScheduler notifications;
  late DateTime now;
  late DayPlanner planner;

  setUp(() {
    days = FakeDayRepository();
    notifications = FakeNotificationScheduler();
    now = DateTime(2026, 7, 28, 7, 0);
    planner = DayPlanner(
      days: days,
      drawer: QuotaDrawer(Random(7)),
      notifications: notifications,
      clock: () => now,
    );
  });

  final wide = Settings.initial.copyWith(
    maximum: 40,
    quotaMode: QuotaMode.fullRandom,
  );

  test(
    "plans today and the whole horizon, marking only today as seen",
    () async {
      final result = await planner.plan(wide);
      expect(result.length, DayPlanner.horizonDays);
      expect(result[dateKeyOf(now)]!.seen, isTrue);
      expect(result.values.where((d) => d.seen).length, 1);
    },
  );

  test("a day's quota does not change when the app is reopened", () async {
    final first = await planner.plan(wide);
    final second = await planner.plan(wide);
    expect(second[dateKeyOf(now)]!.quota, first[dateKeyOf(now)]!.quota);
  });

  test("frozen policy keeps today but draws the future again", () async {
    final before = await planner.plan(wide);
    final changed = wide.copyWith(maximum: 41);
    final after = await planner.plan(changed, redraw: true);
    final todayKey = dateKeyOf(now);
    expect(after[todayKey]!.quota, before[todayKey]!.quota);
    final futureKeys = before.keys.where((k) => k != todayKey);
    expect(futureKeys.any((k) => after[k]!.quota != before[k]!.quota), isTrue);
  });

  test(
    "recalculating policy draws today again and keeps the smoked count",
    () async {
      final settings = wide.copyWith(drawPolicy: DrawPolicy.recalculating);
      final before = await planner.plan(settings);
      await planner.adjustToday(1);
      await planner.adjustToday(1);
      final after = await planner.plan(
        settings.copyWith(maximum: 41),
        redraw: true,
      );
      final todayKey = dateKeyOf(now);
      expect(after[todayKey]!.smoked, 2);
      var differs = after[todayKey]!.quota != before[todayKey]!.quota;
      // Retry a few times: two draws can legitimately match by chance.
      for (var i = 0; i < 20 && !differs; i++) {
        final again = await planner.plan(
          settings.copyWith(maximum: 40 - (i % 2)),
          redraw: true,
        );
        differs = again[todayKey]!.quota != before[todayKey]!.quota;
      }
      expect(differs, isTrue);
    },
  );

  test("adjusting stays between zero and the cap", () async {
    await planner.plan(wide);
    var result = await planner.adjustToday(-1);
    expect(result[dateKeyOf(now)]!.smoked, 0);
    for (var i = 0; i < 120; i++) {
      result = await planner.adjustToday(1);
    }
    expect(result[dateKeyOf(now)]!.smoked, 99);
  });

  test("adjusting before planning is a programming error", () async {
    expect(() => planner.adjustToday(1), throwsStateError);
  });

  test("notifications cover only future moments, once per day", () async {
    await planner.plan(wide.copyWith(notificationsEnabled: true));
    expect(notifications.scheduled.length, DayPlanner.horizonDays);
    now = DateTime(2026, 7, 28, 9, 0);
    await planner.plan(wide.copyWith(notificationsEnabled: true));
    expect(notifications.scheduled.length, DayPlanner.horizonDays - 1);
    expect(notifications.scheduled.every((n) => n.at.isAfter(now)), isTrue);
  });

  test("turning notifications off cancels the pending ones", () async {
    await planner.plan(wide);
    expect(notifications.scheduled, isEmpty);
    expect(notifications.cancelCount, 1);
  });

  test("records older than the retention window are dropped", () async {
    await planner.plan(wide);
    now = DateTime(2026, 7, 28 + DayPlanner.retentionDays + 5);
    final result = await planner.plan(wide);
    expect(result.containsKey("2026-07-28"), isFalse);
  });
}
