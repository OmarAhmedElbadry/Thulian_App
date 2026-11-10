import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/utils/format.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/app_dialog.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../../../../core/widgets/display_title.dart";
import "../../../../core/widgets/journal_body.dart";
import "../../../../core/widgets/page_nav_row.dart";
import "../../../../core/widgets/pinned_footer.dart";
import "../../../../core/widgets/record_header.dart";
import "../../../../core/widgets/segmented_choice.dart";
import "../../../../core/widgets/time_wheel_sheet.dart";
import "../../data/habits_mock_store.dart";
import "../../domain/entities/habit_draft.dart";
import "../../domain/entities/habit_entry.dart";
import "../cubit/create_habit_cubit.dart";
import "../habit_format.dart";
import "../widgets/habit_preview_card.dart";
import "../widgets/habit_value_tiles.dart";
import "../widgets/weekday_picker.dart";

/// "File a new habit" (P. 03 / 12). Composes a [HabitDraft] through
/// [CreateHabitCubit]; the mock store stands in for Firestore until Phase 4.
class CreateHabitPage extends StatelessWidget {
  const CreateHabitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateHabitCubit>(
      create: (_) => CreateHabitCubit(HabitsMockStore.instance),
      child: const _CreateHabitView(),
    );
  }
}

class _CreateHabitView extends StatefulWidget {
  const _CreateHabitView();

  @override
  State<_CreateHabitView> createState() => _CreateHabitViewState();
}

class _CreateHabitViewState extends State<_CreateHabitView> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: context.read<CreateHabitCubit>().state.draft.name,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.habits);
    }
  }

  Future<void> _cancel() async {
    final cubit = context.read<CreateHabitCubit>();
    if (cubit.state.dirty) {
      final discard = await showAppDialog(
        context,
        recordLabel: "Draft \u00b7 N\u00ba 0309",
        title: "Discard this entry?",
        message: "Your unsaved changes will be lost.",
        confirmLabel: "Discard",
        cancelLabel: "Keep editing",
      );
      if (discard != true || !mounted) return;
    }
    _close();
  }

  Future<void> _pickReminder(int currentMinutes) async {
    final cubit = context.read<CreateHabitCubit>();
    final picked = await showTimeWheelSheet(
      context,
      title: "Daily reminder",
      initial: TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      ),
    );
    if (picked == null) return;
    cubit.setReminder(picked.hour * 60 + picked.minute);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<CreateHabitCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<CreateHabitCubit, CreateHabitState>(
          listenWhen: (previous, next) => previous.savedTick != next.savedTick,
          listener: (context, state) => _toast("Draft saved."),
        ),
        BlocListener<CreateHabitCubit, CreateHabitState>(
          listenWhen: (previous, next) => !previous.filed && next.filed,
          listener: (context, state) {
            _toast("Filed \u00b7 ${state.draft.name.trim()}");
            _close();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: BlocBuilder<CreateHabitCubit, CreateHabitState>(
            builder: (context, state) {
              final draft = state.draft;
              final weekly = draft.frequency == HabitFrequency.weekly;
              final draftLabel = state.saved && !state.dirty
                  ? "Draft \u00b7 saved"
                  : "Draft \u00b7 unsaved";

              return Column(
                children: [
                  const RecordHeader(
                    label: "NEW ENTRY \u00b7 N\u00ba 0309",
                    page: "P. 03 / 12",
                  ),
                  Expanded(
                    child: JournalBody(
                      children: [
                        PageNavRow(
                          backLabel: "Cancel",
                          onBack: _cancel,
                          trailing: draftLabel,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        const DisplayTitle("File a new\nhabit"),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          label: "01 \u2014 Name",
                          controller: _name,
                          hint: "Evening journal",
                          textStyle: context.type.title.copyWith(fontSize: 22),
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          errorText: state.showNameError && !draft.hasName
                              ? "Give the habit a name"
                              : null,
                          onChanged: cubit.setName,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _FieldLabel("02 \u2014 Category"),
                        SegmentedChoice<HabitCategory>(
                          options: [
                            for (final category in HabitCategory.values)
                              (category, category.name),
                          ],
                          value: draft.category,
                          onChanged: cubit.setCategory,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _FieldLabel("03 \u2014 Frequency"),
                        SegmentedChoice<HabitFrequency>(
                          expand: false,
                          options: const [
                            (HabitFrequency.daily, "Daily"),
                            (HabitFrequency.weekly, "Weekly"),
                          ],
                          value: draft.frequency,
                          onChanged: cubit.setFrequency,
                        ),
                        if (weekly) ...[
                          const SizedBox(height: AppSpacing.m),
                          WeekdayPicker(
                            selected: draft.weeklyDays,
                            onToggle: cubit.toggleDay,
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            scheduleCaption(draft).toUpperCase(),
                            style: context.type.metaSmall,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: HabitValueTile(
                                label: "04 \u2014 Reminder",
                                value: formatClockMinutes(
                                  draft.reminderMinutes,
                                ),
                                onTap: () =>
                                    _pickReminder(draft.reminderMinutes),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xl),
                            Expanded(
                              child: HabitStepperTile(
                                label: "05 \u2014 Target",
                                value: "${draft.targetMinutes} min",
                                onDecrease: () =>
                                    cubit.adjustTarget(-HabitDraft.targetStep),
                                onIncrease: () =>
                                    cubit.adjustTarget(HabitDraft.targetStep),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        HabitPreviewCard(
                          title: draft.hasName
                              ? draft.name.trim()
                              : "Untitled habit",
                          meta: previewMeta(draft),
                        ),
                      ],
                    ),
                  ),
                  PinnedFooter(
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: "Save draft",
                            variant: AppButtonVariant.ghost,
                            showArrow: false,
                            onPressed: cubit.saveDraft,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: AppButton(
                            label: "File habit",
                            onPressed: cubit.file,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Text(text.toUpperCase(), style: context.type.metaSmall),
    );
  }
}
