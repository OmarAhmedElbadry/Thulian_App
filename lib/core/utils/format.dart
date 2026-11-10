/// Small, locale-free formatting helpers shared by features.
library;

String two(int value) => value.toString().padLeft(2, "0");

/// 1062 -> "17:42"
String formatMinutesSeconds(int totalSeconds) {
  final s = totalSeconds < 0 ? 0 : totalSeconds;
  return "${two(s ~/ 60)}:${two(s % 60)}";
}

/// 9668 -> "02:41:08"
String formatHoursMinutesSeconds(int totalSeconds) {
  final s = totalSeconds < 0 ? 0 : totalSeconds;
  return "${two(s ~/ 3600)}:${two((s % 3600) ~/ 60)}:${two(s % 60)}";
}

/// Minutes since midnight -> "21:30"
String formatClockMinutes(int minutesSinceMidnight) {
  final m = minutesSinceMidnight % (24 * 60);
  return "${two(m ~/ 60)}:${two(m % 60)}";
}
