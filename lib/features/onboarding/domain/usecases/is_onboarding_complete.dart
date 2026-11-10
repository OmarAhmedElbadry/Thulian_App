import "../repositories/onboarding_repository.dart";

class IsOnboardingComplete {
  const IsOnboardingComplete(this._repository);

  final OnboardingRepository _repository;

  bool call() => _repository.isComplete();
}
