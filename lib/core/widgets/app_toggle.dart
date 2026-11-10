import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_motion.dart";
import "../theme/tokens/app_sizes.dart";

/// Square on/off switch (settings screen). On = filled accent.
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onChanged != null;
    final duration = AppMotion.resolve(context, AppMotion.fast);
    const pad = 3.0;
    const knob = AppSizes.toggleHeight - pad * 2 - 2;

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          child: Center(
            widthFactor: 1,
            child: AnimatedContainer(
              duration: duration,
              width: AppSizes.toggleWidth,
              height: AppSizes.toggleHeight,
              padding: const EdgeInsets.all(pad),
              decoration: BoxDecoration(
                color: value ? c.accent : Colors.transparent,
                border: Border.all(
                  color: value ? c.accent : (enabled ? c.ink : c.hairline),
                ),
              ),
              child: AnimatedAlign(
                duration: duration,
                curve: AppMotion.curve,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: knob,
                  height: knob,
                  color: value ? c.onAccent : c.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
