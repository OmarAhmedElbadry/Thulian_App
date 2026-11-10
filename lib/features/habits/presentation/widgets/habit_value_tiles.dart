import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";

/// Label + large mono value on an underline. Tapping opens a picker.
class HabitValueTile extends StatelessWidget {
  const HabitValueTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;

    return Semantics(
      button: true,
      label: "$label, $value",
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: t.metaSmall),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                child: Text(
                  value,
                  style: t.meta.copyWith(fontSize: 24, letterSpacing: 0),
                ),
              ),
              Container(height: 1, color: c.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label + large mono value with square minus / plus buttons.
class HabitStepperTile extends StatelessWidget {
  const HabitStepperTile({
    super.key,
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: t.metaSmall),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: t.meta.copyWith(fontSize: 24, letterSpacing: 0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StepButton(
                symbol: "\u2212",
                semanticLabel: "Decrease target",
                onTap: onDecrease,
              ),
              const SizedBox(width: 6),
              _StepButton(
                symbol: "+",
                semanticLabel: "Increase target",
                onTap: onIncrease,
              ),
            ],
          ),
        ),
        Container(height: 1, color: c.inkMuted),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.symbol,
    required this.semanticLabel,
    required this.onTap,
  });

  final String symbol;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: c.ink)),
          child: ExcludeSemantics(
            child: Text(symbol, style: context.type.meta),
          ),
        ),
      ),
    );
  }
}
