import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:cloud_firestore/cloud_firestore.dart";

import "../../../../core/di/injection.dart";
import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/tokens/app_sizes.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/chip_filter.dart";
import "../../../../core/widgets/display_title.dart";
import "../../../../core/widgets/empty_state.dart";
import "../../../../core/widgets/error_state.dart";
import "../../../../core/widgets/hairline_divider.dart";
import "../../../../core/widgets/record_header.dart";
import "../../../../core/widgets/reveal.dart";
import "../../../../core/widgets/section_header.dart";
import "../../data/habits_mock_data.dart";
import "../../domain/entities/habit_entry.dart";
import "../../domain/repositories/habits_repository.dart";
import "../widgets/habit_row.dart";
import "../widgets/habit_stats_row.dart";
import "../widgets/history_grid.dart";
import "../widgets/week_day_strip.dart";

/// The habit register page (P. 02 / 12). Shows a week strip, category filters,
/// Expandable habit rows with 7-day dots, history and aggregate stats.
class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  HabitCategory? _selectedCategory;
  @override
  Widget build(BuildContext context) {
    if (!sl.isRegistered<HabitsRepository>()) {
      return _buildRegister(HabitsMockData.habits);
    }
    return StreamBuilder<List<HabitEntry>>(
      stream: sl<HabitsRepository>().watchHabits(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: ErrorState(
              title: "Could not load habits.",
              message: _errorMessage(snapshot.error),
              onRetry: () => setState(() {}),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildRegister(snapshot.data!);
      },
    );
  }

  String _errorMessage(Object? error) {
    if (error is FirebaseException) {
      return switch (error.code) {
        "permission-denied" =>
          "Firestore denied access. Deploy the latest firestore.rules and make sure this account's email is verified. (permission-denied)",
        "unauthenticated" =>
          "Your session has expired. Sign in again. (unauthenticated)",
        "unavailable" || "network-request-failed" =>
          "Firebase is unreachable. Check your internet connection and retry. (${error.code})",
        _ =>
          "Firebase error (${error.code}): ${error.message ?? 'Unknown error'}",
      };
    }
    return error?.toString() ?? "An unknown error occurred.";
  }

  Widget _buildRegister(List<HabitEntry> allHabits) {
    final habits = _selectedCategory == null
        ? allHabits
        : allHabits.where((h) => h.category == _selectedCategory).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final todayIndex = today.weekday - 1;

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
                          onPressed: () => context.push(AppRoutes.habitNew),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // ── Week strip ──
                    WeekDayStrip(
                      weekStartDate: weekStart,
                      todayIndex: todayIndex,
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // ── Category filters ──
                    _buildFilters(allHabits),
                    const SizedBox(height: AppSpacing.l),

                    // ── Section header ──
                    SectionHeader(
                      number: "01",
                      title: "Register",
                      trailing: "MON–SUN",
                      strong: true,
                    ),

                    // ── First habit (expanded with history + stats) ──
                    if (habits.isNotEmpty) ...[
                      _watchHabit(habits[0], today, (habit) {
                        void edit() {
                          context.push(
                            AppRoutes.habitEditPath(habit.id),
                            extra: habit,
                          );
                        }

                        return Column(
                          children: [
                            _habitRow(habit, 1, todayIndex, onEdit: edit),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 32,
                                bottom: AppSpacing.l,
                              ),
                              child: HistoryGrid(grid: habit.historyGrid),
                            ),
                            const SizedBox(height: AppSpacing.s),
                            HabitStatsRow(
                              bestStreak: habit.bestStreak,
                              totalCompletions: habit.totalCompletions,
                              completionRate: habit.completionRate,
                              onEdit: edit,
                            ),
                            const SizedBox(height: AppSpacing.l),
                            const HairlineDivider(strong: true),
                          ],
                        );
                      }),
                    ] else ...[
                      EmptyState(
                        title: "Your register is ready.",
                        message:
                            "File a habit to begin tracking your progress.",
                        actionLabel: "New habit",
                        onAction: () => context.push(AppRoutes.habitNew),
                      ),
                    ],
                    // ── Remaining habits ──
                    for (var i = 1; i < habits.length; i++)
                      _watchHabit(
                        habits[i],
                        today,
                        (habit) => _habitRow(
                          habit,
                          i + 1,
                          todayIndex,
                          onEdit: () => context.push(
                            AppRoutes.habitEditPath(habit.id),
                            extra: habit,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _watchHabit(
    HabitEntry habit,
    DateTime today,
    Widget Function(HabitEntry) builder,
  ) {
    if (!sl.isRegistered<HabitsRepository>()) return builder(habit);
    final repository = sl<HabitsRepository>();
    return StreamBuilder<List<DateTime>>(
      stream: repository.watchCompletions(habit.id),
      builder: (context, snapshot) {
        final displayed = snapshot.hasData
            ? _withCompletions(habit, snapshot.data!, today)
            : habit;
        return builder(displayed);
      },
    );
  }

  HabitEntry _withCompletions(
    HabitEntry habit,
    List<DateTime> completions,
    DateTime today,
  ) {
    final completedDays = completions.map(_dateKey).toSet();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final week = List<bool>.generate(
      7,
      (index) => completedDays.contains(
        _dateKey(weekStart.add(Duration(days: index))),
      ),
    );
    final start = today.subtract(const Duration(days: 27));
    final history = List<bool>.generate(
      28,
      (index) =>
          completedDays.contains(_dateKey(start.add(Duration(days: index)))),
    );
    return habit.copyWith(weekCompletions: week, historyGrid: history);
  }

  String _dateKey(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";

  Widget _habitRow(
    HabitEntry habit,
    int index,
    int todayIndex, {
    required VoidCallback onEdit,
  }) => HabitRow(
    index: index,
    habit: habit,
    onTap: onEdit,
    todayIndex: todayIndex,
    onToggleToday: sl.isRegistered<HabitsRepository>()
        ? () => _toggleToday(habit)
        : null,
  );

  Future<void> _toggleToday(HabitEntry habit) async {
    try {
      await sl<HabitsRepository>().toggleCompletion(habit.id, DateTime.now());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    }
  }

  Widget _buildFilters(List<HabitEntry> allHabits) {
    int count(HabitCategory? category) => category == null
        ? allHabits.length
        : allHabits.where((h) => h.category == category).length;
    final categories = [
      (null, "All · ${count(null)}"),
      (HabitCategory.mind, "Mind · ${count(HabitCategory.mind)}"),
      (HabitCategory.body, "Body · ${count(HabitCategory.body)}"),
      (HabitCategory.work, "Work · ${count(HabitCategory.work)}"),
      (HabitCategory.social, "Social · ${count(HabitCategory.social)}"),
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
