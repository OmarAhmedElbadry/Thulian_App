/// Presentation-only date copy for notes.
library;

import "../../../core/utils/format.dart";

const _weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

String _hm(DateTime d) => "${two(d.hour)}:${two(d.minute)}";
String _dm(DateTime d) => "${two(d.day)}.${two(d.month)}";

/// "Today 09:12", "Mon 02.11" (within a week) or "02.11".
String noteListDate(DateTime date, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return "Today ${_hm(date)}";
  if (diff > 0 && diff < 7) {
    return "${_weekdays[date.weekday - 1]} ${_dm(date)}";
  }
  return _dm(date);
}

/// "Edited 02.11 \u00b7 21:14"
String editedLabel(DateTime date) => "Edited ${_dm(date)} \u00b7 ${_hm(date)}";

/// "Modified 03.11 \u00b7 09:12"
String modifiedLabel(DateTime date) =>
    "Modified ${_dm(date)} \u00b7 ${_hm(date)}";
