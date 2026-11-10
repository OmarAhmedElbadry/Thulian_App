import "package:flutter/material.dart";

import "tokens/thulian_colors.dart";
import "typography/thulian_type.dart";

/// `context.colors` and `context.type`: the only way widgets read design tokens.
extension ThulianThemeContext on BuildContext {
  ThulianColors get colors => Theme.of(this).extension<ThulianColors>()!;
  ThulianType get type => Theme.of(this).extension<ThulianType>()!;
}
