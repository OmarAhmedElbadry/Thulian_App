import "package:flutter/material.dart";

import "../theme/theme_extensions.dart";
import "../theme/tokens/app_spacing.dart";
import "../utils/format.dart";
import "app_bottom_sheet.dart";
import "app_button.dart";

/// Bottom sheet with two wheels (hours, minutes in 5-minute steps).
/// Resolves to the chosen time, or null when dismissed.
Future<TimeOfDay?> showTimeWheelSheet(
  BuildContext context, {
  required TimeOfDay initial,
  String title = "Set time",
}) {
  return showAppBottomSheet<TimeOfDay>(
    context,
    title: title,
    builder: (_) => _TimeWheel(initial: initial),
  );
}

class _TimeWheel extends StatefulWidget {
  const _TimeWheel({required this.initial});

  final TimeOfDay initial;

  @override
  State<_TimeWheel> createState() => _TimeWheelState();
}

class _TimeWheelState extends State<_TimeWheel> {
  static const _itemExtent = 48.0;

  late int _hour = widget.initial.hour;
  late int _minuteStep = widget.initial.minute ~/ 5;
  late final FixedExtentScrollController _hours = FixedExtentScrollController(
    initialItem: _hour,
  );
  late final FixedExtentScrollController _minutes = FixedExtentScrollController(
    initialItem: _minuteStep,
  );

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int count,
    required String Function(int) label,
    required ValueChanged<int> onChanged,
  }) {
    final style = context.type.timer.copyWith(fontSize: 32);
    return ListWheelScrollView(
      controller: controller,
      itemExtent: _itemExtent,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 2.2,
      perspective: 0.002,
      onSelectedItemChanged: onChanged,
      children: [
        for (var i = 0; i < count; i++)
          Center(child: Text(label(i), style: style)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.type.timer.copyWith(fontSize: 32);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        0,
        AppSpacing.pageMargin,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _itemExtent * 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _wheel(
                        controller: _hours,
                        count: 24,
                        label: two,
                        onChanged: (i) => _hour = i,
                      ),
                    ),
                    Text(":", style: style),
                    Expanded(
                      child: _wheel(
                        controller: _minutes,
                        count: 12,
                        label: (i) => two(i * 5),
                        onChanged: (i) => _minuteStep = i,
                      ),
                    ),
                  ],
                ),
                IgnorePointer(
                  child: Container(
                    height: _itemExtent,
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: c.ink),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          AppButton(
            label: "Set time",
            onPressed: () =>
                Navigator.of(context)
                    .pop(TimeOfDay(hour: _hour, minute: _minuteStep * 5)),
          ),
        ],
      ),
    );
  }
}
