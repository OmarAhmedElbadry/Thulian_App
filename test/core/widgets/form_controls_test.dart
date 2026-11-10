import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:thulian/core/theme/app_theme.dart";
import "package:thulian/core/widgets/app_toggle.dart";
import "package:thulian/core/widgets/chip_filter.dart";
import "package:thulian/core/widgets/square_checkbox.dart";

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets("SquareCheckbox reports the toggled value", (tester) async {
    bool? result;
    await tester.pumpWidget(
      _host(
        SquareCheckbox(
          value: false,
          onChanged: (v) => result = v,
          label: "Terms",
        ),
      ),
    );
    await tester.tap(find.byType(SquareCheckbox));
    expect(result, true);
  });

  testWidgets("AppToggle reports the toggled value", (tester) async {
    bool? result;
    await tester.pumpWidget(
      _host(AppToggle(value: true, onChanged: (v) => result = v)),
    );
    await tester.tap(find.byType(AppToggle));
    expect(result, false);
  });

  testWidgets("ChipFilter fires onTap", (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(ChipFilter(label: "All", selected: false, onTap: () => taps++)),
    );
    await tester.tap(find.byType(ChipFilter));
    expect(taps, 1);
  });
}
