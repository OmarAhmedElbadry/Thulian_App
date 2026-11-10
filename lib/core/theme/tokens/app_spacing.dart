/// Spacing scale (logical pixels).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Horizontal page margin used by every screen.
  static const double pageMargin = 20;
}

/// Editorial design uses sharp corners and hairlines.
abstract final class AppBorders {
  static const double hairline = 1;
  static const double radius = 0;
  static const double radiusSmall = 2;
}
