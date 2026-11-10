import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../../../../core/router/app_routes.dart";
import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/utils/format.dart";
import "../../../../core/widgets/app_button.dart";
import "../../../../core/widgets/app_dialog.dart";
import "../../../../core/widgets/error_state.dart";
import "../../../../core/widgets/journal_body.dart";
import "../../../../core/widgets/mascot_figure.dart";
import "../../../../core/widgets/pinned_footer.dart";
import "../../../../core/widgets/record_header.dart";
import "../../data/rooms_mock_store.dart";
import "../../domain/entities/study_room.dart";
import "../../domain/entities/study_session.dart";
import "../cubit/session_cubit.dart";
import "../widgets/leaderboard_row.dart";

/// Active focus session (no bottom navigation). Shows the block countdown, the
/// elapsed rule and the live leaderboard. Driven by [SessionCubit].
class SessionPage extends StatelessWidget {
  const SessionPage({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    final room = RoomsMockStore.instance.byId(roomId);
    if (room == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const RecordHeader(label: "SESSION LOG", page: "P."),
              Expanded(
                child: Center(
                  child: ErrorState(
                    title: "Room not found.",
                    message: "This room is no longer available.",
                    onRetry: () => context.go(AppRoutes.rooms),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider<SessionCubit>(
      create: (_) => SessionCubit(room),
      child: _SessionView(room: room),
    );
  }
}

class _SessionView extends StatelessWidget {
  const _SessionView({required this.room});

  final StudyRoom room;

  Future<void> _leave(BuildContext context) async {
    final cubit = context.read<SessionCubit>();
    if (cubit.state.status != SessionStatus.finished) {
      final confirmed = await showAppDialog(
        context,
        recordLabel: "Session log \u00b7 Room N\u00ba ${room.number}",
        title: "Leave this room?",
        message: "Your focus time so far will be filed.",
        confirmLabel: "Leave",
      );
      if (confirmed != true || !context.mounted) return;
    }
    cubit.leave();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.rooms);
    }
  }

  void _primary(BuildContext context, SessionState state) {
    final cubit = context.read<SessionCubit>();
    switch (state.status) {
      case SessionStatus.idle:
        cubit.start();
      case SessionStatus.running:
        cubit.pause();
      case SessionStatus.paused:
        cubit.resume();
      case SessionStatus.finished:
        _leave(context);
    }
  }

  static String _primaryLabel(SessionStatus status) {
    return switch (status) {
      SessionStatus.idle => "Start session",
      SessionStatus.running => "Pause session",
      SessionStatus.paused => "Resume session",
      SessionStatus.finished => "Finish session",
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: BlocBuilder<SessionCubit, SessionState>(
          builder: (context, state) {
            return Column(
              children: [
                _SessionHeader(room: room, status: state.status),
                Expanded(
                  child: JournalBody(
                    children: [
                      _TitleBlock(room: room),
                      const SizedBox(height: AppSpacing.l),
                      _TimerBlock(state: state),
                      const SizedBox(height: AppSpacing.l),
                      _Leaderboard(state: state),
                    ],
                  ),
                ),
                PinnedFooter(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: AppButton(
                          label: _primaryLabel(state.status),
                          showArrow: false,
                          onPressed: () => _primary(context, state),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        flex: 3,
                        child: AppButton(
                          label: "Leave",
                          variant: AppButtonVariant.ghost,
                          showArrow: false,
                          onPressed: () => _leave(context),
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
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.room, required this.status});

  final StudyRoom room;
  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.type.metaSmall;

    final Widget badge = switch (status) {
      SessionStatus.running => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, color: c.accent),
          const SizedBox(width: 6),
          Text("LIVE", style: style.copyWith(color: c.accent)),
        ],
      ),
      SessionStatus.paused => Text("PAUSED", style: style),
      SessionStatus.idle => Text("READY", style: style),
      SessionStatus.finished => Text("COMPLETE", style: style),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.l,
        AppSpacing.pageMargin,
        AppSpacing.m,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "SESSION LOG \u00b7 ROOM N\u00ba ${room.number.toString().padLeft(3, "0")}",
                  style: style,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              badge,
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Container(height: 1, color: c.ink),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.room});

  final StudyRoom room;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "STUDY ROOM \u00b7 ${room.visibility.name.toUpperCase()}",
                style: t.metaSmall,
              ),
              const SizedBox(height: 6),
              Text(room.name, style: t.display.copyWith(fontSize: 26)),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("CODE", style: t.metaSmall),
            const SizedBox(height: 2),
            Text(room.displayCode, style: t.meta.copyWith(letterSpacing: 0.5)),
          ],
        ),
      ],
    );
  }
}

class _TimerBlock extends StatelessWidget {
  const _TimerBlock({required this.state});

  final SessionState state;

  String get _caption {
    final block = "BLOCK ${two(state.blockIndex)} / ${two(state.blockCount)}";
    return switch (state.status) {
      SessionStatus.idle => "READY \u00b7 $block",
      SessionStatus.running ||
      SessionStatus.paused => "REMAINING \u00b7 $block",
      SessionStatus.finished => "BLOCK COMPLETE \u00b7 $block",
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;
    final paused = state.status == SessionStatus.paused;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_caption, style: t.metaSmall),
        const SizedBox(height: AppSpacing.s),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Semantics(
                  label:
                      "${state.remainingSeconds ~/ 60} minutes "
                      "${state.remainingSeconds % 60} seconds remaining",
                  child: ExcludeSemantics(
                    child: Text(
                      formatMinutesSeconds(state.remainingSeconds),
                      style: t.timer.copyWith(
                        color: paused ? c.inkMuted : c.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            const MascotFace(size: 56),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        SizedBox(
          height: 2,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: c.hairline),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: state.progress,
                child: ColoredBox(color: c.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("00:00", style: t.metaSmall),
            Text(
              "${formatMinutesSeconds(state.elapsedSeconds)} ELAPSED",
              style: t.metaSmall,
            ),
            Text(formatMinutesSeconds(state.blockSeconds), style: t.metaSmall),
          ],
        ),
      ],
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.state});

  final SessionState state;

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final board = state.leaderboard;
    final top = board.isEmpty ? 0 : board.first.focusSeconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 1, color: context.colors.hairline),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("LEADERBOARD \u00b7 TODAY", style: t.metaSmall),
              Text("${board.length} IN ROOM", style: t.metaSmall),
            ],
          ),
        ),
        for (var i = 0; i < board.length; i++)
          LeaderboardRow(
            key: ValueKey(board[i].id),
            rank: i + 1,
            participant: board[i],
            topSeconds: top,
          ),
      ],
    );
  }
}
