import "package:flutter/material.dart";

import "../../../../core/theme/tokens/app_motion.dart";

/// Page-turn between onboarding steps. Forward slides in from the right,
/// back slides in from the left. Honours reduce-motion.
class JournalStepSwitcher extends StatelessWidget {
  const JournalStepSwitcher({
    super.key,
    required this.stepIndex,
    required this.forward,
    required this.child,
    this.expand = false,
  });

  final int stepIndex;
  final bool forward;
  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.resolve(context, AppMotion.slow);
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: duration,
      switchInCurve: AppMotion.curve,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          fit: expand ? StackFit.expand : StackFit.loose,
          alignment: Alignment.topCenter,
          children: [
            for (final previous in previousChildren)
              IgnorePointer(child: previous),
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey<int>(stepIndex);
        final from = Offset(forward ? 0.08 : -0.08, 0);
        final begin = incoming ? from : Offset(-from.dx, 0);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: AppMotion.curve),
            ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey<int>(stepIndex), child: child),
    );
  }
}
