class OnboardingDraft {
  const OnboardingDraft({
    required this.displayName,
    required this.goalIds,
    required this.reminderMinutes,
    required this.notificationsEnabled,
  });

  final String displayName;
  final Set<String> goalIds;
  final int reminderMinutes;
  final bool notificationsEnabled;
}
