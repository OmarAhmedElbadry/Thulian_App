import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_spacing.dart";

/// TEMPORARY framed mascot placeholder ("FIG. 01 . IDLE / RIVE SLOT . STATE 01").
/// Replaced by the real Rive mascot component in Phase 6; the frame stays.
class MascotFigure extends StatelessWidget {
  const MascotFigure({
    super.key,
    this.figure = 1,
    this.state = "Idle",
    this.stateIndex = 1,
    this.size = 96,
  });

  final int figure;
  final String state;
  final int stateIndex;
  final double size;

  String _two(int n) => n.toString().padLeft(2, "0");

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.type.metaSmall;

    return Container(
      decoration: BoxDecoration(border: Border.all(color: c.inkMuted)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: c.surface,
            padding: const EdgeInsets.all(AppSpacing.l),
            alignment: Alignment.center,
            child: MascotFace(size: size),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "FIG. ${_two(figure)} \u00b7 ${state.toUpperCase()}",
                    style: style,
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Text(
                  "RIVE SLOT \u00b7 STATE ${_two(stateIndex)}",
                  style: style.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Face-only placeholder so screens can nest the mascot inside another plate.
class MascotFace extends StatelessWidget {
  const MascotFace({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PlaceholderFacePainter(c.accentSoft, c.ink)),
    );
  }
}

/// TEMPORARY heart-shaped mascot face used by the Phase 2 home dashboard.
///
/// The mockup gives the creature a 73 x 55 dusty-rose heart with ink eyes and
/// smile. Phase 6 swaps this for the animated Rive component; the surrounding
/// frame stays.
class HeartMascot extends StatelessWidget {
  const HeartMascot({super.key, this.width = 73});

  final double width;

  /// The mockup heart is roughly 4:3 (wider than tall).
  static const double aspectRatio = 73 / 55;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: width,
      height: width / aspectRatio,
      child: CustomPaint(
        painter: _HeartFacePainter(fill: c.mascot, ink: c.ink, eyes: c.accent),
      ),
    );
  }
}

class _HeartFacePainter extends CustomPainter {
  const _HeartFacePainter({
    required this.fill,
    required this.ink,
    required this.eyes,
  });

  final Color fill;
  final Color ink;
  final Color eyes;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final heart = Path()
      ..moveTo(w / 2, h)
      ..cubicTo(w * 0.06, h * 0.66, 0, h * 0.38, 0, h * 0.24)
      ..cubicTo(0, h * 0.03, w * 0.24, 0, w / 2, h * 0.20)
      ..cubicTo(w * 0.76, 0, w, h * 0.03, w, h * 0.24)
      ..cubicTo(w, h * 0.38, w * 0.94, h * 0.66, w / 2, h)
      ..close();

    canvas.drawPath(heart, Paint()..color = fill);
    canvas.drawPath(
      heart,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
    );

    final eyePaint = Paint()..color = eyes;
    final eyeWidth = w * 0.085;
    final eyeHeight = h * 0.15;
    for (final dx in [-w * 0.16, w * 0.16]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w / 2 + dx, h * 0.40),
          width: eyeWidth,
          height: eyeHeight,
        ),
        eyePaint,
      );
    }

    final smile = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.50),
        width: w * 0.24,
        height: h * 0.18,
      ),
      0.18,
      2.78,
      false,
      smile,
    );
  }

  @override
  bool shouldRepaint(covariant _HeartFacePainter old) =>
      old.fill != fill || old.ink != ink || old.eyes != eyes;
}

class _PlaceholderFacePainter extends CustomPainter {
  const _PlaceholderFacePainter(this.fill, this.ink);

  final Color fill;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height * 0.06);
    final radius = size.shortestSide * 0.38;

    final sprout = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;
    final sproutTop = Offset(center.dx, center.dy - radius - radius * 0.45);
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.85),
      sproutTop,
      sprout,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: sproutTop + Offset(-radius * 0.18, 0),
        width: radius * 0.45,
        height: radius * 0.35,
      ),
      2.6,
      2.2,
      false,
      sprout,
    );

    canvas.drawCircle(center, radius, Paint()..color = fill);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.045,
    );

    final eye = Paint()..color = ink;
    canvas.drawCircle(
      center + Offset(-radius * 0.32, -radius * 0.08),
      radius * 0.07,
      eye,
    );
    canvas.drawCircle(
      center + Offset(radius * 0.32, -radius * 0.08),
      radius * 0.07,
      eye,
    );

    final smile = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: center + Offset(0, radius * 0.18),
        width: radius * 0.55,
        height: radius * 0.42,
      ),
      0.25,
      2.65,
      false,
      smile,
    );
  }

  @override
  bool shouldRepaint(covariant _PlaceholderFacePainter old) =>
      old.fill != fill || old.ink != ink;
}
