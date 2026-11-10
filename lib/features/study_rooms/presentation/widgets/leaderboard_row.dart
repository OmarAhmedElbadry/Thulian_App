import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/utils/format.dart";
import "../../domain/entities/study_session.dart";

/// One leaderboard line: rank, name with a relative bar, focus time, status.
/// The signed-in participant sits on a surface band and is tinted accent.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.participant,
    required this.topSeconds,
  });

  final int rank;
  final SessionParticipant participant;

  /// Focus time of the leader, used to scale the bars.
  final int topSeconds;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;
    final you = participant.isYou;
    final onBreak = participant.status == ParticipantStatus.onBreak;
    final double fraction = topSeconds == 0
        ? 0.0
        : (participant.focusSeconds / topSeconds).clamp(0.0, 1.0).toDouble();
    final time = formatHoursMinutesSeconds(participant.focusSeconds);
    final name = you ? "${participant.name} \u00b7 you" : participant.name;

    return Semantics(
      label: "${two(rank)}, $name, $time, ${onBreak ? "on break" : "focusing"}",
      child: ExcludeSemantics(
        child: Container(
          color: you ? c.surface : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(two(rank), style: t.metaSmall),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: t.title.copyWith(
                        fontSize: 17,
                        color: you ? c.accent : c.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 2,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(color: c.hairline),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: fraction,
                            child: ColoredBox(color: you ? c.accent : c.ink),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: t.meta.copyWith(fontSize: 15, letterSpacing: 0),
                  ),
                  const SizedBox(height: 2),
                  Text(onBreak ? "BREAK" : "FOCUSING", style: t.metaSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
