import "package:flutter/foundation.dart";

@immutable
class Stamp {
  const Stamp({required this.value, required this.label, this.unlocked = true});

  final String value;
  final String label;
  final bool unlocked;
}

@immutable
class FriendStat {
  const FriendStat({required this.name, required this.focusMinutes});

  final String name;
  final int focusMinutes;
}

/// Everything the profile page needs (Phase 2 mock entity). Phase 5 builds it
/// from server-computed XP, streaks and achievements.
@immutable
class ProfileSnapshot {
  const ProfileSnapshot({
    required this.name,
    required this.handle,
    required this.email,
    required this.level,
    required this.xp,
    required this.xpForNext,
    required this.streakDays,
    required this.habitsFiled,
    required this.studyHours,
    required this.weekActivity,
    required this.weekHighlightIndex,
    required this.stamps,
    required this.stampsTotal,
    required this.friends,
  });

  final String name;
  final String handle;
  final String email;
  final int level;
  final int xp;
  final int xpForNext;
  final int streakDays;
  final int habitsFiled;
  final int studyHours;

  /// Seven values, 0-100, Monday first.
  final List<int> weekActivity;
  final int weekHighlightIndex;
  final List<Stamp> stamps;
  final int stampsTotal;
  final List<FriendStat> friends;

  double get levelProgress {
    if (xpForNext == 0) return 0.0;
    return (xp / xpForNext).clamp(0.0, 1.0).toDouble();
  }

  String get initial => name.isEmpty ? "?" : name.substring(0, 1).toUpperCase();

  int get unlockedStamps => stamps.where((s) => s.unlocked).length;
}
