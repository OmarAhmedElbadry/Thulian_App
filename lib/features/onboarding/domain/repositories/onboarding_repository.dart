import "../entities/onboarding_draft.dart";

abstract interface class OnboardingRepository {
  bool isComplete();
  Future<void> saveCompleted(OnboardingDraft draft);
}
