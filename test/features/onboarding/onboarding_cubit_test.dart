import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:thulian/core/services/key_value_store.dart";
import "package:thulian/features/onboarding/data/onboarding_local_datasource.dart";
import "package:thulian/features/onboarding/data/onboarding_repository_impl.dart";
import "package:thulian/features/onboarding/domain/entities/onboarding_draft.dart";
import "package:thulian/features/onboarding/domain/repositories/onboarding_repository.dart";
import "package:thulian/features/onboarding/domain/usecases/complete_onboarding.dart";
import "package:thulian/features/onboarding/presentation/cubit/onboarding_cubit.dart";
import "package:thulian/features/onboarding/presentation/cubit/onboarding_state.dart";

class _MemoryStore implements KeyValueStore {
  final Map<String, Object?> data = {};

  @override
  T? read<T>(String key) {
    final value = data[key];
    return value is T ? value : null;
  }

  @override
  Future<void> write(String key, Object? value) async => data[key] = value;
}

class _RecordingRepo implements OnboardingRepository {
  OnboardingDraft? saved;

  @override
  bool isComplete() => saved != null;

  @override
  Future<void> saveCompleted(OnboardingDraft draft) async => saved = draft;
}

class _FlakyRepo implements OnboardingRepository {
  int calls = 0;
  OnboardingDraft? saved;

  @override
  bool isComplete() => saved != null;

  @override
  Future<void> saveCompleted(OnboardingDraft draft) async {
    calls++;
    if (calls == 1) throw StateError("disk unavailable");
    saved = draft;
  }
}

void main() {
  group("OnboardingCubit", () {
    late OnboardingCubit cubit;

    setUp(() {
      cubit = OnboardingCubit(CompleteOnboarding(_RecordingRepo()));
    });

    tearDown(() => cubit.close());

    test("starts on welcome and advances through intake", () {
      expect(cubit.state.step, OnboardingStep.welcome);
      cubit.next();
      expect(cubit.state.step, OnboardingStep.goals);
      expect(cubit.state.forward, isTrue);
      cubit.next();
      expect(cubit.state.step, OnboardingStep.dailyHour);
    });

    test("back returns to the previous step", () {
      cubit
        ..next()
        ..next()
        ..back();
      expect(cubit.state.step, OnboardingStep.goals);
      expect(cubit.state.forward, isFalse);
      cubit.back();
      expect(cubit.state.step, OnboardingStep.welcome);
    });

    test("blocks continue when no goals are selected", () {
      cubit.next();
      for (final id in {...cubit.state.selectedGoalIds}) {
        cubit.toggleGoal(id);
      }
      cubit.next();
      expect(cubit.state.step, OnboardingStep.goals);
      expect(cubit.state.goalError, isTrue);
      expect(cubit.state.canContinueGoals, isFalse);
    });

    test("openJournal persists the draft and marks completed", () async {
      final repo = _RecordingRepo();
      final completing = OnboardingCubit(CompleteOnboarding(repo));
      completing
        ..next()
        ..next()
        ..setDisplayName(" Amira ")
        ..setReminder(const TimeOfDay(hour: 21, minute: 30))
        ..setNotifications(false);
      await completing.openJournal();
      expect(completing.state.completed, isTrue);
      expect(repo.saved?.displayName, "Amira");
      expect(repo.saved?.reminderMinutes, 21 * 60 + 30);
      expect(repo.saved?.notificationsEnabled, isFalse);
      expect(repo.saved?.goalIds, containsAll(["study_focus", "reading"]));
      await completing.close();
    });

    test("a failed save reports an error without getting stuck", () async {
      final failing = OnboardingCubit(CompleteOnboarding(_FlakyRepo()));
      failing
        ..next()
        ..next();
      await failing.openJournal();
      expect(failing.state.saveError, isTrue);
      expect(failing.state.submitting, isFalse);
      expect(failing.state.completed, isFalse);
      await failing.close();
    });

    test(
      "retrying after a failed save succeeds and clears the error",
      () async {
        final repo = _FlakyRepo();
        final retrying = OnboardingCubit(CompleteOnboarding(repo));
        retrying
          ..next()
          ..next();
        await retrying.openJournal();
        expect(retrying.state.saveError, isTrue);

        await retrying.openJournal();
        expect(retrying.state.saveError, isFalse);
        expect(retrying.state.completed, isTrue);
        expect(repo.saved, isNotNull);
        await retrying.close();
      },
    );
  });

  group("OnboardingRepositoryImpl", () {
    test("saveCompleted writes local keys", () async {
      final store = _MemoryStore();
      final repo = OnboardingRepositoryImpl(OnboardingLocalDataSource(store));
      expect(repo.isComplete(), isFalse);
      await repo.saveCompleted(
        const OnboardingDraft(
          displayName: "Amira",
          goalIds: {"reading"},
          reminderMinutes: 90,
          notificationsEnabled: true,
        ),
      );
      expect(repo.isComplete(), isTrue);
      expect(store.data[OnboardingLocalDataSource.nameKey], "Amira");
      expect(store.data[OnboardingLocalDataSource.goalsKey], "reading");
      expect(store.data[OnboardingLocalDataSource.reminderKey], 90);
      expect(store.data[OnboardingLocalDataSource.notificationsKey], isTrue);
      expect(store.data[OnboardingLocalDataSource.completeKey], isTrue);
    });
  });
}
