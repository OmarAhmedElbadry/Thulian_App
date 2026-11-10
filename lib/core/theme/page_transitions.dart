import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "tokens/app_motion.dart";

/// Editorial page transition: the arriving page fades in while sliding a few
/// percent from the right, and the page underneath drifts slightly left.
///
/// Registered for every platform in [AppTheme] so navigation feels identical
/// on Android, iOS, desktop and web.
class EditorialPageTransitionsBuilder extends PageTransitionsBuilder {
  const EditorialPageTransitionsBuilder({this.distance = 0.035});

  /// Horizontal travel of the incoming page, as a fraction of its width.
  final double distance;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final enter = CurvedAnimation(
      parent: animation,
      curve: AppMotion.emphasized,
      reverseCurve: AppMotion.exit,
    );
    final exit = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.emphasized,
      reverseCurve: AppMotion.exit,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(enter),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(distance, 0),
          end: Offset.zero,
        ).animate(enter),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: Offset(-distance * 0.4, 0),
          ).animate(exit),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.88).animate(exit),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A page for the auth flow that rises into place instead of sliding sideways.
///
/// The motion is deliberately softer than a full modal: a short fade plus a
/// 2.5 % upward drift, so sign-in and recovery feel like turning a page.
class JournalPage<T> extends CustomTransitionPage<T> {
  const JournalPage({required super.child, super.key})
    : super(
        transitionDuration: AppMotion.page,
        reverseTransitionDuration: AppMotion.page,
        transitionsBuilder: _transitions,
      );

  static Widget _transitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final enter = CurvedAnimation(
      parent: animation,
      curve: AppMotion.emphasized,
      reverseCurve: AppMotion.exit,
    );
    final exit = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppMotion.emphasized,
      reverseCurve: AppMotion.exit,
    );

    return FadeTransition(
      opacity: enter,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(enter),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0, -0.0125),
          ).animate(exit),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.9).animate(exit),
            child: child,
          ),
        ),
      ),
    );
  }
}
