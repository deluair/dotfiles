# Global Lessons

Cross-project patterns and gotchas learned from past sessions.

## Deployment
- `npm ci` fails on VPS when lockfile was generated on Windows. Use `npm install --force` instead.
- After replacing a `.db` file on VPS, always remove stale WAL/SHM files: `rm -f *.db-wal *.db-shm`.

## Dependencies
- React 19 projects need `--legacy-peer-deps` with npm.

## Data
- Always use real data, never mock or hallucinated data unless explicitly asked.

## Subagent Token Limits
- Subagents hit CLAUDE_CODE_MAX_OUTPUT_TOKENS (32K) when generating large Bengali/multilingual text (>5K words).
- For large content generation: instruct agents to use Python/Bash to write files instead of the Write tool. Build JSON incrementally in code, not as raw text output.
- Split chapters >6K words into multiple Python write calls or temp files that get merged.

## Large Document Rewriting
- AI-polished "summaries" lose 50-80% of content. Always compare word counts between original and output.
- When rewriting a book/manuscript: extract raw text per chapter first, count words, then verify output word counts match or exceed originals.
- Supplementary materials (letters, appendices, anecdotes) should be woven into relevant narrative chapters, not appended at the end, unless the user says otherwise.
- Kill conflicting agents immediately when strategy changes (e.g., switching from standalone appendix to integrated content).

## Bengali/Multilingual Processing
- Windows cp1252 codec fails on Bengali stdout. Always set `sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')`.
- Bengali filenames in paths: some CLI tools (pdftoppm) choke on encoded paths. Use PyMuPDF (fitz) instead.
- OneDrive paths with spaces and Unicode: always quote paths in shell, use raw strings in Python.
- Font installation on Windows: copy to `AppData/Local/Microsoft/Windows/Fonts/` and register via `HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts`.
