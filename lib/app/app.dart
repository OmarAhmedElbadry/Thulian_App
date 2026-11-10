import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../core/di/injection.dart";
import "../core/theme/app_theme.dart";
import "../core/theme/theme_cubit.dart";
import "../core/theme/tokens/app_motion.dart";

class ThulianApp extends StatelessWidget {
  const ThulianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>.value(
      value: sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp.router(
            title: "Thulian",
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode,
            themeAnimationDuration: AppMotion.slow,
            themeAnimationCurve: AppMotion.curve,
            routerConfig: sl<GoRouter>(),
          );
        },
      ),
    );
  }
}
