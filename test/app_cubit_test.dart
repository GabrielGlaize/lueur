import "dart:math";

import "package:flutter_test/flutter_test.dart";
import "package:lueur/data/storage_exception.dart";
import "package:lueur/domain/quota_drawer.dart";
import "package:lueur/domain/settings.dart";
import "package:lueur/features/app/app_cubit.dart";
import "package:lueur/features/app/app_state.dart";
import "package:lueur/services/day_planner.dart";

import "support/fakes.dart";

class _CorruptSettings extends FakeSettingsRepository {
  @override
  Settings? load() =>
      throw const StorageCorruptedException("settings_v1", "bad");
}

void main() {
  late FakeSettingsRepository settings;
  late FakeDayRepository days;
  late FakeNotificationScheduler notifications;

  AppCubit build([FakeSettingsRepository? repo]) => AppCubit(
    settings: repo ?? settings,
    days: days,
    planner: DayPlanner(
      days: days,
      drawer: QuotaDrawer(Random(1)),
      notifications: notifications,
      clock: () => DateTime(2026, 7, 28, 7),
    ),
    notifications: notifications,
  );

  setUp(() {
    settings = FakeSettingsRepository();
    days = FakeDayRepository();
    notifications = FakeNotificationScheduler();
  });

  test("first launch asks for onboarding", () async {
    final cubit = build();
    await cubit.start();
    expect(cubit.state, const AppNeedsOnboarding());
  });

  test("onboarding saves settings and reaches ready", () async {
    final cubit = build();
    await cubit.start();
    final kept = await cubit.completeOnboarding(Settings.initial);
    expect(kept, isTrue);
    expect(cubit.state, const AppReady(Settings.initial));
    expect(settings.stored, Settings.initial);
    expect(days.stored, isNotEmpty);
  });

  test("a refused permission turns notifications off and says so", () async {
    notifications.permission = false;
    final cubit = build();
    await cubit.start();
    final kept = await cubit.completeOnboarding(
      Settings.initial.copyWith(notificationsEnabled: true),
    );
    expect(kept, isFalse);
    expect((cubit.state as AppReady).settings.notificationsEnabled, isFalse);
    expect(notifications.scheduled, isEmpty);
  });

  test("a returning user goes straight to ready", () async {
    settings.stored = Settings.initial;
    final cubit = build();
    await cubit.start();
    expect(cubit.state, const AppReady(Settings.initial));
  });

  test("corrupted settings surface a dedicated state", () async {
    final cubit = build(_CorruptSettings());
    await cubit.start();
    expect(cubit.state, const AppStorageCorrupted());
  });

  test("reset wipes everything and returns to onboarding", () async {
    final cubit = build();
    await cubit.start();
    await cubit.completeOnboarding(Settings.initial);
    await cubit.resetEverything();
    expect(cubit.state, const AppNeedsOnboarding());
    expect(settings.stored, isNull);
    expect(days.stored, isEmpty);
  });

  test("changing settings before the app is ready is an error", () async {
    final cubit = build();
    await cubit.start();
    expect(() => cubit.updateSettings(Settings.initial), throwsStateError);
  });
}
