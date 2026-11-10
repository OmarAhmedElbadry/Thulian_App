"""
Phase 2 (remaining screens) - patches for files you already have.

Run from the Flutter project root AFTER copying lib/ and test/ from this
package over your project:

    python apply_phase2_patches.py

Each patch is an exact string replacement, keeps the file's own line endings
(LF or CRLF), asserts that every anchor matches exactly once, and is skipped
if the file was already patched. Nothing is written if an anchor is missing.
"""
from pathlib import Path


def patch(path, marker, edits):
    p = Path(path)
    if not p.exists():
        print(f"MISSING: {path}")
        return False
    raw = p.read_bytes().decode("utf-8")
    newline = "\r\n" if "\r\n" in raw else "\n"
    text = raw.replace("\r\n", "\n")

    if marker in text:
        print(f"skip (already patched): {path}")
        return True

    for old, new in edits:
        count = text.count(old)
        if count != 1:
            print(f"FAILED: {path}: anchor found {count}x (expected 1):\n  {old.strip()[:80]!r}")
            return False
        text = text.replace(old, new)

    p.write_bytes(text.replace("\n", newline).encode("utf-8"))
    print(f"patched: {path}")
    return True


ok = True

# 1 - routes ----------------------------------------------------------------
ok &= patch("lib/core/router/app_routes.dart", "habitNew", [
    ('  static const authRecover = "/auth/recover";',
     """  static const authRecover = "/auth/recover";

  static const habitNew = "/habits/new";
  static const noteNew = "/notes/new";
  static const settings = "/profile/settings";

  static const roomSession = "/rooms/:id/session";
  static const noteEditor = "/notes/:id";

  static String roomSessionPath(String id) => "/rooms/$id/session";
  static String noteEditorPath(String id) => "/notes/$id";"""),
])

# 2 - router ----------------------------------------------------------------
ok &= patch("lib/core/router/app_router.dart", "CreateHabitPage", [
    ('import "../../features/habits/presentation/pages/habits_page.dart";',
     'import "../../features/habits/presentation/pages/create_habit_page.dart";\nimport "../../features/habits/presentation/pages/habits_page.dart";'),
    ('import "../../features/notes/presentation/pages/notes_page.dart";',
     'import "../../features/notes/presentation/pages/note_editor_page.dart";\nimport "../../features/notes/presentation/pages/notes_page.dart";'),
    ('import "../../features/profile/presentation/pages/profile_page.dart";',
     'import "../../features/profile/presentation/pages/profile_page.dart";\nimport "../../features/settings/presentation/pages/settings_page.dart";'),
    ('import "../../features/study_rooms/presentation/pages/rooms_page.dart";',
     'import "../../features/study_rooms/presentation/pages/rooms_page.dart";\nimport "../../features/study_rooms/presentation/pages/session_page.dart";'),
    ('      StatefulShellRoute(\n',
     """      GoRoute(
        path: AppRoutes.habitNew,
        pageBuilder: (context, state) => JournalPage<void>(
          key: state.pageKey,
          child: const CreateHabitPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.roomSession,
        pageBuilder: (context, state) => JournalPage<void>(
          key: state.pageKey,
          child: SessionPage(roomId: state.pathParameters["id"] ?? ""),
        ),
      ),
      GoRoute(
        path: AppRoutes.noteEditor,
        pageBuilder: (context, state) => JournalPage<void>(
          key: state.pageKey,
          child: NoteEditorPage(noteId: state.pathParameters["id"] ?? "new"),
        ),
      ),
      StatefulShellRoute(\n"""),
    ("""              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),""",
     """              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: "settings",
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),"""),
])

# 3 - DI --------------------------------------------------------------------
ok &= patch("lib/core/di/injection.dart", "SettingsCubit", [
    ('import "../../features/onboarding/presentation/cubit/onboarding_cubit.dart";',
     'import "../../features/onboarding/presentation/cubit/onboarding_cubit.dart";\nimport "../../features/settings/presentation/cubit/settings_cubit.dart";'),
    ('    ..registerSingleton<ThemeCubit>(ThemeCubit(sl<KeyValueStore>()))\n',
     '    ..registerSingleton<ThemeCubit>(ThemeCubit(sl<KeyValueStore>()))\n    ..registerSingleton<SettingsCubit>(SettingsCubit(sl<KeyValueStore>()))\n'),
])

