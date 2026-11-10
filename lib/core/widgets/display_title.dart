import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";

/// Big editorial title that ends with an accent-coloured full stop ("Habits.").
class DisplayTitle extends StatelessWidget {
  const DisplayTitle(this.text, {super.key, this.extraLarge = false});

  final String text;
  final bool extraLarge;

  @override
  Widget build(BuildContext context) {
    final style = extraLarge ? context.type.displayXL : context.type.display;
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text),
          TextSpan(
            text: ".",
            style: TextStyle(color: context.colors.accent),
          ),
        ],
      ),
    );
  }
}
