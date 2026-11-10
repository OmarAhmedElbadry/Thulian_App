import "package:flutter/material.dart";

import "page_transitions.dart";
import "tokens/app_palette.dart";
import "tokens/thulian_colors.dart";
import "typography/thulian_type.dart";

abstract final class AppTheme {
  static final ThemeData light = _build(Brightness.light, ThulianColors.light);
  static final ThemeData dark = _build(Brightness.dark, ThulianColors.dark);

  static ThemeData _build(Brightness brightness, ThulianColors c) {
    final type = ThulianType.from(ink: c.ink, muted: c.inkMuted);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accentSoft,
      onSecondary: AppPalette.darkGray,
      error: c.accent,
      onError: c.onAccent,
      surface: c.background,
      onSurface: c.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      textTheme: type.toTextTheme(),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: EditorialPageTransitionsBuilder(),
          TargetPlatform.iOS: EditorialPageTransitionsBuilder(),
          TargetPlatform.fuchsia: EditorialPageTransitionsBuilder(),
          TargetPlatform.linux: EditorialPageTransitionsBuilder(),
          TargetPlatform.macOS: EditorialPageTransitionsBuilder(),
          TargetPlatform.windows: EditorialPageTransitionsBuilder(),
        },
      ),
      extensions: <ThemeExtension<dynamic>>[c, type],
    );
  }
}
