import "dart:async";

import "package:flutter/widgets.dart";
import "package:firebase_core/firebase_core.dart";

import "app/app.dart";
import "core/di/injection.dart";
import "core/services/habit_reminder_service.dart";
import "firebase_options.dart";

/// App entry sequence. Firebase / Crashlytics initialisation joins here in Phase 3.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  final reminders = sl<HabitReminderService>();
  await reminders.initialize();
  unawaited(reminders.syncFromRepository().catchError((Object _) {}));
  runApp(const ThulianApp());
}
