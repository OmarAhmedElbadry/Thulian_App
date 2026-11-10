import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_bottom_sheet.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../../../../core/widgets/chip_filter.dart";
import "../cubit/note_editor_cubit.dart";

/// Opens the tag editor for the note managed by [cubit].
Future<void> showTagsSheet(BuildContext context, NoteEditorCubit cubit) {
  return showAppBottomSheet<void>(
    context,
    title: "Tags",
    builder: (_) => BlocProvider<NoteEditorCubit>.value(
      value: cubit,
      child: const _TagsBody(),
    ),
  );
}

class _TagsBody extends StatefulWidget {
  const _TagsBody();

  @override
  State<_TagsBody> createState() => _TagsBodyState();
}

class _TagsBodyState extends State<_TagsBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    context.read<NoteEditorCubit>().addTag(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.type;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        0,
        AppSpacing.pageMargin,
        AppSpacing.xl,
      ),
      child: BlocBuilder<NoteEditorCubit, NoteEditorState>(
        builder: (context, state) {
          final tags = state.note.tags;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (tags.isEmpty)
                Text("NO TAGS YET", style: t.metaSmall)
              else ...[
                Text("TAP A TAG TO REMOVE IT", style: t.metaSmall),
                const SizedBox(height: AppSpacing.s),
                Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  children: [
                    for (final tag in tags)
                      ChipFilter(
                        label: "#$tag \u00d7",
                        selected: true,
                        onTap: () =>
                            context.read<NoteEditorCubit>().removeTag(tag),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: "New tag",
                controller: _controller,
                hint: "memory",
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: "Add tag",
                variant: AppButtonVariant.ghost,
                showArrow: false,
                onPressed: _add,
              ),
            ],
          );
        },
      ),
    );
  }
}
