import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_sizes.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/hairline_divider.dart";
import "../../../../core/widgets/record_header.dart";
import "../../../../core/widgets/reveal.dart";
import "../../../../core/widgets/section_header.dart";
import "../../data/dashboard_mock_data.dart";
import "../../domain/entities/dashboard_snapshot.dart";
import "../dashboard_format.dart";
import "../widgets/completion_block.dart";
import "../widgets/habit_brief_row.dart";
import "../widgets/mascot_panel.dart";
import "../widgets/mascot_state_strip.dart";
import "../widgets/mini_stat_card.dart";
import "../widgets/stat_strip.dart";

/// The daily record. Mock data and local completion state only; Phase 5 swaps
/// the snapshot for a cubit backed by Firestore.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.data = DashboardMockData.snapshot, this.now});

  final DashboardSnapshot data;

  /// Injectable clock so the greeting, date line and record numbers can be
  /// tested.
  final DateTime? now;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _mascotStates = [
    "IDLE",
    "HAPPY",
    "STUDY",
    "SLEEPY",
    "ENCOURAGE",
    "CELEBRATE",
  ];
  static const _activeState = 4;

  late List<HabitBrief> _habits;

  @override
  void initState() {
    super.initState();
    _habits = [...widget.data.habits];
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _habits = [...widget.data.habits];
    }
  }

  void _toggleHabit(String id) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index == -1) return;
    setState(() {
      _habits[index] = _habits[index].copyWith(done: !_habits[index].done);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = widget.now ?? DateTime.now();
    final data = widget.data;
    final completed = _habits.where((habit) => habit.done).length;
    final percent = _habits.isEmpty
        ? 0
        : (completed / _habits.length * 100).round();

    return Column(
      children: [
        RecordHeader(
          label: "DAILY RECORD",
          center: "NO ${recordNumber(now)}",
          page: "P. 01 / 12",
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                4,
                AppSpacing.pageMargin,
                AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: RevealGroup(
                  children: [
                    Text(
                      shortDateLabel(now),
                      style: context.type.metaSmall.copyWith(
                        color: c.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: context.type.display.copyWith(height: 1),
                              children: [
                                TextSpan(text: "${greetingFor(now)},\n"),
                                TextSpan(text: data.displayName),
                                TextSpan(
                                  text: ".",
                                  style: TextStyle(color: c.accent),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "WK ${isoWeekNumber(now)}",
                              style: context.type.metaSmall.copyWith(
                                color: c.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "DAY ${dayOfYear(now)}",
                              style: context.type.metaSmall.copyWith(
                                color: c.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const HairlineDivider(strong: true),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 197,
                          child: CompletionBlock(
                            percent: percent,
                            completed: completed,
                            total: _habits.length,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(
                          flex: 134,
                          child: MascotPanel(
                            state: "Encouraging",
                            stateIndex: _activeState + 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const MascotStateStrip(
                      states: _mascotStates,
                      activeIndex: _activeState,
                    ),
                    const SizedBox(height: 10),
                    SectionHeader(
                      number: "01",
                      title: "Today's habits",
                      trailing: "${_habits.length} entries",
                      strong: true,
                    ),
                    for (var i = 0; i < _habits.length; i++)
                      HabitBriefRow(
                        key: ValueKey(_habits[i].id),
                        number: i + 1,
                        habit: _habits[i],
                        onToggle: () => _toggleHabit(_habits[i].id),
                      ),
                    const SizedBox(height: 20),
                    StatStrip(
                      streakDays: data.streakDays,
                      focusMinutes: data.focusMinutes,
                      weekDone: data.weekDone,
                      weekTotal: data.weekTotal,
                      weekActivity: data.weekActivity,
                      weekHighlightIndex: data.weekHighlightIndex,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: MiniStatCard(
                            key: const ValueKey("home-study-rooms"),
                            number: "05",
                            title: "Study rooms",
                            value: "${data.roomsLive} live now",
                            onTap: () => context.go(AppRoutes.rooms),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MiniStatCard(
                            key: const ValueKey("home-notes"),
                            number: "06",
                            title: "Notes",
                            value: "${data.notesCount} entries",
                            onTap: () => context.go(AppRoutes.notes),
                          ),
                        ),
                      ],
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: "Design check",
                        variant: AppButtonVariant.ghost,
                        showArrow: false,
                        onPressed: () => context.push(AppRoutes.designCheck),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
