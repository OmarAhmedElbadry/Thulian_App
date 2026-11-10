import "../domain/entities/onboarding_draft.dart";
import "../domain/repositories/onboarding_repository.dart";
import "onboarding_local_datasource.dart";

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._local);

  final OnboardingLocalDataSource _local;

  @override
  bool isComplete() => _local.isComplete();

  @override
  Future<void> saveCompleted(OnboardingDraft draft) =>
      _local.saveCompleted(draft);
}
