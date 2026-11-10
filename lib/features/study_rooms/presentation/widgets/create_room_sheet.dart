import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_bottom_sheet.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/app_text_field.dart";
import "../../../../core/widgets/segmented_choice.dart";
import "../../data/rooms_mock_store.dart";
import "../../domain/entities/study_room.dart";

/// Opens the "New room" sheet. Resolves to the created room, or null.
Future<StudyRoom?> showCreateRoomSheet(BuildContext context) {
  return showAppBottomSheet<StudyRoom>(
    context,
    title: "New room",
    builder: (_) => const _CreateRoomForm(),
  );
}

class _CreateRoomForm extends StatefulWidget {
  const _CreateRoomForm();

  @override
  State<_CreateRoomForm> createState() => _CreateRoomFormState();
}

class _CreateRoomFormState extends State<_CreateRoomForm> {
  final _name = TextEditingController();
  RoomVisibility _visibility = RoomVisibility.private;
  int _blockMinutes = 50;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _create() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = "Give the room a name");
      return;
    }
    final room = RoomsMockStore.instance.create(
      name: _name.text,
      visibility: _visibility,
      blockMinutes: _blockMinutes,
    );
    Navigator.of(context).pop(room);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: "Room name",
            controller: _name,
            hint: "Library, 3rd floor",
            textCapitalization: TextCapitalization.sentences,
            errorText: _error,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Text("VISIBILITY", style: t.metaSmall),
          ),
          SegmentedChoice<RoomVisibility>(
            options: const [
              (RoomVisibility.public, "Public"),
              (RoomVisibility.private, "Private"),
            ],
            value: _visibility,
            onChanged: (value) => setState(() => _visibility = value),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Text("BLOCK LENGTH", style: t.metaSmall),
          ),
          SegmentedChoice<int>(
            options: const [(25, "25 min"), (50, "50 min"), (90, "90 min")],
            value: _blockMinutes,
            onChanged: (value) => setState(() => _blockMinutes = value),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: "Create room", onPressed: _create),
        ],
      ),
    );
  }
}
