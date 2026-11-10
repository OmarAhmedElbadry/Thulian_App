import "package:flutter/widgets.dart";

/// Motion tokens. Always resolve durations through [resolve] so the
/// system "reduce motion" setting is respected.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration page = Duration(milliseconds: 340);
  static const Duration reveal = Duration(milliseconds: 680);

  /// Standard decelerating curve for most state changes.
  static const Curve curve = Curves.easeOutCubic;

  /// Emphasised curve for page and reveal transitions (M3-style).
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);

  /// Soft arrival curve for editorial reveals.
  static const Curve entrance = Cubic(0.16, 1, 0.3, 1);

  /// Departing content leaves a little faster than it arrived.
  static const Curve exit = Cubic(0.3, 0, 0.8, 0.15);

  static Duration resolve(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }

  /// Stagger start for item [index] in a group of reveals.
  static double stagger(int index, {double step = 0.07, double max = 0.45}) {
    return (index * step).clamp(0, max);
  }
}
