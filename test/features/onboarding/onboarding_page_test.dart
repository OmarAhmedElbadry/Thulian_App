import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:go_router/go_router.dart";
import "package:thulian/core/router/app_routes.dart";
import "package:thulian/core/theme/app_theme.dart";
import "package:thulian/features/onboarding/domain/entities/onboarding_draft.dart";
import "package:thulian/features/onboarding/domain/repositories/onboarding_repository.dart";
import "package:thulian/features/onboarding/domain/usecases/complete_onboarding.dart";
import "package:thulian/features/onboarding/presentation/cubit/onboarding_cubit.dart";
import "package:thulian/features/onboarding/presentation/pages/onboarding_page.dart";

class _Repo implements OnboardingRepository {
  @override
  bool isComplete() => false;

  @override
  Future<void> saveCompleted(OnboardingDraft draft) async {}
}

Widget _host(OnboardingCubit cubit) {
  return MaterialApp(
    theme: AppTheme.light,
    home: OnboardingPage(cubit: cubit),
  );
}

Future<void> _begin(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel("Begin"));
  await tester.pumpAndSettle();
}

Future<void> _openDailyHour(WidgetTester tester) async {
  await _begin(tester);
  await tester.tap(find.bySemanticsLabel("Continue"));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets("welcome advances to goals then daily hour", (tester) async {
    final cubit = OnboardingCubit(CompleteOnboarding(_Repo()));
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));

    expect(find.textContaining("A quiet archive"), findsOneWidget);
    await _begin(tester);

    expect(find.textContaining("What are you filing"), findsOneWidget);
    expect(find.text("STEP 01 / 02"), findsOneWidget);

    await tester.tap(find.bySemanticsLabel("Continue"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Set your daily hour"), findsOneWidget);
    expect(find.text("STEP 02 / 02"), findsOneWidget);
    expect(find.text("21:30"), findsOneWidget);

    await tester.tap(find.bySemanticsLabel("Back"));
    await tester.pumpAndSettle();
    expect(find.textContaining("What are you filing"), findsOneWidget);
  });

  testWidgets("continue is blocked when no goals are selected", (tester) async {
    final cubit = OnboardingCubit(CompleteOnboarding(_Repo()));
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await _begin(tester);

    // Both defaults are selected at this point.
    await tester.tap(find.text("Study & focus"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Reading"));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel("Continue"));
    await tester.pumpAndSettle();

    expect(find.textContaining("What are you filing"), findsOneWidget);
    expect(find.text("PICK AT LEAST ONE AREA TO FILE"), findsOneWidget);
  });

  testWidgets("system back returns to the previous step", (tester) async {
    final cubit = OnboardingCubit(CompleteOnboarding(_Repo()));
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await _openDailyHour(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.textContaining("What are you filing"), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.textContaining("A quiet archive"), findsOneWidget);
  });

  testWidgets("keyboard keeps the actions above it without overflowing", (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final cubit = OnboardingCubit(CompleteOnboarding(_Repo()));
    addTearDown(cubit.close);
    await tester.pumpWidget(_host(cubit));
    await _openDailyHour(tester);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final action = tester.getRect(find.bySemanticsLabel("Open my journal"));
    expect(action.bottom, greaterThan(500));
    expect(action.bottom, lessThanOrEqualTo(544));
  });

  testWidgets("opening the journal saves and navigates home", (tester) async {
    final cubit = OnboardingCubit(CompleteOnboarding(_Repo()));
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: "/onboarding",
      routes: [
        GoRoute(
          path: "/onboarding",
          builder: (context, state) => OnboardingPage(cubit: cubit),
        ),
        GoRoute(
          path: "/home",
          builder: (context, state) => const Scaffold(body: Text("HOME")),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await _openDailyHour(tester);

    await tester.tap(find.bySemanticsLabel("Open my journal"));
    await tester.pumpAndSettle();

    expect(find.text("HOME"), findsOneWidget);
    expect(cubit.state.completed, isTrue);
  });

  testWidgets("welcome sign-in link opens the auth route", (tester) async {
    final cubit = OnboardingCubit(CompleteOnboarding(_Repo()));
    addTearDown(cubit.close);
    final router = GoRouter(
      initialLocation: "/onboarding",
      routes: [
        GoRoute(
          path: "/onboarding",
          builder: (context, state) => OnboardingPage(cubit: cubit),
        ),
        GoRoute(
          path: AppRoutes.authSignIn,
          builder: (context, state) =>
              const Scaffold(body: Text("SIGN IN PAGE")),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
    await tester.tap(find.text("I ALREADY HAVE AN ACCOUNT"));
    await tester.pumpAndSettle();

    expect(find.text("SIGN IN PAGE"), findsOneWidget);
  });
}
