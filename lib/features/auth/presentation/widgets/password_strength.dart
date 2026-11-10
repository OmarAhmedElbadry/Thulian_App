import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_motion.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../auth_validators.dart";

/// Four-cell password strength meter: bars plus a mono label.
class PasswordStrength extends StatelessWidget {
  const PasswordStrength({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final level = AuthValidators.passwordStrength(value);
    final duration = AppMotion.resolve(context, AppMotion.base);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < 4; i++)
              Expanded(
                child: AnimatedContainer(
                  duration: duration,
                  curve: AppMotion.curve,
                  height: 4,
                  margin: EdgeInsets.only(right: i == 3 ? 0 : AppSpacing.s),
                  color: i < level ? c.accent : c.hairline,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            Text("STRENGTH", style: context.type.metaSmall),
            const SizedBox(width: AppSpacing.s),
            AnimatedSwitcher(
              duration: duration,
              switchInCurve: AppMotion.curve,
              switchOutCurve: AppMotion.curve,
              child: Text(
                AuthValidators.strengthLabel(level),
                key: ValueKey(level),
                style: context.type.metaSmall.copyWith(
                  color: level >= 3 ? c.accent : c.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
