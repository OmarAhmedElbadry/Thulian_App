import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";

/// Horizontal mascot-state legend under the completion row. The active state is
/// underlined in accent. Static for now; Phase 6 binds these states to Rive.
class MascotStateStrip extends StatelessWidget {
  const MascotStateStrip({
    super.key,
    required this.states,
    required this.activeIndex,
  });

  final List<String> states;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.type.metaSmall.copyWith(
      fontSize: 8.5,
      letterSpacing: 0.8,
      height: 1.2,
      color: c.inkMuted,
    );

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < states.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  right: i == states.length - 1 ? 0 : 12,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(2, 0, 2, 3),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == activeIndex ? c.accent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(states[i], style: style),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
