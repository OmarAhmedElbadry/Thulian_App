import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_motion.dart";
import "../theme/tokens/app_spacing.dart";

/// Underlined editorial text field with a small mono label, optional
/// SHOW/HIDE toggle for passwords, and an accent-coloured error line.
///
/// The label and underline animate on focus and the error slot grows in and
/// out, so validation never makes the form jump.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hint,
    this.errorText,
    this.obscure = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.inputFormatters,
    this.maxLines = 1,
    this.textStyle,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final String? errorText;
  final bool obscure;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final TextStyle? textStyle;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;
  FocusNode? _internalFocus;
  bool _focused = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocus)?.removeListener(_handleFocus);
      _focusNode.addListener(_handleFocus);
      _focused = _focusNode.hasFocus;
    }
  }

  void _handleFocus() {
    if (!mounted) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _internalFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;
    final hasError = widget.errorText != null;
    final style =
        widget.textStyle ?? t.meta.copyWith(fontSize: 14, letterSpacing: 0.2);
    final labelColor = hasError ? c.accent : (_focused ? c.ink : c.inkMuted);
    final duration = AppMotion.resolve(context, AppMotion.fast);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedDefaultTextStyle(
              duration: duration,
              curve: AppMotion.curve,
              style: t.metaSmall.copyWith(color: labelColor),
              child: Text(widget.label.toUpperCase()),
            ),
            if (widget.obscure)
              Semantics(
                button: true,
                label: _hidden ? "Show password" : "Hide password",
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _hidden = !_hidden),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: AnimatedSwitcher(
                      duration: duration,
                      switchInCurve: AppMotion.curve,
                      switchOutCurve: AppMotion.curve,
                      child: Text(
                        _hidden ? "SHOW" : "HIDE",
                        key: ValueKey(_hidden),
                        style: t.metaSmall.copyWith(color: c.ink),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Semantics(
          label: widget.label,
          textField: true,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: _hidden,
            enableSuggestions: !widget.obscure,
            autocorrect: !widget.obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            autofillHints: widget.autofillHints,
            inputFormatters: widget.inputFormatters,
            maxLines: widget.obscure ? 1 : widget.maxLines,
            cursorColor: c.accent,
            style: style,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hint,
              hintStyle: style.copyWith(color: c.inkMuted),
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.s,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
        AnimatedContainer(
          duration: duration,
          curve: AppMotion.curve,
          height: hasError || _focused ? 1.5 : 1,
          color: hasError ? c.accent : (_focused ? c.ink : c.inkMuted),
        ),
        AnimatedSize(
          duration: duration,
          curve: AppMotion.curve,
          alignment: Alignment.topLeft,
          child: AnimatedOpacity(
            duration: duration,
            opacity: hasError ? 1 : 0,
            child: hasError
                ? Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        widget.errorText!.toUpperCase(),
                        style: t.metaSmall.copyWith(color: c.accent),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
      ],
    );
  }
}
