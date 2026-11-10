import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_motion.dart";
import "../theme/tokens/app_sizes.dart";
import "../theme/tokens/app_spacing.dart";

enum AppButtonVariant {
  /// Filled accent button, 48 dp tall.
  primary,

  /// Outlined ink button, 48 dp tall.
  ghost,

  /// Thin accent strip (bookmark / footer CTA) inside a full touch target.
  strip,
}

/// Square, mono, uppercase button. Primary = filled accent, ghost = outlined
/// ink, strip = slim accent bar used by the auth footers.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.showArrow = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool showArrow;
  final bool loading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _setHovered(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final active = widget.onPressed != null;
    final enabled = active && !widget.loading;
    final primary = widget.variant == AppButtonVariant.primary;
    final strip = widget.variant == AppButtonVariant.strip;

    final Color background;
    final Color foreground;
    final Border? border;

    if (primary || strip) {
      final base = active ? c.accent : c.hairline;
      background = _hovered && enabled
          ? Color.alphaBlend(c.ink.withValues(alpha: 0.08), base)
          : base;
      foreground = active ? c.onAccent : c.inkMuted;
      border = null;
    } else {
      background = _hovered && enabled ? c.surface : Colors.transparent;
      foreground = active ? c.ink : c.inkMuted;
      border = Border.all(color: active ? c.ink : c.hairline);
    }

    final text = widget.showArrow
        ? "${widget.label.toUpperCase()}  \u2192"
        : widget.label.toUpperCase();

    final content = widget.loading
        ? _LoadingDots(color: foreground)
        : Text(text, style: context.type.meta.copyWith(color: foreground));

    final visual = AnimatedContainer(
      duration: AppMotion.resolve(context, AppMotion.fast),
      curve: AppMotion.curve,
      height: strip ? 24 : AppSizes.buttonHeight,
      padding: EdgeInsets.symmetric(
        horizontal: strip ? AppSpacing.m : AppSpacing.l,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, border: border),
      child: ExcludeSemantics(child: content),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => _setHovered(true),
        onExit: (_) {
          _setHovered(false);
          _setPressed(false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? widget.onPressed : null,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Center(
              child: AnimatedScale(
                scale: _pressed ? 0.985 : 1,
                duration: AppMotion.resolve(context, AppMotion.fast),
                curve: AppMotion.curve,
                child: visual,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Static three-square ellipsis shown while a button is busy. The squares are
/// intentionally stepped in opacity; no repeating animation is used so tests
/// and "reduce motion" stay calm.
class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final alpha in [0.9, 0.65, 0.4])
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: color.withValues(alpha: alpha),
          ),
      ],
    );
  }
}
