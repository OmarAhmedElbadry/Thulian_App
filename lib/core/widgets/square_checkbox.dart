import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_motion.dart";
import "../theme/tokens/app_sizes.dart";
import "../theme/tokens/app_spacing.dart";

/// Square checkbox with an optional label (mockup: habit rows, terms notice).
class SquareCheckbox extends StatelessWidget {
  const SquareCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onChanged != null;
    final duration = AppMotion.resolve(context, AppMotion.fast);

    final box = AnimatedContainer(
      duration: duration,
      curve: AppMotion.curve,
      width: AppSizes.checkbox,
      height: AppSizes.checkbox,
      decoration: BoxDecoration(
        color: value ? c.accent : Colors.transparent,
        border: Border.all(
          color: value ? c.accent : (enabled ? c.ink : c.hairline),
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: value
            ? Icon(
                Icons.check,
                key: const ValueKey(true),
                size: AppSizes.iconSmall,
                color: c.onAccent,
              )
            : const SizedBox.shrink(key: ValueKey(false)),
      ),
    );

    return Semantics(
      checked: value,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              box,
              if (label != null) ...[
                const SizedBox(width: AppSpacing.m),
                Flexible(
                  child: ExcludeSemantics(
                    child: Text(label!, style: context.type.bodySmall),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
