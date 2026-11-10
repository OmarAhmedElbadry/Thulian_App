import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../domain/entities/onboarding_draft.dart";
import "../../domain/usecases/complete_onboarding.dart";
import "onboarding_state.dart";

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._completeOnboarding) : super(const OnboardingState());

  final CompleteOnboarding _completeOnboarding;

  void next() {
    switch (state.step) {
      case OnboardingStep.welcome:
        emit(state.copyWith(step: OnboardingStep.goals, forward: true));
      case OnboardingStep.goals:
        if (!state.canContinueGoals) {
          emit(state.copyWith(goalError: true));
          return;
        }
        emit(
          state.copyWith(
            step: OnboardingStep.dailyHour,
            forward: true,
            goalError: false,
          ),
        );
      case OnboardingStep.dailyHour:
        return;
    }
  }

  void back() {
    switch (state.step) {
      case OnboardingStep.welcome:
        return;
      case OnboardingStep.goals:
        emit(state.copyWith(step: OnboardingStep.welcome, forward: false));
      case OnboardingStep.dailyHour:
        emit(state.copyWith(step: OnboardingStep.goals, forward: false));
    }
  }

  void toggleGoal(String id) {
    final next = {...state.selectedGoalIds};
    if (!next.add(id)) next.remove(id);
    emit(state.copyWith(selectedGoalIds: next, goalError: next.isEmpty));
  }

  void setDisplayName(String value) {
    emit(state.copyWith(displayName: value));
  }

  void setReminder(TimeOfDay value) {
    emit(state.copyWith(reminder: value));
  }

  void setNotifications(bool value) {
    emit(state.copyWith(notificationsEnabled: value));
  }

  Future<void> openJournal() async {
    if (state.submitting || state.step != OnboardingStep.dailyHour) return;
    emit(state.copyWith(submitting: true, saveError: false));
    final reminder = state.reminder;
    try {
      await _completeOnboarding(
        OnboardingDraft(
          displayName: state.displayName.trim(),
          goalIds: state.selectedGoalIds,
          reminderMinutes: reminder.hour * 60 + reminder.minute,
          notificationsEnabled: state.notificationsEnabled,
        ),
      );
      if (isClosed) return;
      emit(state.copyWith(submitting: false, completed: true));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(submitting: false, saveError: true));
    }
  }
}
