import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:go_router/go_router.dart";

import "../../../../core/di/injection.dart";
import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_sizes.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/hairline_divider.dart";
import "../../../../core/widgets/record_header.dart";
import "../../../../core/widgets/reveal.dart";
import "../../../../core/widgets/section_header.dart";
import "../../../auth/domain/repositories/auth_repository.dart";
import "../../data/dashboard_mock_data.dart";
import "../../domain/entities/dashboard_snapshot.dart";
import "../../../habits/domain/entities/habit_entry.dart";
import "../../../habits/domain/repositories/habits_repository.dart";
import "../../../habits/domain/usecases/set_habit_completion.dart";
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
  late final bool _useRepository;
  List<HabitEntry> _habitEntries = const [];
  final Map<String, Set<String>> _completionKeys = {};
  final Map<String, StreamSubscription<List<DateTime>>> _completionStreams = {};
  StreamSubscription<List<HabitEntry>>? _habitsStream;

  @override
  void initState() {
    super.initState();
    _useRepository = sl.isRegistered<HabitsRepository>();
    _habits = _useRepository ? const [] : [...widget.data.habits];
    if (_useRepository) _listenToHabits();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_useRepository && oldWidget.data != widget.data) {
      _habits = [...widget.data.habits];
    }
  }

  @override
  void dispose() {
    final habitsStream = _habitsStream;
    if (habitsStream != null) unawaited(habitsStream.cancel());
    for (final subscription in _completionStreams.values) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }

  void _listenToHabits() {
    final repository = sl<HabitsRepository>();
    _habitsStream = repository.watchHabits().listen(
      (habits) {
        _habitEntries = habits;
        _syncCompletionStreams(repository, habits);
        if (!mounted) return;
        setState(_refreshBriefs);
      },
      onError: (Object error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not load habits: $error")),
        );
      },
    );
  }

  void _syncCompletionStreams(
    HabitsRepository repository,
    List<HabitEntry> habits,
  ) {
    final ids = habits.map((habit) => habit.id).toSet();
    for (final id in _completionStreams.keys.toList()) {
      if (ids.contains(id)) continue;
      final subscription = _completionStreams.remove(id);
      if (subscription != null) unawaited(subscription.cancel());
      _completionKeys.remove(id);
    }
    for (final habit in habits) {
      if (_completionStreams.containsKey(habit.id)) continue;
      _completionStreams[habit.id] = repository
          .watchCompletions(habit.id)
          .listen((dates) {
            _completionKeys[habit.id] = dates.map(_dateKey).toSet();
            if (mounted) setState(_refreshBriefs);
          }, onError: (Object _) {});
    }
  }

  void _refreshBriefs() {
    final today = _dateKey(widget.now ?? DateTime.now());
    _habits = [
      for (final habit in _habitEntries)
        HabitBrief(
          id: habit.id,
          title: habit.title,
          streakDays: 0,
          done: _completionKeys[habit.id]?.contains(today) ?? false,
        ),
    ];
  }

  String _dateKey(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";

  void _toggleHabit(String id) {
    final index = _habits.indexWhere((habit) => habit.id == id);
    if (index == -1) return;
    if (!_habits[index].done) HapticFeedback.selectionClick();
    if (_useRepository) {
      unawaited(_setPersistedHabit(id, completed: !_habits[index].done));
      return;
    }
    setState(() {
      _habits[index] = _habits[index].copyWith(done: !_habits[index].done);
    });
  }

  Future<void> _setPersistedHabit(String id, {required bool completed}) async {
    try {
      await sl<SetHabitCompletion>()(
        habitId: id,
        date: widget.now ?? DateTime.now(),
        completed: completed,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not save completion: $error")),
      );
    }
  }

  List<int> _liveWeekActivity() {
    final now = widget.now ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    if (_habitEntries.isEmpty) return List<int>.filled(7, 0);
    return List<int>.generate(7, (index) {
      final day = _dateKey(monday.add(Duration(days: index)));
      final done = _habitEntries
          .where((habit) => _completionKeys[habit.id]?.contains(day) ?? false)
          .length;
      return (done * 100 / _habitEntries.length).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = widget.now ?? DateTime.now();
    final data = widget.data;
    final user = _useRepository ? sl<AuthRepository>().currentUser : null;
    final displayName = user?.displayName.trim().isNotEmpty == true
        ? user!.displayName
        : user?.email.split("@").first ?? data.displayName;
    final weekActivity = _useRepository
        ? _liveWeekActivity()
        : data.weekActivity;
    final weekDone = _useRepository
        ? weekActivity.where((activity) => activity > 0).length
        : data.weekDone;
    final weekHighlightIndex = _useRepository
        ? now.weekday - 1
        : data.weekHighlightIndex;
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
                                TextSpan(text: displayName),
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
                      focusMinutes: data.focusMinutes,
                      weekDone: weekDone,
                      weekTotal: data.weekTotal,
                      weekActivity: weekActivity,
                      weekHighlightIndex: weekHighlightIndex,
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
