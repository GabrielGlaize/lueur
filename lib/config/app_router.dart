import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../features/about/about_page.dart";
import "../features/app/app_cubit.dart";
import "../features/app/app_state.dart";
import "../features/app/splash_page.dart";
import "../features/home/home_cubit.dart";
import "../features/home/home_page.dart";
import "../features/onboarding/onboarding_page.dart";
import "../features/settings/settings_page.dart";
import "../services/day_planner.dart";
import "../core/dates.dart";
import "service_locator.dart";

class _CubitRefresh extends ChangeNotifier {
  _CubitRefresh(Stream<AppState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AppState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

GoRouter buildRouter(AppCubit appCubit) {
  return GoRouter(
    refreshListenable: _CubitRefresh(appCubit.stream),
    redirect: (context, state) {
      final location = state.matchedLocation;
      return switch (appCubit.state) {
        AppLoading() ||
        AppStorageCorrupted() => location == "/splash" ? null : "/splash",
        AppNeedsOnboarding() =>
          location == "/onboarding" ? null : "/onboarding",
        AppReady() =>
          location == "/splash" || location == "/onboarding" ? "/" : null,
      };
    },
    initialLocation: "/splash",
    routes: [
      GoRoute(path: "/splash", builder: (_, _) => const SplashPage()),
      GoRoute(path: "/onboarding", builder: (_, _) => const OnboardingPage()),
      GoRoute(
        path: "/",
        builder: (context, _) => BlocProvider(
          create: (_) => HomeCubit(
            planner: getIt<DayPlanner>(),
            clock: getIt<Clock>(),
            settings: () => (appCubit.state as AppReady).settings,
          )..refresh(),
          child: const HomePage(),
        ),
      ),
      GoRoute(path: "/settings", builder: (_, _) => const SettingsPage()),
      GoRoute(path: "/about", builder: (_, _) => const AboutPage()),
    ],
  );
}
