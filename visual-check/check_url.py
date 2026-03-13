"""Visual Check Tool - Screenshot and inspect web pages or PDFs.

Captures screenshots of localhost URLs or live sites for visual inspection.
Can check for common rendering issues: blank areas, overflow, broken layouts.

Usage:
    # Screenshot a URL (desktop + mobile)
    uv run python ~/scripts/visual-check/check_url.py http://localhost:5173/narratives

    # Screenshot with specific viewport
    uv run python ~/scripts/visual-check/check_url.py http://localhost:5173 --width=375 --height=812

    # Check a PDF (delegates to econai visual_check)
    uv run python ~/scripts/visual-check/check_url.py paper.pdf

Requirements:
    uv pip install playwright
    playwright install chromium
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from datetime import datetime
from pathlib import Path


SCREENSHOT_DIR = Path("/tmp/visual-checks")

VIEWPORTS = {
    "desktop": {"width": 1440, "height": 900},
    "tablet": {"width": 768, "height": 1024},
    "mobile": {"width": 375, "height": 812},
}


def screenshot_url(
    url: str,
    output_dir: Path,
    viewports: list[str] | None = None,
    full_page: bool = True,
    wait_ms: int = 2000,
) -> list[Path]:
    """Take screenshots of a URL at different viewport sizes.

    Args:
        url: URL to screenshot (localhost or live).
        output_dir: Directory to save screenshots.
        viewports: List of viewport names ("desktop", "tablet", "mobile").
        full_page: Capture full scrollable page.
        wait_ms: Wait time for page to settle (ms).

    Returns:
        List of screenshot file paths.
    """
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("Playwright not installed. Run:")
        print("  uv pip install playwright && playwright install chromium")
        sys.exit(1)

    if viewports is None:
        viewports = ["desktop", "mobile"]

    output_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    paths = []

    # Clean URL for filename
    url_slug = url.replace("http://", "").replace("https://", "").replace("/", "_").replace(":", "-")
    if len(url_slug) > 60:
        url_slug = url_slug[:60]

    with sync_playwright() as p:
        browser = p.chromium.launch()

        for vp_name in viewports:
            vp = VIEWPORTS.get(vp_name, VIEWPORTS["desktop"])
            context = browser.new_context(
                viewport=vp,
                device_scale_factor=2,  # retina
                color_scheme="dark",    # match dark theme
            )
            page = context.new_page()

            try:
                page.goto(url, wait_until="networkidle", timeout=15000)
                page.wait_for_timeout(wait_ms)

                filename = f"{timestamp}_{url_slug}_{vp_name}.png"
                filepath = output_dir / filename
                page.screenshot(path=str(filepath), full_page=full_page)
                paths.append(filepath)
                print(f"  [{vp_name}] {filepath}")
            except Exception as e:
                print(f"  [{vp_name}] ERROR: {e}")
            finally:
                context.close()

        browser.close()

    return paths


def check_pdf(pdf_path: str) -> None:
    """Delegate PDF checking to econai visual_check if available."""
    econai_check = Path.home() / "econai" / "src" / "python" / "latex" / "visual_check.py"

    if econai_check.exists():
        print(f"Using econai visual_check for: {pdf_path}")
        subprocess.run(
            ["uv", "run", "python", "-c",
             f"from pathlib import Path; "
             f"sys.path.insert(0, '{econai_check.parent}'); "
             f"from visual_check import visual_check; "
             f"result = visual_check(Path('{pdf_path}')); "
             f"print(result)"],
            check=False,
        )
    else:
        print(f"econai visual_check not found at {econai_check}")
        print("Install pdf2image for PDF inspection: uv pip install pdf2image")


def main():
    parser = argparse.ArgumentParser(description="Visual Check Tool")
    parser.add_argument("target", help="URL or PDF path to check")
    parser.add_argument("--width", type=int, help="Custom viewport width")
    parser.add_argument("--height", type=int, help="Custom viewport height")
    parser.add_argument("--viewports", nargs="+", default=None,
                        choices=["desktop", "tablet", "mobile"],
                        help="Viewport sizes to capture")
    parser.add_argument("--output", type=str, default=None,
                        help="Output directory for screenshots")
    parser.add_argument("--no-full-page", action="store_true",
                        help="Only capture visible viewport, not full page")
    parser.add_argument("--wait", type=int, default=2000,
                        help="Wait time in ms for page to settle")
    parser.add_argument("--light", action="store_true",
                        help="Use light color scheme instead of dark")

    args = parser.parse_args()
    target = args.target

    # PDF check
    if target.endswith(".pdf"):
        check_pdf(target)
        return

    # URL check
    output_dir = Path(args.output) if args.output else SCREENSHOT_DIR
    viewports = args.viewports

    # Custom viewport
    if args.width and args.height:
        VIEWPORTS["custom"] = {"width": args.width, "height": args.height}
        viewports = ["custom"]

    print(f"Capturing: {target}")
    paths = screenshot_url(
        target,
        output_dir,
        viewports=viewports,
        full_page=not args.no_full_page,
        wait_ms=args.wait,
    )

    if paths:
        print(f"\n{len(paths)} screenshot(s) saved to {output_dir}")
        print("View with: open " + " ".join(str(p) for p in paths))
    else:
        print("No screenshots captured.")


if __name__ == "__main__":
    main()
