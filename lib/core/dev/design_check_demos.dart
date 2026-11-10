import "package:flutter/material.dart";

import "../theme/tokens/app_spacing.dart";
import "../widgets/app_bottom_sheet.dart";
import "../widgets/app_button.dart";
import "../widgets/app_dialog.dart";
import "../widgets/app_text_field.dart";
import "../widgets/app_toggle.dart";
import "../widgets/chip_filter.dart";
import "../widgets/empty_state.dart";
import "../widgets/error_state.dart";
import "../widgets/mascot_figure.dart";
import "../widgets/shimmer_box.dart";
import "../widgets/square_checkbox.dart";

/// Interactive demos used only by DesignCheckPage (debug).
class InputsDemo extends StatelessWidget {
  const InputsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        AppTextField(
          label: "Email",
          hint: "amira@mail.com",
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: "Password",
          obscure: true,
          errorText: "Incorrect password \u00b7 2 attempts left",
        ),
      ],
    );
  }
}

class ControlsDemo extends StatefulWidget {
  const ControlsDemo({super.key});

  @override
  State<ControlsDemo> createState() => _ControlsDemoState();
}

class _ControlsDemoState extends State<ControlsDemo> {
  bool _check = true;
  bool _toggle = true;
  String _chip = "All";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SquareCheckbox(
          value: _check,
          onChanged: (v) => setState(() => _check = v),
          label: "I accept the terms and privacy notice.",
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Daily reminder"),
            AppToggle(
              value: _toggle,
              onChanged: (v) => setState(() => _toggle = v),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final label in ["All", "Public", "Private"])
              ChipFilter(
                label: label,
                selected: _chip == label,
                onTap: () => setState(() => _chip = label),
              ),
          ],
        ),
      ],
    );
  }
}

class OverlaysDemo extends StatelessWidget {
  const OverlaysDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: "Dialog",
            showArrow: false,
            variant: AppButtonVariant.ghost,
            onPressed: () => showAppDialog(
              context,
              recordLabel: "Confirm \u00b7 N\u00ba 0001",
              title: "Leave this room?",
              message: "Your focus time so far will be filed.",
              confirmLabel: "Leave",
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: AppButton(
            label: "Sheet",
            showArrow: false,
            variant: AppButtonVariant.ghost,
            onPressed: () => showAppBottomSheet<void>(
              context,
              title: "Pick a category",
              builder: (_) => const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageMargin,
                  0,
                  AppSpacing.pageMargin,
                  AppSpacing.xl,
                ),
                child: Text("Sheet content goes here."),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatesDemo extends StatelessWidget {
  const StatesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBox(height: 20, width: 220),
        const SizedBox(height: AppSpacing.s),
        const ShimmerBox(height: 14),
        const SizedBox(height: AppSpacing.s),
        const ShimmerBox(height: 14, width: 160),
        const SizedBox(height: AppSpacing.xl),
        EmptyState(
          title: "No habits filed yet.",
          message: "Create your first entry to start the register.",
          actionLabel: "New entry",
          onAction: () {},
        ),
        ErrorState(
          message: "The register could not be loaded.",
          onRetry: () {},
        ),
        const SizedBox(height: AppSpacing.l),
        const MascotFigure(state: "Encouraging", stateIndex: 4),
      ],
    );
  }
}
