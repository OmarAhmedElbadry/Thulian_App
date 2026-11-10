import "package:flutter/material.dart";

import "app_palette.dart";

/// Semantic colour tokens (single source of truth for UI colour).
@immutable
class ThulianColors extends ThemeExtension<ThulianColors> {
  const ThulianColors({
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.hairline,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.mascot,
  });

  final Color background;
  final Color surface;
  final Color ink;
  final Color inkMuted;
  final Color hairline;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;

  /// Mascot fill. Temporary placeholder colour until the Rive mascot lands.
  final Color mascot;

  static const light = ThulianColors(
    background: AppPalette.paper,
    surface: AppPalette.paperSurface,
    ink: AppPalette.darkGray,
    inkMuted: Color(0x8C2F2F2F), // ink @ ~55 %
    hairline: Color(0x332F2F2F), // ink @ 20 %
    accent: AppPalette.deepMagenta,
    onAccent: AppPalette.paper,
    accentSoft: AppPalette.lightMagenta,
    mascot: AppPalette.mascotBlush,
  );

  static const dark = ThulianColors(
    background: AppPalette.nightBackground,
    surface: AppPalette.nightSurface,
    ink: AppPalette.paper,
    inkMuted: Color(0x8CF3EDE1), // paper @ ~55 %
    hairline: Color(0x33F3EDE1), // paper @ 20 %
    accent: AppPalette.lightMagenta,
    onAccent: AppPalette.nightBackground,
    accentSoft: AppPalette.lightMagenta,
    mascot: AppPalette.mascotBlush,
  );

  @override
  ThulianColors copyWith({
    Color? background,
    Color? surface,
    Color? ink,
    Color? inkMuted,
    Color? hairline,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? mascot,
  }) {
    return ThulianColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      hairline: hairline ?? this.hairline,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
      mascot: mascot ?? this.mascot,
    );
  }

  @override
  ThulianColors lerp(ThemeExtension<ThulianColors>? other, double t) {
    if (other is! ThulianColors) return this;
    return ThulianColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      mascot: Color.lerp(mascot, other.mascot, t)!,
    );
  }
}
