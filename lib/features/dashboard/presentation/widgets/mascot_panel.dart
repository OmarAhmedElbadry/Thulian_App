import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/widgets/mascot_figure.dart";

/// Framed mascot plate at the top of the dashboard: the temporary heart face
/// on a surface panel, with the spec footer from the mockup
/// ("FIG. 01 / ENCOURAGING / RIVE SLOT STATE / 04").
///
/// Phase 6 replaces [HeartMascot] with the animated Rive component; the frame
/// and footer stay.
class MascotPanel extends StatelessWidget {
  const MascotPanel({
    super.key,
    this.figure = 1,
    required this.state,
    required this.stateIndex,
  });

  final int figure;
  final String state;
  final int stateIndex;

  String _two(int value) => value.toString().padLeft(2, "0");

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.type.metaSmall.copyWith(
      fontSize: 8.5,
      letterSpacing: 0.6,
      height: 1.2,
    );

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: c.background,
        border: Border.all(color: c.ink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Semantics(
              image: true,
              label: "Mascot, ${state.toLowerCase()}",
              child: Container(
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border(bottom: BorderSide(color: c.ink)),
                ),
                alignment: Alignment.bottomCenter,
                child: const HeartMascot(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FIG. ${_two(figure)}",
                  style: style.copyWith(color: c.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  state.toUpperCase(),
                  style: style.copyWith(color: c.ink),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "RIVE SLOT",
                        style: style.copyWith(color: c.inkMuted),
                        maxLines: 1,
                      ),
                    ),
                    Text("STATE", style: style.copyWith(color: c.inkMuted)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _two(stateIndex),
                  style: style.copyWith(color: c.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
