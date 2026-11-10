import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../../../../core/widgets/app_toggle.dart";
import "../../../../core/widgets/display_title.dart";
import "../../../../core/widgets/mascot_figure.dart";

class DailyHourStep extends StatelessWidget {
  const DailyHourStep({
    super.key,
    required this.nameController,
    required this.reminder,
    required this.notificationsEnabled,
    required this.onNameChanged,
    required this.onPickTime,
    required this.onNotificationsChanged,
  });

  final TextEditingController nameController;
  final TimeOfDay reminder;
  final bool notificationsEnabled;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onPickTime;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final time =
        "${reminder.hour.toString().padLeft(2, "0")}:${reminder.minute.toString().padLeft(2, "0")}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DisplayTitle("Set your daily hour"),
        const SizedBox(height: AppSpacing.l),
        AppTextField(
          label: "Your name",
          controller: nameController,
          hint: "Amira",
          textInputAction: TextInputAction.done,
          onChanged: onNameChanged,
        ),
        const SizedBox(height: AppSpacing.l),
        Container(height: 1, color: c.hairline),
        const SizedBox(height: AppSpacing.m),
        Text(
          "DAILY REMINDER",
          style: context.type.metaSmall.copyWith(color: c.inkMuted),
        ),
        const SizedBox(height: AppSpacing.s),
        InkWell(
          onTap: onPickTime,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: Text(
              time,
              style: context.type.timer.copyWith(
                fontSize: 56,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        Container(height: 1, color: c.ink),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Allow notifications",
                    style: context.type.headline.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "REMINDERS AND ROOM INVITATIONS",
                    style: context.type.metaSmall.copyWith(color: c.inkMuted),
                  ),
                ],
              ),
            ),
            AppToggle(
              value: notificationsEnabled,
              semanticLabel: "Allow notifications",
              onChanged: onNotificationsChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.inkMuted),
          ),
          child: Row(
            children: [
              const MascotFace(size: 44),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FIG. 04 \u00b7 ENCOURAGING",
                      style: context.type.metaSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "I will nudge you once a day, never more.",
                      style: context.type.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
