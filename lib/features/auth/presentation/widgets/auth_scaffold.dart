import "package:flutter/material.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_sizes.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/display_title.dart";
import "../../../../core/widgets/record_header.dart";
import "../../../../core/widgets/reveal.dart";

/// Shared frame for the auth flow: record header, scrolling editorial body,
/// and an optional pinned footer above the keyboard.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.recordLabel,
    required this.title,
    required this.children,
    this.footer,
    this.leading,
    this.page = "P.",
  });

  final String recordLabel;
  final String page;

  /// Display title without the trailing accent dot.
  final String title;

  /// Optional widget above the title (e.g. the recovery back link).
  final Widget? leading;

  /// Body content, revealed in a short cascade after the title.
  final List<Widget> children;

  /// Pinned footer (rule, primary action, secondary link).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            RecordHeader(label: recordLabel, page: page),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageMargin,
                    AppSpacing.l,
                    AppSpacing.pageMargin,
                    AppSpacing.xl,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: RevealGroup(
                      children: [
                        if (leading != null) ...[
                          leading!,
                          const SizedBox(height: AppSpacing.s),
                        ],
                        DisplayTitle(title),
                        const SizedBox(height: AppSpacing.xl),
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ?footer,
          ],
        ),
      ),
    );
  }
}

/// Footer for auth pages. The top rule is full-bleed, while the content stays
/// aligned with the page margin and capped at [AppSizes.maxContentWidth].
class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.ink, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.m,
          AppSpacing.pageMargin,
          AppSpacing.l,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
