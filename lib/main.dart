import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:go_router/go_router.dart";

import "config/app_router.dart";
import "config/service_locator.dart";
import "core/theme/app_theme.dart";
import "features/app/app_cubit.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  final appCubit = getIt<AppCubit>();
  runApp(LueurApp(appCubit: appCubit, router: buildRouter(appCubit)));
  await appCubit.start();
}

class LueurApp extends StatelessWidget {
  const LueurApp({super.key, required this.appCubit, required this.router});

  final AppCubit appCubit;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: appCubit,
      child: MaterialApp.router(
        title: "Lueur",
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.system,
        locale: const Locale("fr"),
        supportedLocales: const [Locale("fr")],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
  }
}
