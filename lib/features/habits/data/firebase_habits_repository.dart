import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import "../domain/entities/habit_draft.dart";
import "../domain/entities/habit_entry.dart";
import "../domain/repositories/habits_repository.dart";

class FirebaseHabitsRepository implements HabitsRepository {
  FirebaseHabitsRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _habits {
    final user = _auth.currentUser;
    if (user == null) throw StateError("Sign in to access your habits.");
    return _firestore.collection("users").doc(user.uid).collection("habits");
  }

  @override
  Stream<List<HabitEntry>> watchHabits() {
    try {
      return _habits.snapshots().map((snapshot) {
        final habits = snapshot.docs
            .where((doc) => doc.data()["archived"] != true)
            .map((doc) => _fromDocument(doc.id, doc.data()))
            .toList();
        habits.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        return habits;
      });
    } catch (error, stackTrace) {
      return Stream.error(error, stackTrace);
    }
  }

  @override
  Future<HabitEntry> createHabit(HabitDraft draft) async {
    final reference = _habits.doc();
    final data = _draftData(draft)
      ..addAll({
        "archived": false,
        "stats": const {
          "streakDays": 0,
          "bestStreak": 0,
          "totalCompletions": 0,
          "completionRate": 0,
        },
        "statsUpdatedAt": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    await reference.set(data);
    return _fromDocument(reference.id, {
      ...data,
      "createdAt": Timestamp.now(),
      "updatedAt": Timestamp.now(),
    });
  }

  @override
  Future<void> updateHabit(String id, HabitDraft draft) =>
      _habits.doc(id).update({
        ..._draftData(draft),
        "updatedAt": FieldValue.serverTimestamp(),
      });

  @override
  Future<void> archiveHabit(String id) => _habits.doc(id).update({
    "archived": true,
    "updatedAt": FieldValue.serverTimestamp(),
  });

  @override
  Stream<List<DateTime>> watchCompletions(String habitId) {
    try {
      return _habits.doc(habitId).collection("completions").snapshots().map((
        snapshot,
      ) {
        final dates =
            snapshot.docs
                .map((document) => DateTime.tryParse(document.id))
                .whereType<DateTime>()
                .map((date) => DateTime(date.year, date.month, date.day))
                .toList()
              ..sort();
        return dates;
      });
    } catch (error, stackTrace) {
      return Stream.error(error, stackTrace);
    }
  }

  @override
  Future<void> toggleCompletion(String habitId, DateTime date) async {
    final day = DateTime(date.year, date.month, date.day);
    final dateKey =
        "${day.year.toString().padLeft(4, '0')}-"
        "${day.month.toString().padLeft(2, '0')}-"
        "${day.day.toString().padLeft(2, '0')}";
    final completion = _habits
        .doc(habitId)
        .collection("completions")
        .doc(dateKey);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(completion);
      if (snapshot.exists) {
        transaction.delete(completion);
      } else {
        transaction.set(completion, {
          "dateKey": dateKey,
          "timezoneOffsetMinutes": DateTime.now().timeZoneOffset.inMinutes,
          "completedAt": FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Map<String, Object?> _draftData(HabitDraft draft) => {
    "title": draft.name.trim(),
    "category": draft.category.name,
    "frequency": draft.frequency.name,
    "weeklyDays": draft.frequency == HabitFrequency.weekly
        ? (draft.weeklyDays.toList()..sort())
        : <int>[],
    "reminderMinutes": draft.reminderMinutes,
    "targetMinutes": draft.targetMinutes,
  };

  HabitEntry _fromDocument(String id, Map<String, dynamic> data) {
    final category = HabitCategory.values.firstWhere(
      (value) => value.name == data["category"],
      orElse: () => HabitCategory.mind,
    );
    final frequency = HabitFrequency.values.firstWhere(
      (value) => value.name == data["frequency"],
      orElse: () => HabitFrequency.daily,
    );
    final stats = data["stats"] as Map<String, dynamic>? ?? const {};
    return HabitEntry(
      id: id,
      title: data["title"] as String? ?? "",
      category: category,
      frequency: frequency,
      weeklyDays: (data["weeklyDays"] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((day) => day.toInt())
          .toList(),
      weekCompletions: List<bool>.filled(7, false),
      historyGrid: List<bool>.filled(28, false),
      reminderMinutes: data["reminderMinutes"] as int? ?? 21 * 60 + 30,
      targetMinutes: data["targetMinutes"] as int? ?? 15,
      streakDays: stats["streakDays"] as int? ?? 0,
      bestStreak: stats["bestStreak"] as int? ?? 0,
      totalCompletions: stats["totalCompletions"] as int? ?? 0,
      completionRate: stats["completionRate"] as int? ?? 0,
    );
  }
}
