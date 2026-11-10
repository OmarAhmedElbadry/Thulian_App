/// Presentation-only copy for the habit pages.
library;

import "../domain/entities/habit_draft.dart";
import "../domain/entities/habit_entry.dart";

const _weekdaysShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const weekdaysLong = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];

/// "3x per week · Mon, Wed, Fri"
String scheduleCaption(HabitDraft draft) {
  if (draft.frequency == HabitFrequency.daily) return "Every day";
  if (draft.weeklyDays.isEmpty) return "Select at least one day";
  if (draft.weeklyDays.length == 7) return "Every day";
  final days = [...draft.weeklyDays]..sort();
  final names = days.map((d) => _weekdaysShort[d - 1]).join(", ");
  return "${days.length}\u00d7 per week \u00b7 $names";
}

/// "MIND · 3x/WK"
String previewMeta(HabitDraft draft) {
  final category = draft.category.name.toUpperCase();
  if (draft.frequency == HabitFrequency.daily) return "$category \u00b7 DAILY";
  return "$category \u00b7 ${draft.weeklyDays.length}\u00d7/WK";
}
