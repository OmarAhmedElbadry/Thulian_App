import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_link.dart";
import "../../../../core/widgets/journal_body.dart";
import "../../../../core/widgets/record_header.dart";
import "../../../../core/widgets/section_header.dart";
import "../../../dashboard/presentation/dashboard_format.dart";
import "../../data/profile_mock_data.dart";
import "../../domain/entities/profile_snapshot.dart";
import "../widgets/friend_row.dart";
import "../widgets/profile_identity.dart";
import "../widgets/profile_stat_strip.dart";
import "../widgets/stamp_tile.dart";
import "../widgets/week_focus_chart.dart";

/// Personal file and statistics (P. 07 / 12). Mock snapshot until Phase 5.
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    this.profile = ProfileMockData.snapshot,
    this.now,
  });

  final ProfileSnapshot profile;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final today = now ?? DateTime.now();

    return Column(
      children: [
        const RecordHeader(
          label: "PERSONAL FILE \u00b7 N\u00ba 0313",
          page: "P. 07 / 12",
        ),
        Expanded(
          child: JournalBody(
            children: [
              ProfileIdentity(profile: profile),
              const SizedBox(height: AppSpacing.l),
              ProfileStatStrip(
                streakDays: profile.streakDays,
                habitsFiled: profile.habitsFiled,
                studyHours: profile.studyHours,
              ),
              const SizedBox(height: AppSpacing.l),
              SectionHeader(
                number: "01",
                title: "This week",
                trailing: "WK ${isoWeekNumber(today)}",
                strong: true,
              ),
              const SizedBox(height: AppSpacing.m),
              WeekFocusChart(
                activity: profile.weekActivity,
                highlightIndex: profile.weekHighlightIndex,
              ),
              const SizedBox(height: AppSpacing.l),
              SectionHeader(
                number: "02",
                title: "Stamps",
                trailing: "${profile.unlockedStamps} of ${profile.stampsTotal}",
                strong: true,
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  for (var i = 0; i < profile.stamps.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.s),
                    Expanded(child: StampTile(stamp: profile.stamps[i])),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              SectionHeader(
                number: "03",
                title: "Friends",
                trailing: "Top ${profile.friends.length} this week",
                strong: true,
              ),
              for (var i = 0; i < profile.friends.length; i++)
                FriendRow(number: i + 1, friend: profile.friends[i]),
              const SizedBox(height: AppSpacing.m),
              AppLink(
                label: "Settings",
                onTap: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
