import "package:flutter/material.dart";

/// Typography roles.
///  - display/body: Playfair Display (variable font, wght axis)
///  - meta: IBM Plex Mono (dates, timers, stats, labels, buttons)
@immutable
class ThulianType extends ThemeExtension<ThulianType> {
  const ThulianType({
    required this.displayXL,
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.bodySmall,
    required this.meta,
    required this.metaSmall,
    required this.timer,
    required this.stat,
  });

  final TextStyle displayXL;
  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle meta;
  final TextStyle metaSmall;
  final TextStyle timer;
  final TextStyle stat;

  static const _serif = "PlayfairDisplay";
  static const _mono = "IBMPlexMono";

  static TextStyle _playfair(
    double size,
    FontWeight weight,
    Color color, {
    double height = 1.15,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: _serif,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation("wght", weight.value.toDouble())],
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _plexMono(
    double size,
    FontWeight weight,
    Color color, {
    double height = 1.3,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: _mono,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  factory ThulianType.from({required Color ink, required Color muted}) {
    return ThulianType(
      displayXL: _playfair(
        44,
        FontWeight.w800,
        ink,
        height: 1.05,
        letterSpacing: -0.5,
      ),
      display: _playfair(
        34,
        FontWeight.w800,
        ink,
        height: 1.08,
        letterSpacing: -0.3,
      ),
      headline: _playfair(24, FontWeight.w700, ink),
      title: _playfair(18, FontWeight.w700, ink, height: 1.25),
      body: _playfair(16, FontWeight.w400, ink, height: 1.5),
      bodySmall: _playfair(14, FontWeight.w400, ink, height: 1.45),
      meta: _plexMono(12, FontWeight.w500, ink, letterSpacing: 1.0),
      metaSmall: _plexMono(10, FontWeight.w400, muted, letterSpacing: 1.2),
      timer: _plexMono(
        72,
        FontWeight.w500,
        ink,
        height: 1.0,
        letterSpacing: -1,
      ),
      stat: _playfair(36, FontWeight.w700, ink, height: 1.0),
    );
  }

  TextTheme toTextTheme() {
    return TextTheme(
      displayLarge: displayXL,
      displayMedium: display,
      headlineMedium: headline,
      titleMedium: title,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: bodySmall,
      labelLarge: meta,
      labelMedium: meta,
      labelSmall: metaSmall,
    );
  }

  @override
  ThulianType copyWith({
    TextStyle? displayXL,
    TextStyle? display,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? meta,
    TextStyle? metaSmall,
    TextStyle? timer,
    TextStyle? stat,
  }) {
    return ThulianType(
      displayXL: displayXL ?? this.displayXL,
      display: display ?? this.display,
      headline: headline ?? this.headline,
      title: title ?? this.title,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      meta: meta ?? this.meta,
      metaSmall: metaSmall ?? this.metaSmall,
      timer: timer ?? this.timer,
      stat: stat ?? this.stat,
    );
  }

  @override
  ThulianType lerp(ThemeExtension<ThulianType>? other, double t) {
    if (other is! ThulianType) return this;
    return ThulianType(
      displayXL: TextStyle.lerp(displayXL, other.displayXL, t)!,
      display: TextStyle.lerp(display, other.display, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      meta: TextStyle.lerp(meta, other.meta, t)!,
      metaSmall: TextStyle.lerp(metaSmall, other.metaSmall, t)!,
      timer: TextStyle.lerp(timer, other.timer, t)!,
      stat: TextStyle.lerp(stat, other.stat, t)!,
    );
  }
}
