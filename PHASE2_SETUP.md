# Thulian - Phase 2 (remaining screens)

New screens: Create habit, Rooms, Focus session, Notes, Note editor, Profile & stats, Settings.

## Apply

1. Copy `lib/` and `test/` from this package over your project.
   This REPLACES the placeholder `rooms_page.dart`, `notes_page.dart`, `profile_page.dart`.
2. From the project root run: `python apply_phase2_patches.py`
   (patches routes, router, DI, app, AppTextField, HabitEntry, HabitsPage; safe to re-run).
3. `dart format .` then `flutter analyze` then `flutter test` then `flutter run`.

## Navigation map

- Habits: `+ NEW ENTRY` -> `/habits/new` (no nav bar). FILE HABIT adds it to the register.
- Rooms: join by code (try KX4821 / QH2501 / TC9004) or tap a room -> `/rooms/:id/session`.
  `+ CREATE` opens a sheet, then enters the new room (idle until you press START SESSION).
- Notes: tap a note -> `/notes/:id`; `+ NEW` -> `/notes/new`. Autosaves after 0.7 s.
- You: `SETTINGS ->` link at the bottom -> `/profile/settings` (bottom bar keeps "You").
- Settings: theme (persisted), toggles (persisted), REDUCE MOTION applies app-wide,
  Account row -> sign-out dialog -> sign-in page.

## Mock data (all temporary)

`habits_mock_store.dart`, `rooms_mock_store.dart`, `notes_mock_store.dart` are in-memory
stand-ins for the repositories of Phases 4, 7 and 8. State resets on app restart.
