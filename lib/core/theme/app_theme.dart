import "package:flutter/material.dart";

/// Palette. Text and accent pairs keep a contrast ratio of at least 4.5:1
/// against their background (WCAG AA) in both schemes.
abstract final class AppColors {
  static const ink = Color(0xFF12100F);
  static const panel = Color(0xFF24201D);
  static const line = Color(0xFF4A423B);
  static const cream = Color(0xFFF3EBDD);
  static const mutedOnDark = Color(0xFFB4AA9C);
  static const coral = Color(0xFFFF7A5C);
  static const peach = Color(0xFFFFB38B);

  static const paper = Color(0xFFF7F1E6);
  static const card = Color(0xFFFFFFFF);
  static const lineLight = Color(0xFFD9CDB9);
  static const mutedOnLight = Color(0xFF65594E);
  static const embers = Color(0xFFA63A1A);
}

ThemeData buildDarkTheme() => _build(
  const ColorScheme.dark(
    primary: AppColors.coral,
    onPrimary: AppColors.ink,
    secondary: AppColors.peach,
    surface: AppColors.panel,
    onSurface: AppColors.cream,
    onSurfaceVariant: AppColors.mutedOnDark,
    outline: AppColors.line,
    error: Color(0xFFFF8F8F),
  ),
  AppColors.ink,
);

ThemeData buildLightTheme() => _build(
  const ColorScheme.light(
    primary: AppColors.embers,
    onPrimary: Colors.white,
    secondary: AppColors.embers,
    surface: AppColors.card,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.mutedOnLight,
    outline: AppColors.lineLight,
    error: Color(0xFFB3261E),
  ),
  AppColors.paper,
);

ThemeData _build(ColorScheme scheme, Color background) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
  );
  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: scheme.outline),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.onSurface,
      contentTextStyle: TextStyle(
        color: background,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
