import "package:get_it/get_it.dart";
import "package:go_router/go_router.dart";

import "../../features/onboarding/data/onboarding_local_datasource.dart";
import "../../features/onboarding/data/onboarding_repository_impl.dart";
import "../../features/onboarding/domain/repositories/onboarding_repository.dart";
import "../../features/onboarding/domain/usecases/complete_onboarding.dart";
import "../../features/onboarding/domain/usecases/is_onboarding_complete.dart";
import "../../features/onboarding/presentation/cubit/onboarding_cubit.dart";
import "../../features/settings/presentation/cubit/settings_cubit.dart";
import "../router/app_router.dart";
import "../services/key_value_store.dart";
import "../theme/theme_cubit.dart";

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  final store = await HiveKeyValueStore.open();
  sl
    ..registerSingleton<KeyValueStore>(store)
    ..registerSingleton<ThemeCubit>(ThemeCubit(sl<KeyValueStore>()))
    ..registerLazySingleton<SettingsCubit>(
      () => SettingsCubit(sl<KeyValueStore>()),
    )
    ..registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSource(sl<KeyValueStore>()),
    )
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(sl<OnboardingLocalDataSource>()),
    )
    ..registerLazySingleton<IsOnboardingComplete>(
      () => IsOnboardingComplete(sl<OnboardingRepository>()),
    )
    ..registerLazySingleton<CompleteOnboarding>(
      () => CompleteOnboarding(sl<OnboardingRepository>()),
    )
    ..registerFactory<OnboardingCubit>(
      () => OnboardingCubit(sl<CompleteOnboarding>()),
    )
    ..registerLazySingleton<GoRouter>(
      () => buildRouter(onboarded: sl<IsOnboardingComplete>()()),
    );
}
