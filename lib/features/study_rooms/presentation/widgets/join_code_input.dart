import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../../../core/theme/theme_extensions.dart";
import "../../../../core/theme/tokens/app_spacing.dart";
import "../../../../core/widgets/dashed_border.dart";

/// Room-code entry: one square per typed character, a dashed square for the
/// next one, and a JOIN button. [onJoin] returns true when the code was
/// accepted, which clears the field.
class JoinCodeInput extends StatefulWidget {
  const JoinCodeInput({
    super.key,
    required this.onJoin,
    this.errorText,
    this.onChanged,
  });

  final bool Function(String code) onJoin;
  final String? errorText;
  final VoidCallback? onChanged;

  static const minLength = 4;
  static const maxLength = 6;

  @override
  State<JoinCodeInput> createState() => _JoinCodeInputState();
}

class _JoinCodeInputState extends State<JoinCodeInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onText() {
    setState(() {});
    widget.onChanged?.call();
  }

  void _submit() {
    final code = _controller.text;
    if (widget.onJoin(code)) {
      _controller.clear();
      _focus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.type;
    final code = _controller.text;
    final canJoin = code.length >= JoinCodeInput.minLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 6.0;
                  final cell = math.min(
                    40.0,
                    (constraints.maxWidth -
                            gap * (JoinCodeInput.maxLength - 1)) /
                        JoinCodeInput.maxLength,
                  );
                  final cells = <Widget>[
                    for (final char in code.split(""))
                      _CodeCell(width: cell, char: char),
                    if (code.length < JoinCodeInput.maxLength)
                      _CodeCell(width: cell),
                  ];
                  return SizedBox(
                    height: 44,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Row(
                          children: [
                            for (var i = 0; i < cells.length; i++) ...[
                              if (i > 0) const SizedBox(width: gap),
                              cells[i],
                            ],
                          ],
                        ),
                        Positioned.fill(
                          child: Semantics(
                            label: "Room code",
                            textField: true,
                            child: TextField(
                              controller: _controller,
                              focusNode: _focus,
                              autocorrect: false,
                              enableSuggestions: false,
                              enableInteractiveSelection: false,
                              showCursor: false,
                              textCapitalization: TextCapitalization.characters,
                              textInputAction: TextInputAction.go,
                              onSubmitted: (_) => _submit(),
                              style: const TextStyle(color: Colors.transparent),
                              cursorColor: Colors.transparent,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp("[A-Za-z0-9]"),
                                ),
                                LengthLimitingTextInputFormatter(
                                  JoinCodeInput.maxLength,
                                ),
                                TextInputFormatter.withFunction(
                                  (old, next) => next.copyWith(
                                    text: next.text.toUpperCase(),
                                  ),
                                ),
                              ],
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                counterText: "",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Semantics(
              button: true,
              enabled: canJoin,
              label: "Join room",
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canJoin ? _submit : null,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  color: canJoin ? c.ink : c.hairline,
                  child: ExcludeSemantics(
                    child: Text(
                      "JOIN  \u2192",
                      style: t.meta.copyWith(
                        color: canJoin ? c.background : c.inkMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s),
            child: Semantics(
              liveRegion: true,
              child: Text(
                widget.errorText!.toUpperCase(),
                style: t.metaSmall.copyWith(color: c.accent),
              ),
            ),
          ),
      ],
    );
  }
}

class _CodeCell extends StatelessWidget {
  const _CodeCell({required this.width, this.char});

  final double width;
  final String? char;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final box = SizedBox(
      width: width,
      height: 44,
      child: char == null
          ? null
          : Center(
              child: Text(
                char!,
                style: context.type.meta.copyWith(
                  fontSize: 20,
                  letterSpacing: 0,
                ),
              ),
            ),
    );

    if (char == null) return DashedBorder(child: box);
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: c.ink)),
      child: box,
    );
  }
}
