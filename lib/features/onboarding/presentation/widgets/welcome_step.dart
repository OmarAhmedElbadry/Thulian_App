import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/display_title.dart";
import "../../../../core/widgets/mascot_figure.dart";

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MascotFigure(figure: 0, size: 150),
        const SizedBox(height: AppSpacing.xl),
        const DisplayTitle(
          "A quiet archive of everything you do",
          extraLarge: true,
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          "Habits, focus hours and small wins, filed page by page in a journal that is only yours.",
          style: context.type.bodySmall.copyWith(color: c.inkMuted),
        ),
      ],
    );
  }
}
