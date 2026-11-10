import "../entities/onboarding_draft.dart";
import "../repositories/onboarding_repository.dart";

class CompleteOnboarding {
  const CompleteOnboarding(this._repository);

  final OnboardingRepository _repository;

  Future<void> call(OnboardingDraft draft) => _repository.saveCompleted(draft);
}
