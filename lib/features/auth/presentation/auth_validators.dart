/// Local-only validation used by the auth screens until Firebase lands in
/// Phase 3. Kept presentation-local because the rules are UX copy, not domain
/// policy.
abstract final class AuthValidators {
  static final RegExp _email = RegExp(r"^[\w.+-]+@[\w-]+(\.[\w-]+)+$");

  static String? name(String value) {
    final name = value.trim();
    if (name.isEmpty) return "Enter your name";
    if (name.length < 2) return "Name is too short";
    return null;
  }

  static String? email(String value) {
    final email = value.trim();
    if (email.isEmpty) return "Enter your email";
    if (!_email.hasMatch(email)) return "Enter a valid email";
    return null;
  }

  /// Used when signing in: any non-empty password is accepted locally.
  static String? password(String value) {
    if (value.isEmpty) return "Enter your password";
    return null;
  }

  /// Used when creating an account.
  static String? newPassword(String value) {
    if (value.isEmpty) return "Choose a password";
    if (value.length < 8) return "Use at least 8 characters";
    return null;
  }

  /// Returns 0 (empty) or 1–4. Three filled bars reads as "GOOD" on the
  /// strength meter, matching the mockup.
  static int passwordStrength(String value) {
    if (value.isEmpty) return 0;
    var score = 0;
    if (value.length >= 8) score++;
    if (value.length >= 12) score++;
    if (RegExp(r"[A-Z]").hasMatch(value) && RegExp(r"[a-z]").hasMatch(value)) {
      score++;
    }
    if (RegExp(r"\d").hasMatch(value)) score++;
    if (RegExp(r"[^\w\s]").hasMatch(value)) score++;
    return score.clamp(1, 4);
  }

  static String strengthLabel(int level) {
    return switch (level) {
      0 => "TOO SHORT",
      1 => "WEAK",
      2 => "FAIR",
      3 => "GOOD",
      _ => "STRONG",
    };
  }
}
