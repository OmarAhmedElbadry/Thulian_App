# Thulian - Phase 1 / Task 1.1 setup

Foundation: project structure, design tokens, typography, theme (light/dark, persisted),
DI, routing with bottom-nav shell, and the first shared widgets.

## 1. Create the Flutter project (once)

```bash
flutter create --org com.thulian --project-name thulian --platforms android .
```

`com.thulian` is a placeholder organisation id (decision D1 is still open). Changing the
Android package later is possible but annoying, so tell me if you want a different one first.

## 2. Copy this package into the project

Copy `lib/`, `assets/`, `test/` over the generated ones (overwrite `lib/main.dart`),
then **delete** the generated `test/widget_test.dart` (it references `MyApp`).

## 3. pubspec

Merge `pubspec_additions.yaml` into the `flutter:` section, then add packages
(this resolves versions against your installed SDK):

```bash
flutter pub add flutter_bloc get_it go_router hive_ce hive_ce_flutter
```

## 4. Verify

```bash
dart format .
flutter analyze
flutter test
flutter run
```

Expected: 4 theme-cubit tests + 1 colour test pass. In a debug build, Home has a
**DESIGN CHECK** button showing tokens, type, buttons and a Light/Dark/System toggle
(the choice survives an app restart).

## What is NOT here yet

Shared inputs, dialogs, bottom sheets, loading/error/empty states, and feature screens
(next tasks). Auth guard and Firebase arrive in Phase 3.
