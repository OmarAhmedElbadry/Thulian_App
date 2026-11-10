import "../domain/entities/note.dart";

/// Mock notes shaped like the approved Notes mockups. Dates are generated
/// relative to [now] so "Today" and weekday labels always read naturally.
/// Removed when notes move to Firestore in Phase 7.
abstract final class NotesMockData {
  static List<Note> seed(DateTime now) {
    DateTime at(int daysAgo, int hour, int minute) =>
        DateTime(now.year, now.month, now.day - daysAgo, hour, minute);

    return [
      Note(
        id: "thesis-outline",
        title: "Thesis outline, ch. 3",
        body:
            "Argument, evidence, counter-case.\n\n"
            "Draft the framing paragraph first, then the three sources.",
        tags: const ["study"],
        pinned: true,
        updatedAt: at(1, 21, 14),
      ),
      Note(
        id: "reading-list",
        title: "Reading list",
        body: "Memory and the filing instinct.\nThe slow web.\nDeep work, re-read.",
        tags: const ["study"],
        pinned: true,
        updatedAt: at(4, 8, 2),
      ),
      Note(
        id: "lecture-07",
        title: "Lecture 07 \u2014 how memory consolidates",
        body:
            "Sleep does the filing. Spaced review beats a single long session; "
            "test yourself before re-reading.\n\n"
            "Three prompts for tomorrow:\n"
            "1. What is encoded, and where?\n"
            "2. Why does retrieval strengthen the trace?\n"
            "3. Draft the 90-second summary.",
        tags: const ["study", "memory"],
        pinned: false,
        updatedAt: at(0, 9, 12),
      ),
      Note(
        id: "why-mornings",
        title: "Why mornings work",
        body: "Fewer decisions, quieter inbox, the day still unspoken for.",
        tags: const ["ideas"],
        pinned: false,
        updatedAt: at(1, 7, 40),
      ),
      Note(
        id: "week-44",
        title: "Week 44 review",
        body: "Filed 5 of 7 days. Focus blocks held up; evenings slipped.",
        tags: const ["log"],
        pinned: false,
        updatedAt: at(2, 20, 5),
      ),
      Note(
        id: "gym-v2",
        title: "Gym plan v2",
        body: "Mon, Wed, Fri. Long run on Saturday if the week allows.",
        tags: const ["log"],
        pinned: false,
        updatedAt: at(4, 18, 30),
      ),
      Note(
        id: "atomic-habits",
        title: "Reading notes \u2014 Atomic Habits",
        body: "Make it obvious, attractive, easy, satisfying.",
        tags: const ["study"],
        pinned: false,
        updatedAt: at(5, 10, 0),
      ),
      Note(
        id: "sleep-log",
        title: "Sleep experiment log",
        body: "Lights out at 23:00 for a week. Mood and focus noted daily.",
        tags: const ["log"],
        pinned: false,
        updatedAt: at(6, 22, 15),
      ),
      Note(
        id: "app-ideas",
        title: "App ideas, round two",
        body: "A habit journal that feels like paper rather than a dashboard.",
        tags: const ["ideas"],
        pinned: false,
        updatedAt: at(7, 14, 10),
      ),
      Note(
        id: "thesis-refs",
        title: "Thesis references",
        body: "Collect the six core papers; tag by chapter.",
        tags: const ["study"],
        pinned: false,
        updatedAt: at(8, 16, 45),
      ),
      Note(
        id: "week-43",
        title: "Week 43 review",
        body: "A quieter week. Streak intact.",
        tags: const ["log"],
        pinned: false,
        updatedAt: at(9, 19, 30),
      ),
      Note(
        id: "gym-v1",
        title: "Gym plan v1",
        body: "Three full-body sessions. Superseded by v2.",
        tags: const ["log"],
        pinned: false,
        updatedAt: at(12, 18, 0),
      ),
    ];
  }
}
