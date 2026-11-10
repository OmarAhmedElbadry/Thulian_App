import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/display_title.dart";
import "../../../../core/widgets/empty_state.dart";
import "../../../../core/widgets/journal_body.dart";
import "../../../../core/widgets/record_header.dart";
import "../../../../core/widgets/section_header.dart";
import "../../../../core/widgets/segmented_choice.dart";
import "../../data/rooms_mock_store.dart";
import "../../domain/entities/study_room.dart";
import "../widgets/create_room_sheet.dart";
import "../widgets/join_code_input.dart";
import "../widgets/room_row.dart";

/// Room index (P. 04 / 12): join by code, then discover public and private
/// rooms. Backed by [RoomsMockStore] until Phase 8.
class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  RoomVisibility? _filter;
  String? _joinError;

  bool _join(String code) {
    final trimmed = code.trim();
    if (trimmed.length < JoinCodeInput.minLength) {
      setState(() => _joinError = "Codes are 4\u20136 characters");
      return false;
    }
    final room = RoomsMockStore.instance.byCode(trimmed);
    if (room == null) {
      setState(() => _joinError = "No room with that code");
      return false;
    }
    setState(() => _joinError = null);
    _open(room);
    return true;
  }

  void _open(StudyRoom room) {
    context.push(AppRoutes.roomSessionPath(room.id));
  }

  Future<void> _create() async {
    final room = await showCreateRoomSheet(context);
    if (room == null || !mounted) return;
    _open(room);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const RecordHeader(
          label: "ROOM INDEX \u00b7 N\u00ba 0310",
          page: "P. 04 / 12",
        ),
        Expanded(
          child: ValueListenableBuilder<List<StudyRoom>>(
            valueListenable: RoomsMockStore.instance.rooms,
            builder: (context, all, _) {
              final rooms = _filter == null
                  ? all
                  : all.where((r) => r.visibility == _filter).toList();

              return JournalBody(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(child: DisplayTitle("Rooms")),
                      AppButton(
                        label: "+ Create",
                        showArrow: false,
                        onPressed: _create,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  const SectionHeader(
                    number: "01",
                    title: "Join by code",
                    trailing: "4\u20136 chars",
                    strong: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  JoinCodeInput(
                    onJoin: _join,
                    errorText: _joinError,
                    onChanged: () {
                      if (_joinError != null) {
                        setState(() => _joinError = null);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.l),
                  SectionHeader(
                    number: "02",
                    title: "Discover",
                    trailing: "${rooms.length} rooms",
                    strong: true,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  SegmentedChoice<RoomVisibility?>(
                    expand: false,
                    options: const [
                      (null, "All"),
                      (RoomVisibility.public, "Public"),
                      (RoomVisibility.private, "Private"),
                    ],
                    value: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  if (rooms.isEmpty)
                    EmptyState(
                      label: "No rooms",
                      title: "Nothing here yet.",
                      message: "Create a room or join one with a code.",
                      actionLabel: "Create room",
                      onAction: _create,
                    )
                  else
                    for (var i = 0; i < rooms.length; i++)
                      RoomRow(
                        index: i + 1,
                        room: rooms[i],
                        onTap: () => _open(rooms[i]),
                      ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
