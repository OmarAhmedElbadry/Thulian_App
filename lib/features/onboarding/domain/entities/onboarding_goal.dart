class OnboardingGoal {
  const OnboardingGoal({
    required this.id,
    required this.title,
    required this.meta,
  });

  final String id;
  final String title;
  final String meta;
}

abstract final class OnboardingCatalog {
  static const goals = <OnboardingGoal>[
    OnboardingGoal(
      id: "study_focus",
      title: "Study & focus",
      meta: "ROOMS \u00b7 TIMERS",
    ),
    OnboardingGoal(id: "fitness", title: "Fitness", meta: "BODY \u00b7 WEEKLY"),
    OnboardingGoal(id: "reading", title: "Reading", meta: "MIND \u00b7 DAILY"),
    OnboardingGoal(id: "sleep", title: "Sleep", meta: "REST \u00b7 NIGHTLY"),
    OnboardingGoal(
      id: "mindfulness",
      title: "Mindfulness",
      meta: "MIND \u00b7 DAILY",
    ),
    OnboardingGoal(
      id: "deep_work",
      title: "Deep work",
      meta: "WORK \u00b7 BLOCKS",
    ),
  ];

  static const defaultSelectedIds = {"study_focus", "reading"};
}
