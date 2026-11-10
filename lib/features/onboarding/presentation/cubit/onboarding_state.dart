import "package:flutter/material.dart";

import "../../domain/entities/onboarding_goal.dart";

enum OnboardingStep { welcome, goals, dailyHour }

class OnboardingState {
  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.forward = true,
    this.selectedGoalIds = OnboardingCatalog.defaultSelectedIds,
    this.displayName = "",
    this.reminder = const TimeOfDay(hour: 21, minute: 30),
    this.notificationsEnabled = true,
    this.goalError = false,
    this.completed = false,
    this.submitting = false,
    this.saveError = false,
  });

  final OnboardingStep step;
  final bool forward;
  final Set<String> selectedGoalIds;
  final String displayName;
  final TimeOfDay reminder;
  final bool notificationsEnabled;
  final bool goalError;
  final bool completed;
  final bool submitting;
  final bool saveError;

  bool get canContinueGoals => selectedGoalIds.isNotEmpty;

  /// Welcome is a cover page, so only the remaining steps are counted.
  int get intakeTotal => OnboardingStep.values.length - 1;

  int get intakeIndex => switch (step) {
    OnboardingStep.welcome => 0,
    OnboardingStep.goals => 1,
    OnboardingStep.dailyHour => 2,
  };

  OnboardingState copyWith({
    OnboardingStep? step,
    bool? forward,
    Set<String>? selectedGoalIds,
    String? displayName,
    TimeOfDay? reminder,
    bool? notificationsEnabled,
    bool? goalError,
    bool? completed,
    bool? submitting,
    bool? saveError,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      forward: forward ?? this.forward,
      selectedGoalIds: selectedGoalIds ?? this.selectedGoalIds,
      displayName: displayName ?? this.displayName,
      reminder: reminder ?? this.reminder,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      goalError: goalError ?? this.goalError,
      completed: completed ?? this.completed,
      submitting: submitting ?? this.submitting,
      saveError: saveError ?? this.saveError,
    );
  }
}
