import "package:flutter/material.dart";

import "../theme/tokens/app_motion.dart";

/// An [IndexedStack] replacement that cross-fades between branches while
/// keeping every branch mounted (so tab state survives switching).
///
/// Inactive branches have their own tickers paused and are removed from the
/// semantics tree. The active branch is painted last so the incoming page
/// fades over the outgoing one. Reduce-motion disables the fade.
class FadeIndexedStack extends StatelessWidget {
  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.resolve(context, AppMotion.base);
    // Paint inactive branches first, active last.
    final order = <int>[
      for (var i = 0; i < children.length; i++)
        if (i != index) i,
      if (index >= 0 && index < children.length) index,
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        for (final i in order)
          _Branch(
            key: ValueKey(i),
            active: i == index,
            duration: duration,
            child: children[i],
          ),
      ],
    );
  }
}

class _Branch extends StatelessWidget {
  const _Branch({
    super.key,
    required this.active,
    required this.duration,
    required this.child,
  });

  final bool active;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !active,
      child: ExcludeSemantics(
        excluding: !active,
        child: AnimatedOpacity(
          opacity: active ? 1 : 0,
          duration: duration,
          curve: AppMotion.curve,
          child: AnimatedScale(
            scale: active ? 1 : 0.995,
            duration: duration,
            curve: AppMotion.curve,
            // Pause page-level tickers only; the opacity/scale controllers
            // live outside so the outgoing branch can still fade.
            child: TickerMode(enabled: active, child: child),
          ),
        ),
      ),
    );
  }
}
