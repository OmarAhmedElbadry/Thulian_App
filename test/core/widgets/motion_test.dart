import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:thulian/core/theme/app_theme.dart";
import "package:thulian/core/widgets/fade_indexed_stack.dart";
import "package:thulian/core/widgets/reveal.dart";

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  );
}

Opacity _revealOpacity(WidgetTester tester) {
  return tester.widget<Opacity>(
    find.descendant(of: find.byType(Reveal), matching: find.byType(Opacity)),
  );
}

void main() {
  testWidgets("Reveal fades and lifts its child into place", (tester) async {
    await tester.pumpWidget(_host(const Reveal(child: Text("REVEALED"))));

    expect(_revealOpacity(tester).opacity, 0);
    await tester.pumpAndSettle();
    expect(_revealOpacity(tester).opacity, 1);
  });

  testWidgets("Reveal is static when animations are disabled", (tester) async {
    await tester.pumpWidget(
      _host(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Reveal(child: Text("STATIC")),
        ),
      ),
    );

    expect(find.text("STATIC"), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Reveal), matching: find.byType(Opacity)),
      findsNothing,
    );
  });

  testWidgets("FadeIndexedStack cross-fades and keeps both branches", (
    tester,
  ) async {
    final index = ValueNotifier<int>(0);
    addTearDown(index.dispose);

    await tester.pumpWidget(
      _host(
        ValueListenableBuilder<int>(
          valueListenable: index,
          builder: (context, value, child) {
            return FadeIndexedStack(
              index: value,
              children: const [Text("FIRST"), Text("SECOND")],
            );
          },
        ),
      ),
    );

    double opacityOf(int branch) {
      return tester
          .widget<AnimatedOpacity>(
            find.descendant(
              of: find.byKey(ValueKey(branch)),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity;
    }

    expect(find.text("FIRST"), findsOneWidget);
    expect(find.text("SECOND"), findsOneWidget);
    expect(opacityOf(0), 1);
    expect(opacityOf(1), 0);

    index.value = 1;
    await tester.pumpAndSettle();

    expect(find.text("FIRST"), findsOneWidget);
    expect(find.text("SECOND"), findsOneWidget);
    expect(opacityOf(0), 0);
    expect(opacityOf(1), 1);
  });
}
