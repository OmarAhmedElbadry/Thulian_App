import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../../../../core/di/injection.dart";
import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_motion.dart";
import "../../../../core/theme/tokens/app_sizes.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/record_header.dart";
import "../cubit/onboarding_cubit.dart";
import "../cubit/onboarding_state.dart";
import "../widgets/daily_hour_step.dart";
import "../widgets/goals_step.dart";
import "../widgets/journal_step_switcher.dart";
import "../widgets/welcome_step.dart";

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, this.cubit});

  final OnboardingCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final provided = cubit;
    if (provided != null) {
      return BlocProvider<OnboardingCubit>.value(
        value: provided,
        child: const _OnboardingView(),
      );
    }
    return BlocProvider(
      create: (_) => sl<OnboardingCubit>(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: context.read<OnboardingCubit>().state.displayName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final cubit = context.read<OnboardingCubit>();
    final result = await showTimePicker(
      context: context,
      initialTime: cubit.state.reminder,
    );
    if (result != null) cubit.setReminder(result);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) =>
          !previous.completed && current.completed,
      listener: (context, state) => context.go(AppRoutes.home),
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              final cubit = context.read<OnboardingCubit>();
              final welcome = state.step == OnboardingStep.welcome;
              return PopScope(
                canPop: welcome,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) cubit.back();
                },
                child: Column(
                  children: [
                    RecordHeader(
                      label: welcome
                          ? "WELCOME \u00b7 N\u2116 0001"
                          : "INTAKE \u00b7 N\u2116 0001",
                      page: "P. 0${state.intakeIndex}",
                    ),
                    if (!welcome) _Progress(state: state),
                    Expanded(
                      child: JournalStepSwitcher(
                        stepIndex: state.intakeIndex,
                        forward: state.forward,
                        expand: true,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pageMargin,
                              AppSpacing.l,
                              AppSpacing.pageMargin,
                              AppSpacing.xl,
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: AppSizes.maxContentWidth,
                              ),
                              child: switch (state.step) {
                                OnboardingStep.welcome => const WelcomeStep(),
                                OnboardingStep.goals => GoalsStep(
                                  selectedIds: state.selectedGoalIds,
                                  onToggle: cubit.toggleGoal,
                                  showError: state.goalError,
                                ),
                                OnboardingStep.dailyHour => DailyHourStep(
                                  nameController: _nameController,
                                  reminder: state.reminder,
                                  notificationsEnabled:
                                      state.notificationsEnabled,
                                  onNameChanged: cubit.setDisplayName,
                                  onPickTime: _pickTime,
                                  onNotificationsChanged:
                                      cubit.setNotifications,
                                ),
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageMargin,
                        AppSpacing.m,
                        AppSpacing.pageMargin,
                        AppSpacing.m,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppSizes.maxContentWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (state.saveError) ...[
                              Text(
                                "COULD NOT SAVE YOUR JOURNAL \u00b7 TRY AGAIN",
                                style: context.type.metaSmall.copyWith(
                                  color: context.colors.accent,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s),
                            ],
                            JournalStepSwitcher(
                              stepIndex: state.intakeIndex,
                              forward: state.forward,
                              child: welcome
                                  ? _WelcomeActions(onBegin: cubit.next)
                                  : _IntakeActions(
                                      primaryLabel:
                                          state.step == OnboardingStep.dailyHour
                                          ? "Open my journal"
                                          : "Continue",
                                      primaryEnabled:
                                          state.step != OnboardingStep.goals ||
                                          state.canContinueGoals,
                                      submitting: state.submitting,
                                      onBack: cubit.back,
                                      onPrimary:
                                          state.step == OnboardingStep.dailyHour
                                          ? cubit.openJournal
                                          : cubit.next,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final filled = state.intakeIndex;
    final total = state.intakeTotal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.s,
        AppSpacing.pageMargin,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(total, (i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: AppMotion.resolve(context, AppMotion.base),
                  curve: AppMotion.curve,
                  height: 4,
                  margin: EdgeInsets.only(
                    right: i == total - 1 ? 0 : AppSpacing.s,
                  ),
                  color: i < filled ? c.accent : c.hairline,
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            "STEP ${_two(filled)} / ${_two(total)}",
            style: context.type.metaSmall.copyWith(color: c.inkMuted),
          ),
        ],
      ),
    );
  }

  static String _two(int value) => value.toString().padLeft(2, "0");
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions({required this.onBegin});

  final VoidCallback onBegin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(label: "Begin", onPressed: onBegin),
        const SizedBox(height: AppSpacing.s),
        TextButton(
          onPressed: () => context.push(AppRoutes.authSignIn),
          child: Text(
            "I ALREADY HAVE AN ACCOUNT",
            style: context.type.meta.copyWith(color: context.colors.ink),
          ),
        ),
      ],
    );
  }
}

class _IntakeActions extends StatelessWidget {
  const _IntakeActions({
    required this.primaryLabel,
    required this.primaryEnabled,
    required this.submitting,
    required this.onBack,
    required this.onPrimary,
  });

  final String primaryLabel;
  final bool primaryEnabled;
  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: "Back",
            showArrow: false,
            variant: AppButtonVariant.ghost,
            onPressed: submitting ? null : onBack,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          flex: 2,
          child: AppButton(
            label: primaryLabel,
            onPressed: primaryEnabled && !submitting ? onPrimary : null,
          ),
        ),
      ],
    );
  }
}
