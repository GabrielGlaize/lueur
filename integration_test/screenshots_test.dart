import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:lueur/config/app_router.dart";
import "package:lueur/config/service_locator.dart";
import "package:lueur/core/dates.dart";
import "package:lueur/data/day_repository.dart";
import "package:lueur/domain/day_record.dart";
import "package:lueur/features/app/app_cubit.dart";
import "package:lueur/main.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Walks through the app on a device or simulator and saves a screenshot of each
/// screen (see test_driver/integration_test.dart). Used for the portfolio and stores.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("screenshots of every screen", (tester) async {
    // The logo spins forever otherwise, and a still logo makes the shots repeatable.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
    final appCubit = getIt<AppCubit>();
    await tester.pumpWidget(
      LueurApp(appCubit: appCubit, router: buildRouter(appCubit)),
    );
    await appCubit.start();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    Future<void> shot(String name) async {
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await binding.takeScreenshot(name);
    }

    Future<void> tapKey(String key) async {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }

    Future<void> tapBack() async {
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }

    await shot("01-bienvenue");
    await tapKey("onboarding-next-btn");
    await shot("02-rythme");
    await tapKey("onboarding-next-btn");
    await shot("03-rappel");
    await tapKey("onboarding-next-btn");

    // Fill the past week so the history is worth looking at.
    final days = getIt<DayRepository>().load();
    final today = dayStart(getIt<Clock>()());
    const past = [(4, 6, true), (3, 3, true), (2, 7, true), (1, 4, true)];
    for (var i = 0; i < past.length; i++) {
      final key = dateKeyOf(addDays(today, -(i + 1)));
      final (quota, smoked, _) = past[i];
      days[key] = DayRecord(
        dateKey: key,
        quota: quota + 2,
        smoked: smoked + (i == 2 ? 3 : 0),
        seen: true,
      );
    }
    await getIt<DayRepository>().save(days);

    for (var i = 0; i < 3; i++) {
      await tapKey("home-add-btn");
    }
    await shot("04-accueil");

    await tapKey("home-settings-btn");
    await shot("05-reglages");
    await tapBack();

    await tapKey("home-about-btn");
    await shot("06-aide");
    await tapBack();

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await shot("07a-sombre-immediat");
    await tester.pump(const Duration(seconds: 2));
    await shot("07b-sombre-apres-2s");
  });
}
