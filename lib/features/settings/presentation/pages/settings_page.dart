import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../../../../core/di/injection.dart";
import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_cubit.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_dialog.dart";
import "../../../../core/widgets/app_toggle.dart";
import "../../../../core/widgets/display_title.dart";
import "../../../../core/widgets/journal_body.dart";
import "../../../../core/widgets/record_header.dart";
import "../../../../core/widgets/section_header.dart";
import "../../../../core/widgets/segmented_choice.dart";
import "../../../profile/data/profile_mock_data.dart";
import "../../domain/entities/app_settings.dart";
import "../../../auth/presentation/cubit/auth_cubit.dart";
import "../cubit/settings_cubit.dart";
import "../widgets/settings_row.dart";

/// Preferences (P. 08 / 12). Reached from the profile page, so the bottom bar
/// keeps "You" selected. Theme and settings persist locally.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.cubit});

  /// Optional override, mainly for tests. Defaults to the app-wide cubit.
  final SettingsCubit? cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>.value(
      value: cubit ?? sl<SettingsCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showAppDialog(
      context,
      recordLabel: "Account \u00b7 N\u00ba 0314",
      title: "Sign out?",
      message: "You can sign back in at any time.",
      confirmLabel: "Sign out",
    );
    if (confirmed != true || !context.mounted) return;
    if (sl.isRegistered<AuthCubit>()) {
      await sl<AuthCubit>().signOut();
      if (!context.mounted) return;
      final result = sl<AuthCubit>().state;
      if (result.status == AuthActionStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? "Sign-out failed.")),
        );
        return;
      }
    }
    context.go(AppRoutes.authSignIn);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final settings = context.read<SettingsCubit>();
    final themeMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return Column(
      children: [
        const RecordHeader(
          label: "PREFERENCES \u00b7 N\u00ba 0314",
          page: "P. 08 / 12",
        ),
        Expanded(
          child: BlocBuilder<SettingsCubit, AppSettings>(
            builder: (context, state) {
              return JournalBody(
                children: [
                  const DisplayTitle("Settings"),
                  const SizedBox(height: AppSpacing.l),
                  const SectionHeader(
                    number: "01",
                    title: "Appearance",
                    strong: true,
                  ),
                  SettingsRow(
                    title: "Theme",
                    subtitle: "Paper or ink",
                    trailing: SizedBox(
                      width: 150,
                      child: SegmentedChoice<ThemeMode>(
                        options: const [
                          (ThemeMode.light, "Light"),
                          (ThemeMode.dark, "Dark"),
                        ],
                        value: themeMode,
                        onChanged: context.read<ThemeCubit>().setMode,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const SectionHeader(
                    number: "02",
                    title: "Notifications",
                    strong: true,
                  ),
                  SettingsRow(
                    title: "Daily reminder",
                    subtitle: "21:30 \u00b7 daily",
                    trailing: AppToggle(
                      semanticLabel: "Daily reminder",
                      value: state.dailyReminder,
                      onChanged: settings.setDailyReminder,
                    ),
                  ),
                  SettingsRow(
                    title: "Room invitations",
                    subtitle: "Study rooms",
                    trailing: AppToggle(
                      semanticLabel: "Room invitations",
                      value: state.roomInvitations,
                      onChanged: settings.setRoomInvitations,
                    ),
                  ),
                  SettingsRow(
                    title: "Weekly digest",
                    subtitle: "Sundays",
                    trailing: AppToggle(
                      semanticLabel: "Weekly digest",
                      value: state.weeklyDigest,
                      onChanged: settings.setWeeklyDigest,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const SectionHeader(
                    number: "03",
                    title: "Experience",
                    strong: true,
                  ),
                  SettingsRow(
                    title: "Sound",
                    subtitle: "Completion chime",
                    trailing: AppToggle(
                      semanticLabel: "Sound",
                      value: state.sound,
                      onChanged: settings.setSound,
                    ),
                  ),
                  SettingsRow(
                    title: "Reduce motion",
                    subtitle: "Fewer animations",
                    trailing: AppToggle(
                      semanticLabel: "Reduce motion",
                      value: state.reduceMotion,
                      onChanged: settings.setReduceMotion,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const SectionHeader(
                    number: "04",
                    title: "Account",
                    strong: true,
                  ),
                  SettingsRow(
                    title: "Language",
                    subtitle: "English",
                    trailing: Text("EN \u2193", style: t.meta),
                  ),
                  SettingsRow(
                    title: "Account",
                    subtitle: ProfileMockData.snapshot.email,
                    onTap: () => _signOut(context),
                    trailing: Text("\u2192", style: t.meta),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    "VERSION 1.0 \u00b7 RECORD N\u00ba 0314",
                    style: t.metaSmall,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
