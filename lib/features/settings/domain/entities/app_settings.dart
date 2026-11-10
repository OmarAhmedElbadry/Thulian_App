import "package:flutter/foundation.dart";

/// User preferences that are not the theme (the theme has its own cubit).
@immutable
class AppSettings {
  const AppSettings({
    this.dailyReminder = true,
    this.roomInvitations = true,
    this.weeklyDigest = false,
    this.sound = true,
    this.reduceMotion = false,
  });

  final bool dailyReminder;
  final bool roomInvitations;
  final bool weeklyDigest;
  final bool sound;

  /// Forces the app's "reduce motion" behaviour even when the OS has not
  /// requested it.
  final bool reduceMotion;

  AppSettings copyWith({
    bool? dailyReminder,
    bool? roomInvitations,
    bool? weeklyDigest,
    bool? sound,
    bool? reduceMotion,
  }) {
    return AppSettings(
      dailyReminder: dailyReminder ?? this.dailyReminder,
      roomInvitations: roomInvitations ?? this.roomInvitations,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      sound: sound ?? this.sound,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}
