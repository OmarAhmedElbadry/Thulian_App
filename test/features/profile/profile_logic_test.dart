import "package:flutter_test/flutter_test.dart";
import "package:thulian/features/profile/data/profile_mock_data.dart";
import "package:thulian/features/profile/presentation/profile_format.dart";

void main() {
  test("formatThousands", () {
    expect(formatThousands(0), "0");
    expect(formatThousands(999), "999");
    expect(formatThousands(2480), "2,480");
    expect(formatThousands(1234567), "1,234,567");
  });

  test("mock profile matches the mockup", () {
    final p = ProfileMockData.snapshot;
    expect(p.initial, "A");
    expect(p.unlockedStamps, 2);
    expect(p.levelProgress, closeTo(2480 / 3000, 1e-9));
    expect(p.weekActivity, hasLength(7));
  });
}
