import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_motion.dart";
import "../dashboard_format.dart";

/// The large "67 %" completion figure, the filed-habits caption and the thin
/// progress rule underneath. Sized to sit beside the mascot card.
class CompletionBlock extends StatelessWidget {
  const CompletionBlock({
    super.key,
    required this.percent,
    required this.completed,
    required this.total,
  });

  final int percent;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "COMPLETED TODAY",
          style: context.type.metaSmall.copyWith(color: c.inkMuted),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$percent",
                style: context.type.displayXL.copyWith(
                  fontSize: 90,
                  height: 0.88,
                  letterSpacing: -2,
                ),
              ),
              Text(
                "%",
                style: context.type.displayXL.copyWith(
                  fontSize: 30,
                  height: 0.88,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          completionLabel(completed, total),
          style: context.type.metaSmall.copyWith(color: c.inkMuted),
        ),
        const SizedBox(height: 6),
        _ProgressRule(value: percent / 100),
      ],
    );
  }
}

class _ProgressRule extends StatelessWidget {
  const _ProgressRule({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fraction = value.clamp(0.0, 1.0).toDouble();
    final duration = AppMotion.resolve(context, AppMotion.base);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          width: width,
          height: 3,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: ColoredBox(color: c.ink.withValues(alpha: 0.12)),
              ),
              AnimatedContainer(
                duration: duration,
                curve: AppMotion.curve,
                width: width * fraction,
                height: 3,
                color: c.accent,
              ),
            ],
          ),
        );
      },
    );
  }
}
