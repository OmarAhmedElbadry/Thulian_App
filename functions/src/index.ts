import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

initializeApp();

const db = getFirestore();
const weekdays = [1, 2, 3, 4, 5, 6, 7];

type CalendarDate = { year: number; month: number; day: number };

export const refreshHabitStats = onDocumentWritten(
  "users/{userId}/habits/{habitId}/completions/{dateKey}",
  async (event) => {
    const { userId, habitId } = event.params;
    const habitRef = db.doc(`users/${userId}/habits/${habitId}`);
    const habitSnapshot = await habitRef.get();
    if (!habitSnapshot.exists) return;

    const habit = habitSnapshot.data()!;
    const completionSnapshot = await habitRef.collection("completions").get();
    const completionKeys = completionSnapshot.docs
      .map((document) => document.id)
      .sort();
    const completed = new Set(completionKeys);

    const eventRecord = event.data?.after.exists
      ? event.data.after.data()
      : event.data?.before.data();
    const latestRecord = completionSnapshot.docs.at(-1)?.data();
    const offset =
      eventRecord?.timezoneOffsetMinutes ??
      latestRecord?.timezoneOffsetMinutes ??
      0;
    const today = localToday(offset);
    const todayKey = toKey(today);
    const scheduledWeekdays =
      habit.frequency === "weekly"
        ? (habit.weeklyDays as number[])
        : weekdays;

    const totalCompletions = completionKeys.length;
    const streakDays = currentStreak(
      today,
      todayKey,
      completed,
      scheduledWeekdays,
    );
    const bestStreak = longestStreak(completionKeys, scheduledWeekdays);
    const { completionRate } = rateForLast28Days(
      today,
      completed,
      scheduledWeekdays,
    );

    await habitRef.update({
      "stats.streakDays": streakDays,
      "stats.bestStreak": bestStreak,
      "stats.totalCompletions": totalCompletions,
      "stats.completionRate": completionRate,
      statsUpdatedAt: FieldValue.serverTimestamp(),
    });
  },
);

function localToday(offsetMinutes: number): CalendarDate {
  const shifted = new Date(Date.now() + offsetMinutes * 60_000);
  return {
    year: shifted.getUTCFullYear(),
    month: shifted.getUTCMonth() + 1,
    day: shifted.getUTCDate(),
  };
}

function fromKey(key: string): CalendarDate | undefined {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(key);
  if (!match) return undefined;
  return { year: Number(match[1]), month: Number(match[2]), day: Number(match[3]) };
}

function toKey(date: CalendarDate): string {
  return `${date.year.toString().padStart(4, "0")}-${date.month
    .toString()
    .padStart(2, "0")}-${date.day.toString().padStart(2, "0")}`;
}

function addDays(date: CalendarDate, amount: number): CalendarDate {
  const value = new Date(Date.UTC(date.year, date.month - 1, date.day + amount));
  return {
    year: value.getUTCFullYear(),
    month: value.getUTCMonth() + 1,
    day: value.getUTCDate(),
  };
}

function weekday(date: CalendarDate): number {
  const value = new Date(Date.UTC(date.year, date.month - 1, date.day)).getUTCDay();
  return value === 0 ? 7 : value;
}

function previousScheduledDate(
  date: CalendarDate,
  scheduledWeekdays: number[],
): CalendarDate {
  let cursor = addDays(date, -1);
  while (!scheduledWeekdays.includes(weekday(cursor))) {
    cursor = addDays(cursor, -1);
  }
  return cursor;
}

function nextScheduledDate(
  date: CalendarDate,
  scheduledWeekdays: number[],
): CalendarDate {
  let cursor = addDays(date, 1);
  while (!scheduledWeekdays.includes(weekday(cursor))) {
    cursor = addDays(cursor, 1);
  }
  return cursor;
}

function currentStreak(
  today: CalendarDate,
  todayKey: string,
  completed: Set<string>,
  scheduledWeekdays: number[],
): number {
  let cursor = today;
  if (!scheduledWeekdays.includes(weekday(cursor))) {
    cursor = previousScheduledDate(addDays(cursor, 1), scheduledWeekdays);
  } else if (!completed.has(todayKey)) {
    cursor = previousScheduledDate(cursor, scheduledWeekdays);
  }

  let streak = 0;
  while (completed.has(toKey(cursor))) {
    streak++;
    cursor = previousScheduledDate(cursor, scheduledWeekdays);
  }
  return streak;
}

function longestStreak(keys: string[], scheduledWeekdays: number[]): number {
  let current = 0;
  let best = 0;
  let previous: CalendarDate | undefined;

  for (const key of keys) {
    const date = fromKey(key);
    if (!date || !scheduledWeekdays.includes(weekday(date))) continue;
    if (previous && toKey(nextScheduledDate(previous, scheduledWeekdays)) === key) {
      current++;
    } else {
      current = 1;
    }
    previous = date;
    best = Math.max(best, current);
  }
  return best;
}

function rateForLast28Days(
  today: CalendarDate,
  completed: Set<string>,
  scheduledWeekdays: number[],
): { completionRate: number } {
  let expected = 0;
  let done = 0;
  for (let ago = 0; ago < 28; ago++) {
    const date = addDays(today, -ago);
    if (!scheduledWeekdays.includes(weekday(date))) continue;
    expected++;
    if (completed.has(toKey(date))) done++;
  }
  return { completionRate: expected === 0 ? 0 : Math.round((done / expected) * 100) };
}