# 4 - app (reduce-motion override) ------------------------------------------
ok &= patch("lib/app/app.dart", "SettingsCubit", [
    ('import "../core/theme/tokens/app_motion.dart";',
     'import "../core/theme/tokens/app_motion.dart";\nimport "../features/settings/domain/entities/app_settings.dart";\nimport "../features/settings/presentation/cubit/settings_cubit.dart";'),
    ('            routerConfig: sl<GoRouter>(),',
     """            builder: (context, child) {
              return BlocBuilder<SettingsCubit, AppSettings>(
                bloc: sl<SettingsCubit>(),
                buildWhen: (previous, next) =>
                    previous.reduceMotion != next.reduceMotion,
                builder: (context, settings) {
                  final media = MediaQuery.of(context);
                  return MediaQuery(
                    data: media.copyWith(
                      disableAnimations:
                          media.disableAnimations || settings.reduceMotion,
                    ),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
            },
            routerConfig: sl<GoRouter>(),"""),
])

# 5 - AppTextField: optional text style ---------------------------------------
ok &= patch("lib/core/widgets/app_text_field.dart", "textStyle", [
    ('    this.maxLines = 1,\n  });',
     '    this.maxLines = 1,\n    this.textStyle,\n  });'),
    ('  final int maxLines;\n',
     '  final int maxLines;\n\n  /// Overrides the default mono input style (e.g. a serif title field).\n  final TextStyle? textStyle;\n'),
    ('    final style = t.meta.copyWith(fontSize: 14, letterSpacing: 0.2);',
     '    final style =\n        widget.textStyle ?? t.meta.copyWith(fontSize: 14, letterSpacing: 0.2);'),
])

# 6 - HabitEntry: reminder + target -------------------------------------------
ok &= patch("lib/features/habits/domain/entities/habit_entry.dart", "reminderMinutes", [
    ('    required this.completionRate,\n  });',
     '    required this.completionRate,\n    this.reminderMinutes,\n    this.targetMinutes,\n  });'),
    ('  final int completionRate;\n',
     '  final int completionRate;\n\n  /// Reminder time as minutes since midnight, when one is set.\n  final int? reminderMinutes;\n\n  /// Optional daily target in minutes.\n  final int? targetMinutes;\n'),
    ('      completionRate: completionRate,\n    );',
     '      completionRate: completionRate,\n      reminderMinutes: reminderMinutes,\n      targetMinutes: targetMinutes,\n    );'),
])

# 7 - Habits page: shared store + "+ New entry" -------------------------------
ok &= patch("lib/features/habits/presentation/pages/habits_page.dart", "habits_mock_store", [
    ('import "package:flutter/material.dart";\n',
     'import "package:flutter/material.dart";\nimport "package:go_router/go_router.dart";\n'),
    ('import "../../../../core/theme/theme_extensions.dart";',
     'import "../../../../core/router/app_routes.dart";\nimport "../../../../core/theme/theme_extensions.dart";'),
    ('import "../../data/habits_mock_data.dart";',
     'import "../../data/habits_mock_data.dart";\nimport "../../data/habits_mock_store.dart";'),
    ('  List<HabitEntry> get _allHabits => HabitsMockData.habits;',
     '  List<HabitEntry> get _allHabits => HabitsMockStore.instance.habits.value;'),
    ('  final int _expandedIndex = 0; // First habit expanded by default\n',
     """  final int _expandedIndex = 0; // First habit expanded by default

  @override
  void initState() {
    super.initState();
    HabitsMockStore.instance.habits.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    HabitsMockStore.instance.habits.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }
"""),
    ("""                          onPressed: () {
                            // Phase 2.4b: navigate to create habit
                          },""",
     """                          onPressed: () => context.push(AppRoutes.habitNew),"""),
])

print()
print("All patches applied." if ok else "Some patches FAILED - nothing was changed in those files; see messages above.")
