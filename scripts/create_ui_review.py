#!/usr/bin/env python3
"""Assemble QA artifacts from real Flutter captures, never from generated mocks.

Run from any directory with Python 3 and Pillow. Missing captures are listed and
omitted rather than replaced by reference images. Use --strict in CI to fail if
any of the ten required captures are absent. No production asset is modified.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from statistics import median

from PIL import Image, ImageDraw, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
SCENARIOS = (
    ("01_main_menu", "Main menu"),
    ("02_casual_gameplay", "Casual gameplay"),
    ("03_transition_warning", "Transition warning"),
    ("04_target_mode", "Target mode"),
    ("05_game_over", "Game over"),
    ("06_campaign_map", "Campaign map"),
    ("07_chaos_entry", "Chaos entry"),
    ("08_profile", "Profile"),
    ("09_settings", "Settings"),
    ("10_leaderboards", "Leaderboards"),
)
BG = "#10172A"
TEXT = "#F5F7FF"
MUTED = "#A8BCD8"
CYAN = "#00D9FF"


def font(size: int) -> ImageFont.ImageFont:
    for path in (
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ):
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default(size=size)


def fitted(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    """Preserve aspect ratio: padding reveals inconsistent poster proportions."""
    result = Image.new("RGB", size, BG)
    scaled = ImageOps.contain(image.convert("RGB"), size, Image.Resampling.LANCZOS)
    result.paste(scaled, ((size[0] - scaled.width) // 2, (size[1] - scaled.height) // 2))
    return result


def reference_content(image: Image.Image) -> tuple[Image.Image, tuple[int, ...]]:
    # User-supplied crops include illustrated phone hardware. These conservative
    # insets remove the outer frame without attempting content-aware alteration.
    box = (10, 8, image.width - 10, image.height - 10)
    return image.crop(box), box


def measure_reference(reference_dir: Path, out_dir: Path) -> None:
    # Small hand-inspected texture/flat-fill samples exclude type and hardware.
    # These are approximate raster samples, not claims about original design tokens.
    patches = (
        ("background_navy", "09_settings.png", (40, 12, 174, 20)),
        ("navigation_navy", "09_settings.png", (28, 383, 112, 390)),
        ("panel_navy", "09_settings.png", (98, 149, 110, 156)),
        ("cyan_slider", "09_settings.png", (116, 68, 128, 70)),
        ("haptics_green", "09_settings.png", (161, 115, 170, 120)),
        ("primary_yellow", "01_main_menu.png", (56, 186, 67, 193)),
        ("primary_orange", "01_main_menu.png", (56, 200, 67, 205)),
    )
    measurements = []
    for name, filename, box in patches:
        path = reference_dir / filename
        if not path.exists():
            continue
        image = Image.open(path).convert("RGB")
        patch = image.crop(box)
        pixels = [patch.getpixel((x, y)) for y in range(patch.height) for x in range(patch.width)]
        rgb = tuple(round(median(p[channel] for p in pixels)) for channel in range(3))
        measurements.append({
            "name": name,
            "source": str(path.relative_to(ROOT)),
            "sample_box_left_top_right_bottom": list(box),
            "method": "median RGB of manually selected non-text interior patch",
            "rgb": list(rgb),
            "hex": "#%02X%02X%02X" % rgb,
            "pixels_sampled": len(pixels),
        })
    document = {
        "note": "Approximate samples from a small illustrated reference; not exact source design tokens. Sample patches avoid text and phone hardware. Original reference files remain unchanged.",
        "samples": measurements,
        "reference_crop_insets": {"left": 10, "top": 8, "right": 10, "bottom": 10},
        "comparison_limitations": [
            "The upper-row board drawings contain camera notches extending below the eight-pixel inset. Any remaining black notch is reference-only hardware and excluded from fidelity assessment.",
            "Poster screens have inconsistent aspect ratios. Comparison images preserve each source aspect ratio with letterboxing rather than stretching content.",
            "Phone corner hardware may remain at the extreme corners after approximate cropping and is excluded from assessment.",
            "No numerical pixel-diff score is presented as evidence of reference matching.",
        ],
    }
    (out_dir / "reference_measurements.json").write_text(json.dumps(document, indent=2) + "\n")


def build_review(args: argparse.Namespace) -> int:
    screenshot_dir = args.screenshots.resolve()
    reference_dir = args.references.resolve()
    out_dir = args.output.resolve()
    comparison_dir = out_dir / "comparisons"
    comparison_dir.mkdir(parents=True, exist_ok=True)
    records = []
    missing = []
    previews = []
    for slug, title in SCENARIOS:
        screenshot = screenshot_dir / f"{slug}.png"
        reference = reference_dir / f"{slug}.png"
        if not screenshot.exists():
            missing.append(str(screenshot))
            continue
        if not reference.exists():
            missing.append(str(reference))
            continue
        actual = Image.open(screenshot).convert("RGB")
        original_reference = Image.open(reference).convert("RGB")
        content, crop_box = reference_content(original_reference)
        width, height, gutter = 390, 844, 24
        panel = Image.new("RGB", (width * 2 + gutter * 3, height + 130), BG)
        draw = ImageDraw.Draw(panel)
        draw.text((gutter, 15), f"{slug[:2]}  {title}", fill=TEXT, font=font(23))
        draw.text((gutter, 50), "REFERENCE - approximate content crop", fill=MUTED, font=font(15))
        draw.text((width + gutter * 2, 50), "ACTUAL FLUTTER RENDER", fill=CYAN, font=font(15))
        panel.paste(fitted(content, (width, height)), (gutter, 78))
        panel.paste(fitted(actual, (width, height)), (width + gutter * 2, 78))
        draw.text((gutter, height + 95), "Aspect ratios preserved. Reference camera notch / hardware is excluded from review.", fill=MUTED, font=font(14))
        output = comparison_dir / f"{slug}_comparison.png"
        panel.save(output, optimize=True)
        records.append({
            "scenario": slug,
            "screenshot": str(screenshot),
            "screenshot_dimensions": list(actual.size),
            "screenshot_sha256": hashlib.sha256(screenshot.read_bytes()).hexdigest(),
            "reference": str(reference),
            "reference_dimensions": list(original_reference.size),
            "reference_content_crop": list(crop_box),
            "comparison": str(output),
        })
        previews.append((slug, title, actual))

    contact_path = out_dir / "rendered_app_contact_sheet.png"
    if previews:
        # The contact sheet contains actual captures only, never references.
        cell_w, cell_h, margin, header = 246, 592, 18, 94
        cols = 5
        rows = (len(previews) + cols - 1) // cols
        sheet = Image.new("RGB", (cols * cell_w + margin * (cols + 1), rows * cell_h + margin * (rows + 1) + header), BG)
        draw = ImageDraw.Draw(sheet)
        draw.text((margin, 17), "TOUCH QUEST - ACTUAL FLUTTER RENDERS", fill=TEXT, font=font(27))
        draw.text((margin, 54), f"{len(previews)}/10 reference scenarios captured. Production widgets; deterministic gallery fixtures.", fill=MUTED, font=font(18))
        for i, (slug, title, actual) in enumerate(previews):
            x = margin + (i % cols) * (cell_w + margin)
            y = header + margin + (i // cols) * (cell_h + margin)
            draw.text((x, y), f"{slug[:2]}  {title}", fill=TEXT, font=font(18))
            sheet.paste(fitted(actual, (cell_w, 546)), (x, y + 34))
        sheet.save(contact_path, optimize=True)

    measure_reference(reference_dir, out_dir)
    summary = {
        "captured": len(records),
        "required": len(SCENARIOS),
        "complete": len(records) == len(SCENARIOS),
        "missing": missing,
        "contact_sheet": str(contact_path) if previews else None,
        "comparisons": records,
        "notes": [
            "Artifacts use input screenshot files only. This script does not run or capture the app.",
            "Existing screenshots must be recaptured after implementation changes; this script cannot establish runtime freshness.",
        ],
    }
    (out_dir / "capture_manifest.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(f"Created {len(records)}/10 reference comparisons.")
    if previews:
        print(f"Rendered-app contact sheet: {contact_path}")
    for path in missing:
        print(f"Missing: {path}")
    return 1 if args.strict and missing else 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--screenshots", type=Path, default=ROOT / "docs/ui-review/screenshots")
    parser.add_argument("--references", type=Path, default=ROOT / "design/reference/screens")
    parser.add_argument("--output", type=Path, default=ROOT / "docs/ui-review")
    parser.add_argument("--strict", action="store_true", help="Fail when any expected capture or reference is missing")
    return build_review(parser.parse_args())


if __name__ == "__main__":
    raise SystemExit(main())
