abstract final class AppRoutes {
  static const onboarding = "/onboarding";
  static const home = "/home";
  static const habits = "/habits";
  static const rooms = "/rooms";
  static const notes = "/notes";
  static const noteNew = "/notes/new";
  static String noteEditorPath(String noteId) => "/notes/$noteId";
  static const profile = "/profile";
  static const settings = "/profile/settings";
  static String roomSessionPath(String roomId) => "/rooms/$roomId/session";

  static const authSignIn = "/auth/sign-in";
  static const authCreateAccount = "/auth/create-account";
  static const authRecover = "/auth/recover";

  /// Debug-only design token and component preview.
  static const designCheck = "/dev/design";
}
