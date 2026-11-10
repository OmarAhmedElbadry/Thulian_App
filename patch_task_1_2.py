"""
Run from the Flutter project root AFTER copying lib/ and test/ from this package:
    python patch_task_1_2.py

1. design_check_page.dart: adds sections 05-09 (inputs, controls, overlays, states).
2. app_button.dart / archival_nav_bar.dart: use AppSizes instead of magic numbers.
Safe to re-run: already-patched files are skipped.
"""
from pathlib import Path


def patch(path, edits):
    p = Path(path)
    s = p.read_text(encoding="utf-8")
    if edits[0][1] in s:
        print("skip (already patched):", path)
        return
    for old, new in edits:
        assert s.count(old) == 1, f"anchor not found exactly once in {path}: {old[:60]!r}"
        s = s.replace(old, new)
    p.write_text(s, encoding="utf-8")
    print("patched:", path)


patch("lib/core/dev/design_check_page.dart", [
    ('import "../widgets/app_button.dart";',
     'import "design_check_demos.dart";\nimport "../widgets/app_button.dart";'),
    ('            _pad(const HairlineDivider(strong: true)),',
     """            _pad(const SectionHeader(number: "05", title: "Inputs")),
            _pad(const InputsDemo()),
            gap,
            _pad(const SectionHeader(number: "06", title: "Controls")),
            _pad(const ControlsDemo()),
            gap,
            _pad(const SectionHeader(number: "07", title: "Dialog and sheet")),
            _pad(const OverlaysDemo()),
            gap,
            _pad(const SectionHeader(number: "08", title: "Loading, empty, error, mascot")),
            _pad(const StatesDemo()),
            gap,
            _pad(const HairlineDivider(strong: true)),"""),
])

patch("lib/core/widgets/app_button.dart", [
    ('import "../theme/tokens/app_spacing.dart";',
     'import "../theme/tokens/app_sizes.dart";\nimport "../theme/tokens/app_spacing.dart";'),
    ("          height: 48,", "          height: AppSizes.buttonHeight,"),
])

patch("lib/core/widgets/archival_nav_bar.dart", [
    ('import "../theme/tokens/app_spacing.dart";',
     'import "../theme/tokens/app_sizes.dart";\nimport "../theme/tokens/app_spacing.dart";'),
    ("          height: 56,", "          height: AppSizes.navBarHeight,"),
])
