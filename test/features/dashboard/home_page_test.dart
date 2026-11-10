import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:thulian/core/theme/app_theme.dart";
import "package:thulian/features/dashboard/data/dashboard_mock_data.dart";
import "package:thulian/features/dashboard/presentation/dashboard_format.dart";
import "package:thulian/features/dashboard/presentation/pages/home_page.dart";

/// Tuesday 3 November 2026, the date shown in the approved home mockup.
final _now = DateTime(2026, 11, 3, 9, 30);

Widget _host({DateTime? now}) {
  final router = GoRouter(
    initialLocation: "/home",
    routes: [
      GoRoute(
        path: "/home",
        builder: (context, state) => Scaffold(
          body: HomePage(data: DashboardMockData.snapshot, now: now ?? _now),
        ),
      ),
      GoRoute(
        path: "/habits",
        builder: (context, state) => const Scaffold(body: Text("HABITS")),
      ),
      GoRoute(
        path: "/rooms",
        builder: (context, state) => const Scaffold(body: Text("ROOMS")),
      ),
      GoRoute(
        path: "/notes",
        builder: (context, state) => const Scaffold(body: Text("NOTES")),
      ),
    ],
  );
  addTearDown(router.dispose);
  return MaterialApp.router(theme: AppTheme.light, routerConfig: router);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Interaction tests use a tall viewport so the whole page is reachable
/// without scrolling; layout is covered separately at phone sizes.
void _tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group("dashboard formatting", () {
    test("shortDateLabel matches the editorial date line", () {
      expect(
        shortDateLabel(DateTime(2026, 11, 3)),
        "TUE \u00b7 03 / 11 / 2026",
      );
    });

    test("record numbers follow the day of the year", () {
      expect(dayOfYear(DateTime(2026, 11, 3)), 307);
      expect(recordNumber(DateTime(2026, 11, 3)), "0307");
      expect(recordNumber(DateTime(2026, 1, 1)), "0001");
      expect(isoWeekNumber(DateTime(2026, 11, 3)), 45);
    });

    test("greetingFor changes across the day", () {
      expect(greetingFor(DateTime(2026, 11, 3, 7)), "Good morning");
      expect(greetingFor(DateTime(2026, 11, 3, 13)), "Good afternoon");
      expect(greetingFor(DateTime(2026, 11, 3, 19)), "Good evening");
    });

    test("focusClock renders hours and minutes", () {
      expect(focusClock(0), "00:00");
      expect(focusClock(402), "06:42");
      expect(focusClock(65), "01:05");
    });

    test("completionLabel pads both numbers", () {
      expect(completionLabel(2, 3), "02 of 03 habits filed");
      expect(completionLabel(10, 12), "10 of 12 habits filed");
    });
  });

  testWidgets("home shows the daily record from the mockup", (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    // Header and date block.
    expect(find.text("TUE \u00b7 03 / 11 / 2026"), findsOneWidget);
    expect(find.text("NO 0307"), findsOneWidget);
    expect(find.text("P. 01 / 12"), findsOneWidget);
    expect(find.textContaining("Good morning,"), findsOneWidget);
    expect(find.textContaining("Amira."), findsOneWidget);
    expect(find.text("WK 45"), findsOneWidget);
    expect(find.text("DAY 307"), findsOneWidget);

    // Completion block.
    expect(find.text("COMPLETED TODAY"), findsOneWidget);
    expect(find.text("67"), findsOneWidget);
    expect(find.text("%"), findsOneWidget);
    expect(find.text("02 of 03 habits filed"), findsOneWidget);

    // Mascot plate and state strip.
    expect(find.text("FIG. 01"), findsOneWidget);
    expect(find.text("ENCOURAGING"), findsOneWidget);
    expect(find.text("ENCOURAGE"), findsOneWidget);
    expect(find.text("CELEBRATE"), findsOneWidget);

    // Habit rows.
    expect(find.text("01 \u2014 TODAY'S HABITS"), findsOneWidget);
    expect(find.text("3 ENTRIES"), findsOneWidget);
    expect(find.text("Read 20 pages"), findsOneWidget);
    expect(find.text("Morning stretch"), findsOneWidget);
    expect(find.text("Focus block, 90 min"), findsOneWidget);
    expect(find.text("STR 14"), findsOneWidget);
    expect(find.text("STR 31"), findsOneWidget);
    expect(find.text("PENDING"), findsOneWidget);

    // Stat band.
    expect(find.text("02 \u2014 STREAK"), findsOneWidget);
    expect(find.text("14"), findsOneWidget);
    expect(find.text("days"), findsOneWidget);
    expect(find.text("03 \u2014 FOCUS"), findsOneWidget);
    expect(find.text("06:42"), findsOneWidget);
    expect(find.text("04 \u2014 WEEK"), findsOneWidget);
    expect(find.text("5/7"), findsOneWidget);

    // Shortcut cards.
    expect(find.text("05 \u2014 STUDY ROOMS"), findsOneWidget);
    expect(find.text("3 LIVE NOW"), findsOneWidget);
    expect(find.text("06 \u2014 NOTES"), findsOneWidget);
    expect(find.text("12 ENTRIES"), findsOneWidget);
  });

  testWidgets("tapping a pending habit files it and updates the page", (
    tester,
  ) async {
    _tallScreen(tester);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await _tap(tester, find.text("Focus block, 90 min"));

    expect(find.text("100"), findsOneWidget);
    expect(find.text("03 of 03 habits filed"), findsOneWidget);
    expect(find.text("PENDING"), findsNothing);
    expect(find.text("STR 0"), findsOneWidget);

    await _tap(tester, find.text("Focus block, 90 min"));
    expect(find.text("67"), findsOneWidget);
    expect(find.text("02 of 03 habits filed"), findsOneWidget);
  });

  testWidgets("unfiling a done habit lowers the completion figure", (
    tester,
  ) async {
    _tallScreen(tester);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await _tap(tester, find.text("Read 20 pages"));

    expect(find.text("33"), findsOneWidget);
    expect(find.text("01 of 03 habits filed"), findsOneWidget);
    expect(find.text("STR 14"), findsNothing);
  });

  testWidgets("study rooms shortcut opens the rooms branch", (tester) async {
    _tallScreen(tester);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await _tap(tester, find.byKey(const ValueKey("home-study-rooms")));

    expect(find.text("ROOMS"), findsOneWidget);
  });

  testWidgets("notes shortcut opens the notes branch", (tester) async {
    _tallScreen(tester);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    await _tap(tester, find.byKey(const ValueKey("home-notes")));

    expect(find.text("NOTES"), findsOneWidget);
  });

  testWidgets("home fits a small phone without overflowing", (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
