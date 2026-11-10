import "package:flutter/material.dart";

import "../theme/tokens/app_motion.dart";

/// Fades and lifts its child into place once, shortly after being mounted.
///
/// Used for editorial page bodies so content arrives in a quiet cascade instead
/// of popping in. Honours the system "reduce motion" setting.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.reveal,
    this.offset = const Offset(0, 14),
  });

  final Widget child;

  /// Wait before the animation starts. Compose with [AppMotion.stagger] for
  /// cascades.
  final Duration delay;

  final Duration duration;

  /// Starting translation in logical pixels. Only the Y axis is used by the
  /// editorial layouts, but both are supported.
  final Offset offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _started = false;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total);
    final totalMicros = total.inMicroseconds;
    final start = totalMicros == 0
        ? 0.0
        : widget.delay.inMicroseconds / totalMicros;
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start.clamp(0, 1), 1, curve: AppMotion.entrance),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion || _controller.duration == Duration.zero) {
      _controller.value = 1;
      return;
    }

    // Start after the first frame so the initial 0-value is painted and the
    // transition is visible even when the widget is mounted during a route
    // push.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final t = _animation.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(
              widget.offset.dx * (1 - t),
              widget.offset.dy * (1 - t),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// A vertical stack of [Reveal]s with an increasing delay per item.
///
/// The delay steps are derived from [AppMotion.stagger], so the whole group
/// resolves in roughly the duration of a single reveal.
class RevealGroup extends StatelessWidget {
  const RevealGroup({
    super.key,
    required this.children,
    this.delay = Duration.zero,
    this.step = 0.07,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.min,
  });

  final List<Widget> children;

  /// Delay applied to the first child.
  final Duration delay;

  /// Fraction of [AppMotion.reveal] between consecutive items.
  final double step;

  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (var i = 0; i < children.length; i++)
          Reveal(delay: delay + _staggerDelay(i), child: children[i]),
      ],
    );
  }

  Duration _staggerDelay(int index) {
    final fraction = AppMotion.stagger(index, step: step);
    return Duration(
      milliseconds: (fraction * AppMotion.reveal.inMilliseconds).round(),
    );
  }
}
