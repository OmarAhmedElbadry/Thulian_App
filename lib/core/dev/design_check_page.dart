import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

import "../router/app_routes.dart";
import "../theme/theme_cubit.dart";
import "../theme/theme_extensions.dart";
import "../theme/tokens/app_spacing.dart";
import "../widgets/app_button.dart";
import "../widgets/display_title.dart";
import "../widgets/hairline_divider.dart";
import "../widgets/page_header.dart";
import "../widgets/reveal.dart";
import "../widgets/section_header.dart";
import "design_check_demos.dart";

/// Debug-only page to eyeball tokens, typography and base components in both themes.
class DesignCheckPage extends StatelessWidget {
  const DesignCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;
    const gap = SizedBox(height: AppSpacing.xl);

    final swatches = <String, Color>{
      "background": c.background,
      "surface": c.surface,
      "ink": c.ink,
      "inkMuted": c.inkMuted,
      "hairline": c.hairline,
      "accent": c.accent,
      "onAccent": c.onAccent,
      "accentSoft": c.accentSoft,
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          children: [
            const PageHeader(
              label: "Design check \u00b7 N\u00ba 0000",
              page: "P. 00",
            ),
            _pad(const DisplayTitle("Design check", extraLarge: true)),
            gap,
            _pad(const SectionHeader(number: "01", title: "Theme")),
            _pad(const _ThemeToggle()),
            gap,
            _pad(const SectionHeader(number: "02", title: "Colour tokens")),
            _pad(
              Wrap(
                spacing: AppSpacing.m,
                runSpacing: AppSpacing.m,
                children: [
                  for (final entry in swatches.entries)
                    _Swatch(name: entry.key, color: entry.value),
                ],
              ),
            ),
            gap,
            _pad(const SectionHeader(number: "03", title: "Typography")),
            _pad(Text("Good morning, Amira.", style: t.display)),
            const SizedBox(height: AppSpacing.m),
            _pad(
              Text("A quiet archive of everything you do.", style: t.headline),
            ),
            const SizedBox(height: AppSpacing.m),
            _pad(
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("67", style: t.stat.copyWith(fontSize: 64)),
                  const SizedBox(width: AppSpacing.s),
                  Text("% FILED", style: t.meta),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            _pad(Text("17:42", style: t.timer)),
            const SizedBox(height: AppSpacing.m),
            _pad(
              Text(
                "DAILY RECORD \u00b7 N\u00ba 0307 \u00b7 TUE 03.11.2026",
                style: t.meta,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            _pad(
              Text(
                "Sleep does the filing. Spaced review beats a single long session; "
                "test yourself before re-reading.",
                style: t.body,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            _pad(
              Text(
                "Small body text \u2014 list sub-lines and captions.",
                style: t.bodySmall,
              ),
            ),
            gap,
            _pad(const SectionHeader(number: "04", title: "Buttons")),
            _pad(AppButton(label: "Begin", onPressed: () {})),
            const SizedBox(height: AppSpacing.m),
            _pad(
              AppButton(
                label: "Save draft",
                variant: AppButtonVariant.ghost,
                onPressed: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            _pad(const AppButton(label: "Disabled", onPressed: null)),
            gap,
            _pad(const SectionHeader(number: "05", title: "Inputs")),
            _pad(const InputsDemo()),
            gap,
            _pad(const SectionHeader(number: "06", title: "Controls")),
            _pad(const ControlsDemo()),
            gap,
            _pad(const SectionHeader(number: "07", title: "Overlays")),
            _pad(const OverlaysDemo()),
            gap,
            _pad(const SectionHeader(number: "08", title: "States")),
            _pad(const StatesDemo()),
            gap,
            _pad(const SectionHeader(number: "09", title: "Motion")),
            _pad(const _MotionDemo()),
            gap,
            _pad(const SectionHeader(number: "10", title: "Auth screens")),
            _pad(const _AuthLinks()),
            gap,
            _pad(const HairlineDivider(strong: true)),
          ],
        ),
      ),
    );
  }

  static Widget _pad(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
      child: child,
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: context.colors.hairline),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(name.toUpperCase(), style: context.type.metaSmall),
        ],
      ),
    );
  }
}

class _MotionDemo extends StatefulWidget {
  const _MotionDemo();

  @override
  State<_MotionDemo> createState() => _MotionDemoState();
}

class _MotionDemoState extends State<_MotionDemo> {
  int _run = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeyedSubtree(
          key: ValueKey(_run),
          child: RevealGroup(
            children: [
              AppButton(label: "Primary action", onPressed: () {}),
              const SizedBox(height: AppSpacing.s),
              AppButton(
                label: "Ghost action",
                variant: AppButtonVariant.ghost,
                showArrow: false,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.s),
              AppButton(label: "Loading", loading: true, onPressed: () {}),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        AppButton(
          label: "Replay reveal",
          variant: AppButtonVariant.ghost,
          showArrow: false,
          onPressed: () => setState(() => _run++),
        ),
      ],
    );
  }
}

class _AuthLinks extends StatelessWidget {
  const _AuthLinks();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: "Sign in",
          onPressed: () => context.push(AppRoutes.authSignIn),
        ),
        const SizedBox(height: AppSpacing.s),
        AppButton(
          label: "Create account",
          variant: AppButtonVariant.ghost,
          onPressed: () => context.push(AppRoutes.authCreateAccount),
        ),
        const SizedBox(height: AppSpacing.s),
        AppButton(
          label: "Recover",
          variant: AppButtonVariant.ghost,
          onPressed: () => context.push(AppRoutes.authRecover),
        ),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        Widget option(String label, ThemeMode value) {
          return Expanded(
            child: AppButton(
              label: label,
              showArrow: false,
              variant: mode == value
                  ? AppButtonVariant.primary
                  : AppButtonVariant.ghost,
              onPressed: () => context.read<ThemeCubit>().setMode(value),
            ),
          );
        }

        return Row(
          children: [
            option("Light", ThemeMode.light),
            const SizedBox(width: AppSpacing.s),
            option("Dark", ThemeMode.dark),
            const SizedBox(width: AppSpacing.s),
            option("System", ThemeMode.system),
          ],
        );
      },
    );
  }
}
