import "package:flutter/widgets.dart";
import "package:firebase_core/firebase_core.dart";

import "app/app.dart";
import "core/di/injection.dart";
import "firebase_options.dart";

/// App entry sequence. Firebase / Crashlytics initialisation joins here in Phase 3.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  runApp(const ThulianApp());
}
