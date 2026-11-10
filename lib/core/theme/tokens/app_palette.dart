import "package:flutter/painting.dart";

/// Raw brand colours. Widgets must NOT use these directly; read
/// ThulianColors from the theme so light and dark stay consistent.
abstract final class AppPalette {
  // Brand sheet
  static const Color darkGray = Color(0xFF2F2F2F);
  static const Color neonPink = Color(0xFF4B2F4C); // plum
  static const Color grayRed = Color(0xFF2D1C19); // umber
  static const Color lightMagenta = Color(0xFFF2BDD9);

  // Sampled from the approved mockups
  static const Color paper = Color(0xFFF3EDE1);
  static const Color paperSurface = Color(0xFFEBE4D4);
  static const Color deepMagenta = Color(0xFFC0136F);
  static const Color nightBackground = Color(0xFF1B1A18);
  static const Color nightSurface = Color(0xFF2A2724);

  /// Dusty rose used by the (temporary) heart mascot until Phase 6 Rive.
  static const Color mascotBlush = Color(0xFFE4B7BE);
}
