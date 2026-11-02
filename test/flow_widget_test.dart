import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get_it/get_it.dart";
import "package:lueur/config/app_router.dart";
import "package:lueur/config/service_locator.dart";
import "package:lueur/core/dates.dart";
import "package:lueur/data/day_repository.dart";
import "package:lueur/data/settings_repository.dart";
import "package:lueur/domain/quota_drawer.dart";
import "package:lueur/features/app/app_cubit.dart";
import "package:lueur/main.dart";
import "package:lueur/services/day_planner.dart";
import "package:lueur/services/notification_scheduler.dart";

import "support/fakes.dart";

void main() {
  late FakeSettingsRepository settings;
  late FakeDayRepository days;
  late AppCubit cubit;

  setUp(() async {
    await GetIt.instance.reset();
    settings = FakeSettingsRepository();
    days = FakeDayRepository();
    final notifications = FakeNotificationScheduler();
    DateTime clock() => DateTime(2026, 7, 28, 7);
    final planner = DayPlanner(
      days: days,
      drawer: QuotaDrawer(Random(5)),
      notifications: notifications,
      clock: clock,
    );
    cubit = AppCubit(
      settings: settings,
      days: days,
      planner: planner,
      notifications: notifications,
    );
    getIt
      ..registerSingleton<Clock>(clock)
      ..registerSingleton<SettingsRepository>(settings)
      ..registerSingleton<DayRepository>(days)
      ..registerSingleton<NotificationScheduler>(notifications)
      ..registerSingleton<DayPlanner>(planner)
      ..registerSingleton<AppCubit>(cubit);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    // The logo loops forever unless the user reduces motion; this also covers that path.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      LueurApp(appCubit: cubit, router: buildRouter(cubit)),
    );
    await cubit.start();
    await tester.pumpAndSettle();
  }

  testWidgets("onboarding leads to a home with a quota, then count and undo", (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.byKey(const Key("onboarding-next-btn")), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key("onboarding-next-btn")));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key("home-quota")), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key("home-smoked"))).data,
      "0 fumée",
    );

    await tester.tap(find.byKey(const Key("home-add-btn")));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key("home-smoked"))).data,
      "1 fumée",
    );

    await tester.tap(find.byKey(const Key("home-undo-btn")));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key("home-smoked"))).data,
      "0 fumée",
    );
  });

  testWidgets("settings can be saved, and reset returns to onboarding", (
    tester,
  ) async {
    await pumpApp(tester);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key("onboarding-next-btn")));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const Key("home-settings-btn")));
    await tester.pumpAndSettle();

    final save = find.byKey(const Key("settings-save-btn"));
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.tap(find.byKey(const Key("max-plus-btn")));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(settings.stored!.maximum, 11);

    await tester.scrollUntilVisible(
      find.byKey(const Key("settings-reset-btn")),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key("settings-reset-btn")));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("reset-confirm-btn")));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key("onboarding-next-btn")), findsOneWidget);
    expect(settings.stored, isNull);
  });

  testWidgets("every screen stays usable at 200% text size", (tester) async {
    await pumpApp(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key("onboarding-next-btn")));
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const Key("home-add-btn")), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key("home-about-btn")));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
