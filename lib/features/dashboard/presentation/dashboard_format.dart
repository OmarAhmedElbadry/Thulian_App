/// Presentation-only formatting for the dashboard. Kept out of the entities so
/// the domain stays free of copy and locale decisions.
library;

const _weekdaysShort = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

String _two(int value) => value.toString().padLeft(2, "0");

/// Zero-padded two-digit number, e.g. 3 -> "03".
String twoDigits(int value) => _two(value);

/// "TUE · 03 / 11 / 2026"
String shortDateLabel(DateTime date) {
  return "${_weekdaysShort[date.weekday - 1]} \u00b7 "
      "${_two(date.day)} / ${_two(date.month)} / ${date.year}";
}

/// Day of the year, 1-based. 3 November 2026 -> 307.
int dayOfYear(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  return day.difference(DateTime.utc(date.year, 1, 1)).inDays + 1;
}

/// Four-digit record reference, e.g. 307 -> "0307".
String recordNumber(DateTime date) =>
    dayOfYear(date).toString().padLeft(4, "0");

/// ISO-8601 week number. 3 November 2026 -> 45.
int isoWeekNumber(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  final week = (dayOfYear(date) - day.weekday + 10) ~/ 7;
  if (week < 1) return _isoWeeksInYear(date.year - 1);
  if (week > _isoWeeksInYear(date.year)) return 1;
  return week;
}

int _isoWeeksInYear(int year) {
  final jan1 = DateTime.utc(year, 1, 1);
  final leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  if (jan1.weekday == DateTime.thursday) return 53;
  if (leap && jan1.weekday == DateTime.wednesday) return 53;
  return 52;
}

String greetingFor(DateTime time) {
  if (time.hour < 12) return "Good morning";
  if (time.hour < 18) return "Good afternoon";
  return "Good evening";
}

/// 402 -> "06:42"
String focusClock(int minutes) {
  final safe = minutes < 0 ? 0 : minutes;
  return "${_two(safe ~/ 60)}:${_two(safe % 60)}";
}

/// "02 of 03 habits filed"
String completionLabel(int completed, int total) {
  return "${_two(completed)} of ${_two(total)} habits filed";
}
