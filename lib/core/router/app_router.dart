import "dart:async";

import "package:flutter/foundation.dart";
import "package:go_router/go_router.dart";

import "../../app/app_shell.dart";
import "../../features/auth/domain/entities/auth_user.dart";
import "../../features/auth/domain/repositories/auth_repository.dart";
import "../../features/auth/presentation/pages/create_account_page.dart";
import "../../features/auth/presentation/pages/recovery_page.dart";
import "../../features/auth/presentation/pages/sign_in_page.dart";
import "../../features/dashboard/presentation/pages/home_page.dart";
import "../../features/habits/presentation/pages/habits_page.dart";
import "../../features/notes/presentation/pages/notes_page.dart";
import "../../features/notes/presentation/pages/note_editor_page.dart";
import "../../features/onboarding/presentation/pages/onboarding_page.dart";
import "../../features/profile/presentation/pages/profile_page.dart";
import "../../features/settings/presentation/pages/settings_page.dart";
import "../../features/study_rooms/presentation/pages/rooms_page.dart";
import "../../features/study_rooms/presentation/pages/session_page.dart";
import "../dev/design_check_page.dart";
import "../theme/page_transitions.dart";
import "../widgets/fade_indexed_stack.dart";
import "app_routes.dart";

GoRouter buildRouter({
  required bool onboarded,
  required AuthRepository authRepository,
}) {
  final authRefresh = _AuthRefreshListenable(authRepository.authStateChanges);
  return GoRouter(
    initialLocation: onboarded ? AppRoutes.home : AppRoutes.onboarding,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final signedIn = authRepository.currentUser != null;
      final location = state.matchedLocation;
      final atOnboarding = location == AppRoutes.onboarding;
      final atAuth =
          location == AppRoutes.authSignIn ||
          location == AppRoutes.authCreateAccount ||
          location == AppRoutes.authRecover;

      if (!signedIn && !atOnboarding && !atAuth) return AppRoutes.authSignIn;
      if (signedIn && (atOnboarding || atAuth)) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.authSignIn,
        pageBuilder: (context, state) =>
            JournalPage<void>(key: state.pageKey, child: const SignInPage()),
      ),
      GoRoute(
        path: AppRoutes.authCreateAccount,
        pageBuilder: (context, state) => JournalPage<void>(
          key: state.pageKey,
          child: const CreateAccountPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.authRecover,
        pageBuilder: (context, state) =>
            JournalPage<void>(key: state.pageKey, child: const RecoveryPage()),
      ),
      GoRoute(
        path: AppRoutes.noteNew,
        builder: (context, state) => const NoteEditorPage(noteId: "new"),
      ),
      GoRoute(
        path: "/notes/:noteId",
        builder: (context, state) =>
            NoteEditorPage(noteId: state.pathParameters["noteId"]!),
      ),
      GoRoute(
        path: AppRoutes.roomSessionPath(":roomId"),
        builder: (context, state) =>
            SessionPage(roomId: state.pathParameters["roomId"]!),
      ),
      StatefulShellRoute(
        navigatorContainerBuilder: (context, shell, children) =>
            FadeIndexedStack(index: shell.currentIndex, children: children),
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.habits,
                builder: (context, state) => const HabitsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.rooms,
                builder: (context, state) => const RoomsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.notes,
                builder: (context, state) => const NotesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: "settings",
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.designCheck,
        builder: (context, state) => const DesignCheckPage(),
      ),
    ],
  );
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Stream<AuthUser?> authStateChanges) {
    _subscription = authStateChanges.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthUser?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
