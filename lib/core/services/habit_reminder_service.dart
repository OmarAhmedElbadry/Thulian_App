import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "package:flutter_timezone/flutter_timezone.dart";
import "package:timezone/data/latest.dart" as tz_data;
import "package:timezone/timezone.dart" as tz;

import "../../features/habits/domain/entities/habit_entry.dart";
import "../../features/habits/domain/repositories/habits_repository.dart";
import "key_value_store.dart";

/// Schedules repeating device-local reminders for the user's active habits.
class HabitReminderService {
  HabitReminderService(this._habits, this._store);

  static const enabledKey = "settings_daily_reminder";
  static const _channelId = "habit_reminders";
  static const _channelName = "Habit reminders";

  final HabitsRepository _habits;
  final KeyValueStore _store;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  Future<void> _syncQueue = Future<void>.value();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final localZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localZone.identifier));
    } catch (_) {
      // Keep timezone's UTC fallback if the OS doesn't provide an IANA zone.
    }
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings("ic_habit_reminder"),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    try {
      final android = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? true;
      }
      final ios = _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncFromRepository() {
    final next = _syncQueue.then((_) => _sync());
    _syncQueue = next.catchError((Object _) {});
    return next;
  }

  Future<void> _sync() async {
    await initialize();
    final enabled =
        _store.read<bool>(enabledKey) ??
        _store.read<bool>("notifications_enabled") ??
        true;
    await _notifications.cancelAll();
    if (!enabled) return;

    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null && await android.areNotificationsEnabled() == false) {
      return;
    }

    final habits = await _habits.watchHabits().first;
    for (final habit in habits) {
      await _scheduleHabit(habit);
    }
  }

  Future<void> _scheduleHabit(HabitEntry habit) async {
    final hour = habit.reminderMinutes ~/ 60;
    final minute = habit.reminderMinutes % 60;
    if (habit.frequency == HabitFrequency.daily) {
      await _schedule(
        id: _id(habit.id),
        habit: habit,
        at: _nextDaily(hour, minute),
        recurrence: DateTimeComponents.time,
      );
      return;
    }
    for (final weekday in habit.weeklyDays.toSet()) {
      await _schedule(
        id: _id("${habit.id}:$weekday"),
        habit: habit,
        at: _nextWeekly(weekday, hour, minute),
        recurrence: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> _schedule({
    required int id,
    required HabitEntry habit,
    required tz.TZDateTime at,
    required DateTimeComponents recurrence,
  }) => _notifications.zonedSchedule(
    id,
    "A moment for ${habit.title}",
    "Your habit is ready when you are.",
    at,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: "Gentle reminders for your scheduled habits.",
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: recurrence,
    payload: habit.id,
  );

  tz.TZDateTime _nextDaily(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }

  tz.TZDateTime _nextWeekly(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    final daysAhead = (weekday - now.weekday + 7) % 7;
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysAhead,
      hour,
      minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 7));
    return next;
  }

  int _id(String value) {
    var hash = 0;
    for (final rune in value.runes) {
      hash = (hash * 31 + rune) & 0x7fffffff;
    }
    return hash;
  }
}
