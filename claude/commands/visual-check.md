# Visual Check

Take screenshots of a URL or inspect a PDF for rendering issues.

## For URLs
```bash
uv run python ~/scripts/visual-check/check_url.py <url> [options]
```

Options:
- `--viewports desktop mobile tablet` - which viewports to capture (default: desktop mobile)
- `--width 375 --height 812` - custom viewport
- `--light` - use light color scheme
- `--wait 3000` - wait longer for page to settle (ms)
- `--output /path/to/dir` - custom output directory

Examples:
```bash
# Check narrative page on desktop + mobile
uv run python ~/scripts/visual-check/check_url.py http://localhost:5173/narratives/npl-banking-crisis

# Check all viewports
uv run python ~/scripts/visual-check/check_url.py http://localhost:5173 --viewports desktop tablet mobile

# Check live site
uv run python ~/scripts/visual-check/check_url.py https://bdfacts.org/narratives
```

## For PDFs
```bash
uv run python ~/scripts/visual-check/check_url.py paper.pdf
```
Delegates to econai visual_check for margin overflow, empty page, and formatting detection.

## After Capturing
Screenshots are saved to `/tmp/visual-checks/`. Open with:
```bash
open /tmp/visual-checks/
```

Look for:
- Blank chart areas (data not loaded)
- Text overflow on mobile
- Missing images or icons
- Layout breaks at tablet/mobile widths
- Stale content (wrong dates, old data)
