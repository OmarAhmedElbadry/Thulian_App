import "package:flutter/widgets.dart";

import "app/app.dart";
import "core/di/injection.dart";

/// App entry sequence. Firebase / Crashlytics initialisation joins here in Phase 3.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ThulianApp());
}
