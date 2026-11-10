import "package:flutter/material.dart";

import "../../../../core/theme/tokens/app_sizes.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/chip_filter.dart";
import "../../../../core/widgets/display_title.dart";
import "../../../../core/widgets/hairline_divider.dart";
import "../../../../core/widgets/record_header.dart";
import "../../../../core/widgets/reveal.dart";
import "../../../../core/widgets/section_header.dart";
import "../../data/habits_mock_data.dart";
import "../../domain/entities/habit_entry.dart";
import "../widgets/habit_row.dart";
import "../widgets/habit_stats_row.dart";
import "../widgets/history_grid.dart";
import "../widgets/week_day_strip.dart";

/// The habit register page (P. 02 / 12). Shows a week strip, category filters,
/// expandable habit rows with 7-day dots, a history grid for the first habit,
/// and aggregate stats. All mock data; Phase 4 introduces the cubit.
class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  HabitCategory? _selectedCategory;
  List<HabitEntry> get _allHabits => HabitsMockData.habits;

  List<HabitEntry> get _filteredHabits {
    if (_selectedCategory == null) return _allHabits;
    return _allHabits.where((h) => h.category == _selectedCategory).toList();
  }

  int _countForCategory(HabitCategory? category) {
    if (category == null) return _allHabits.length;
    return _allHabits.where((h) => h.category == category).length;
  }

  /// Week start (Monday) for the current mock week.
  DateTime get _weekStart {
    // Mock: Tuesday Nov 3 2026 → Monday Nov 2 2026
    return DateTime(2026, 11, 2);
  }

  @override
  Widget build(BuildContext context) {
    final habits = _filteredHabits;

    return Column(
      children: [
        const RecordHeader(
          label: "HABIT REGISTER · Nº 0308",
          page: "P. 02 / 12",
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                0,
                AppSpacing.pageMargin,
                AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.maxContentWidth,
                ),
                child: RevealGroup(
                  children: [
                    // ── Title row ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(child: DisplayTitle("Habits")),
                        AppButton(
                          label: "+ New entry",
                          variant: AppButtonVariant.primary,
                          showArrow: false,
                          onPressed: () {
                            // Phase 2.4b: navigate to create habit
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // ── Week strip ──
                    WeekDayStrip(
                      weekStartDate: _weekStart,
                      todayIndex: HabitsMockData.todayWeekdayIndex,
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // ── Category filters ──
                    _buildFilters(),
                    const SizedBox(height: AppSpacing.l),

                    // ── Section header ──
                    SectionHeader(
                      number: "01",
                      title: "Register",
                      trailing: "WK ${HabitsMockData.weekNumber} · MON–SUN",
                      strong: true,
                    ),

                    // ── First habit (expanded with history + stats) ──
                    if (habits.isNotEmpty) ...[
                      HabitRow(index: 1, habit: habits[0]),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 32,
                          bottom: AppSpacing.l,
                        ),
                        child: HistoryGrid(grid: habits[0].historyGrid),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      HabitStatsRow(
                        bestStreak: habits[0].bestStreak,
                        totalCompletions: habits[0].totalCompletions,
                        completionRate: habits[0].completionRate,
                        onEdit: () {},
                      ),
                      const SizedBox(height: AppSpacing.l),
                      const HairlineDivider(strong: true),
                    ],

                    // ── Remaining habits ──
                    for (var i = 1; i < habits.length; i++)
                      HabitRow(index: i + 1, habit: habits[i]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final categories = [
      (null, "All · ${_countForCategory(null)}"),
      (HabitCategory.mind, "Mind · ${_countForCategory(HabitCategory.mind)}"),
      (HabitCategory.body, "Body · ${_countForCategory(HabitCategory.body)}"),
      (HabitCategory.work, "Work · ${_countForCategory(HabitCategory.work)}"),
    ];

    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (final (category, label) in categories)
          ChipFilter(
            label: label,
            selected: _selectedCategory == category,
            onTap: () => setState(() => _selectedCategory = category),
          ),
      ],
    );
  }
}
