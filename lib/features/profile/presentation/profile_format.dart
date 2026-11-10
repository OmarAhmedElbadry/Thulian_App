/// Presentation-only number formatting for the profile page.
library;

/// 2480 -> "2,480"
String formatThousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(",");
    buffer.write(digits[i]);
  }
  return value < 0 ? "-$buffer" : buffer.toString();
}
