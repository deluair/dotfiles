---
name: bg_book_project
description: Bengali memoir book project, build pipeline, chapter structure, and AI rewrite workflow
type: project
---

# তারেক রহমানের সাথে কারাবাস (Book Project)

## What
Bengali memoir by Kabir (common prisoner) about serving as attendant to Tarek Rahman (son of former PM Khaleda Zia) in Dhaka Central Jail during 2007-2009 (1/11 military-backed government).

## Location
C:\Users\mhossen\OneDrive - University of Tennessee\misc_2026\bg_book

## Structure
- `original/` - source manuscript (.docx, 1913 paragraphs, ~43,600 words)
- `ai_cache/` - AI-polished chapter JSONs (segment tuples: NARRATION/DIALOGUE/BREAK)
- `scripts/make_proper_book.py` - main build pipeline (JSON cache -> DOCX+PDF)
- `scripts/raw_to_cache.py` - converts raw manuscript extracts to cache format
- `scripts/merge_parts.py` - combines split chapter parts into single files
- `data/raw_chapters/` - extracted per-chapter text from original docx
- `data/letter_groups/` - letters grouped by target chapter for integration
- `output/` - final DOCX and PDF

## Chapter mapping (CHAPTER_DEFS in make_proper_book.py)
- ch0: ভূমিকা (intro)
- ch1-ch8: main narrative chapters
- Letters, anecdotes, krishi: woven INTO relevant chapters (not standalone)

## Key decisions
- Font: Noto Serif Bengali, 12pt, 1.45x line spacing
- Royal size 6x9, mirror margins, 2.5cm inner for binding
- All supplementary materials (letters, anecdotes, agriculture) integrated into narrative chapters, not appended
- Original manuscript paragraph ranges defined in RANGES dict in create_book.py

## AI rewrite workflow
- Large chapters (>5K words) must be SPLIT into parts (~2.5-3K words each) before sending to subagents
- Subagents must use Write tool (not Bash heredocs) to write JSON, avoids shell quoting issues with Bengali text
- Parts merged back via merge_parts.py
- Target: 120%+ of original word count per chapter

## Current status (2026-03-11)
- All 9 chapters (ch0-ch8) AI-rewritten and built: 284 pages, ~44,898 words
- PDF visually checked, formatting verified, publish-ready
- GitHub: github.com/deluair/bg-book (private)
- PENDING: Letters partially integrated but not all. Photo references (ছবি ০১-৪ে+) exist as text markers only, actual scanned letter images NOT embedded in PDF. Need to extract images from original .docx and audit which letters are missing.
- PENDING: Anecdotes (data/raw_chapters/anec.json) may not be fully integrated into narrative chapters.
