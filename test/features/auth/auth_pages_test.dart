import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:thulian/core/theme/app_theme.dart";
import "package:thulian/core/widgets/app_button.dart";
import "package:thulian/core/widgets/square_checkbox.dart";
import "package:thulian/features/auth/presentation/pages/create_account_page.dart";
import "package:thulian/features/auth/presentation/pages/recovery_page.dart";
import "package:thulian/features/auth/presentation/pages/sign_in_page.dart";

Widget _host(String initialLocation) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: "/auth/sign-in",
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: "/auth/create-account",
        builder: (context, state) => const CreateAccountPage(),
      ),
      GoRoute(
        path: "/auth/recover",
        builder: (context, state) => const RecoveryPage(),
      ),
      GoRoute(
        path: "/home",
        builder: (context, state) => const Scaffold(body: Text("HOME")),
      ),
    ],
  );
  addTearDown(router.dispose);
  return MaterialApp.router(theme: AppTheme.light, routerConfig: router);
}

Finder _action(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is AppButton && widget.label == label,
  );
}

void main() {
  testWidgets("sign in validates empty fields", (tester) async {
    await tester.pumpWidget(_host("/auth/sign-in"));
    await tester.pumpAndSettle();

    await tester.tap(_action("Sign in"));
    await tester.pumpAndSettle();

    expect(find.text("ENTER YOUR EMAIL"), findsOneWidget);
    expect(find.text("ENTER YOUR PASSWORD"), findsOneWidget);
  });

  testWidgets("sign in accepts valid details and opens the journal", (
    tester,
  ) async {
    await tester.pumpWidget(_host("/auth/sign-in"));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), "amira@mail.com");
    await tester.enterText(find.byType(TextField).at(1), "secret");
    await tester.tap(_action("Sign in"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pumpAndSettle();

    expect(find.text("HOME"), findsOneWidget);
  });

  testWidgets("create account requires valid fields and the terms", (
    tester,
  ) async {
    await tester.pumpWidget(_host("/auth/create-account"));
    await tester.pumpAndSettle();

    await tester.tap(_action("Create account"));
    await tester.pumpAndSettle();

    expect(find.text("ENTER YOUR NAME"), findsOneWidget);
    expect(find.text("ENTER YOUR EMAIL"), findsOneWidget);
    expect(find.text("CHOOSE A PASSWORD"), findsOneWidget);
    expect(find.text("ACCEPT THE TERMS TO CONTINUE"), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), "Amira Khalil");
    await tester.enterText(find.byType(TextField).at(1), "amira@mail.com");
    await tester.enterText(find.byType(TextField).at(2), "Password1");
    await tester.pump();
    expect(find.text("GOOD"), findsOneWidget);

    await tester.tap(find.byType(SquareCheckbox));
    await tester.pumpAndSettle();
    await tester.tap(_action("Create account"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 950));
    await tester.pumpAndSettle();

    expect(find.text("HOME"), findsOneWidget);
  });

  testWidgets("recovery sends a link and counts down to the next resend", (
    tester,
  ) async {
    await tester.pumpWidget(_host("/auth/recover"));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, "amira@mail.com");
    await tester.tap(_action("Send reset link"));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(find.text("LINK SENT"), findsOneWidget);
    expect(find.text("Check amira@mail.com."), findsOneWidget);
    expect(find.text("RESEND IN 00:42"), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text("RESEND IN 00:41"), findsOneWidget);

    // Dispose the page so the countdown timer is cancelled.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets("auth pages fit a small phone without overflowing", (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final path in const [
      "/auth/sign-in",
      "/auth/create-account",
      "/auth/recover",
    ]) {
      await tester.pumpWidget(_host(path));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: path);
    }
  });

  testWidgets("sign in keeps its action above the keyboard", (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host("/auth/sign-in"));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final action = tester.getRect(_action("Sign in"));
    expect(action.bottom, lessThanOrEqualTo(544));
  });

  testWidgets("recovery enables resend at the end of the cooldown", (
    tester,
  ) async {
    await tester.pumpWidget(_host("/auth/recover"));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, "amira@mail.com");
    await tester.tap(_action("Send reset link"));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();
    await tester.pump(const Duration(seconds: 42));
    await tester.pump();

    expect(find.text("RESEND LINK"), findsOneWidget);

    await tester.tap(find.text("RESEND LINK"));
    await tester.pump();
    expect(find.text("RESEND IN 00:42"), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
