import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../../../core/theme/theme_extensions.dart";

/// Seven small squares representing the current week's completions.
/// Filled accent = done, outlined hairline = not done / future.
/// Matches the "■■□□□□□" pattern from the mockup.
class CompletionDots extends StatefulWidget {
  const CompletionDots({
    super.key,
    required this.completions,
    this.todayIndex = -1,
    this.onSetTodayCompletion,
  }) : assert(completions.length == 7);

  /// Seven booleans, Monday to Sunday.
  final List<bool> completions;
  final int todayIndex;
  final ValueChanged<bool>? onSetTodayCompletion;

  @override
  State<CompletionDots> createState() => _CompletionDotsState();
}

class _CompletionDotsState extends State<CompletionDots>
    with SingleTickerProviderStateMixin {
  static const _size = 10.0;
  static const _gap = 3.0;

  late final AnimationController _celebration;
  late final Animation<double> _pop;

  @override
  void initState() {
    super.initState();
    _celebration = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: 1,
    );
    _pop = CurvedAnimation(parent: _celebration, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(covariant CompletionDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.todayIndex;
    if (index >= 0 &&
        index < widget.completions.length &&
        index < oldWidget.completions.length &&
        !oldWidget.completions[index] &&
        widget.completions[index]) {
      _celebration.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _celebration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.completions.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          if (i == widget.todayIndex && widget.onSetTodayCompletion != null)
            Semantics(
              button: true,
              label: widget.completions[i]
                  ? "Mark today incomplete"
                  : "Mark today complete",
              child: InkWell(
                onTap: () {
                  final willComplete = !widget.completions[i];
                  if (willComplete) HapticFeedback.selectionClick();
                  widget.onSetTodayCompletion!(willComplete);
                },
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: ScaleTransition(
                      scale: _pop,
                      child: _CompletionSquare(
                        done: widget.completions[i],
                        size: _size,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            _CompletionSquare(done: widget.completions[i], size: _size),
        ],
      ],
    );
  }
}

class _CompletionSquare extends StatelessWidget {
  const _CompletionSquare({required this.done, required this.size});

  final bool done;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: done ? c.accent : Colors.transparent,
        border: Border.all(color: done ? c.accent : c.hairline),
      ),
    );
  }
}
