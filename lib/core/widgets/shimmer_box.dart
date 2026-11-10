import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";

/// Loading placeholder. Static (no animation) when the system asks to reduce motion.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, this.width, this.height = 16});

  final double? width;
  final double height;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = c.surface;
    final highlight = Color.alphaBlend(c.hairline, c.surface);

    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(width: widget.width, height: widget.height, color: base);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
              transform: _SlideTransform(_controller.value * 2 - 1),
            ),
          ),
        );
      },
    );
  }
}

class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.slide);

  final double slide;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slide, 0, 0);
  }
}
