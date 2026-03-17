# Global Preferences

## About Me
- **Md Deluair Hossen, PhD** - Post-Doctoral Research Associate, University of Tennessee.
- **Domain**: Bangladesh policy, economics, trade, open data platforms, genomics, geospatial analysis, AI/ML.
- **Projects**: bdpolicylab.com (OMTT), bdfacts.org (BDFacts), tradeweave.org (TradeWeave)
- **GitHub**: github.com/deluair
- **Primary language**: Python. Default to Python unless the project dictates otherwise.

## Environment
- **Primary OS**: Windows (Git Bash / MSYS2). Do not suggest Unix-only tools (ssh-copy-id, xdg-open, pbcopy) without checking availability first.
- **Cross-platform**: All scripts must work on macOS, Windows (Git Bash), and Linux. Use OS detection from `~/dotfiles/paths.sh`.
- **Machine config**: All machine-specific values live in `~/dotfiles/config.sh` (gitignored). Never hardcode usernames, IPs, or absolute paths in committed files.

## Writing Style
- **No em dashes or en dashes** in any output, code, templates, or writing. Use commas, periods, colons, or parentheses instead.
- **No emojis** unless explicitly asked.
- **Be terse**. Match my short, direct communication style. No filler, no preamble. If I say "push", just push.
- **No unsolicited commentary**. Don't explain what you're about to do, just do it. Don't narrate obvious steps.

## ABSOLUTE RULES (non-negotiable)
- **Local first, always.** Test every change locally before touching VPS. Run imports, run tests, verify output. Only then deploy. One combined SSH command for deploy (rsync + install + generate + restart). Never retry blindly on VPS. If VPS fails, come back to local.
- **Smart time.** Do the work, verify once. No polling loops. No redundant testing. No asking "want me to do X?" when the answer is obvious. Combine commands. If something fails, diagnose the root cause, don't retry the same command. If the user says "go on", execute.
- **Never get stuck.** If a command hangs, kill it and try a different approach. If VPS is unresponsive, move on to other work. If a tool is blocked, use a different tool. If an approach isn't working after 2 attempts, stop, explain what's wrong, and ask for direction. Never sit in a polling loop. Never wait for something that might not come.

- **Session bookends.** When I say "start": run `make -C ~/dotfiles pull`. When I say "end": run `make -C ~/dotfiles push`. No questions, just do it.

## Do NOT
- Refactor code I didn't ask you to touch.
- Add type annotations, docstrings, or comments to code you didn't change.
- Suggest or write tests unless asked.
- Add error handling for impossible scenarios or wrap internal code in try/catch "just in case".
- Create README, docs, or markdown files unless asked.
- Add features beyond what was requested. No "while we're at it" improvements.
- Over-abstract. Three similar lines > a premature helper function.
- Use mock, fake, or hallucinated data. Always use real data unless I explicitly say otherwise.
- When fixing a reported bug, fix ONLY the reported issue. No unsolicited visual improvements, polish, or design changes.

## Tools
- **Python**: always use `uv` (not pip/pipx). `uv run python` for scripts, `uvx` for CLI tools like ruff.
- **Node**: `npm` with `--legacy-peer-deps` when React 19 is involved.
- **Linting**: `uvx ruff check` and `uvx ruff format` (Python), `npm run lint` (JS/TS).
- **Tests**: `pytest` (Python), Playwright (JS/TS). No Vitest, no Jest.
- **Deploy**: project-specific `deploy.sh` scripts.

## Defaults for New Projects
- **Python web**: FastAPI + SQLite (via better-sqlite3 or aiosqlite). Not Flask, not Django.
- **Frontend**: Next.js or Vite + React. Tailwind CSS. No CSS-in-JS.
- **Data viz**: Plotly (Python), Recharts or D3 (JS/TS).
- **Database**: SQLite for most things. PostgreSQL only when SQLite won't scale.
- **Styling**: Clean, minimal, professional. No rounded-everything, no gradients, no card-heavy layouts unless appropriate.

## Git Conventions
- **Commit messages**: imperative mood, lowercase, concise. e.g., "add trade flow endpoint", "fix date parsing in importer".
- **Branch naming**: `feature/short-description`, `fix/short-description`, `data/short-description`.
- **Never** `git push --force` to main or master.
- **Never** commit `.env`, credentials, API keys, or large `.db` files.
- **PR titles**: short, descriptive, under 70 chars.

## Data Handling
- Trade/economics datasets are often large (GBs). Never load entire datasets into memory without checking size first.
- Prefer streaming/chunked processing for CSVs over 100MB.
- SQLite is the default data store. Use WAL mode for concurrent reads.
- When replacing `.db` files, always clean up stale WAL/SHM files.
- Data file paths: use project-relative paths, never hardcode absolute paths in code.
- For data backups, use OneDrive (`$ONEDRIVE` from `~/dotfiles/paths.sh`).

## Infrastructure
- **Hosting**: OVH VPS, Ubuntu, Nginx reverse proxy.
- **Process management**: PM2 (Node apps) or systemd (Python services).
- **DNS/SSL**: Cloudflare.
- **Dotfiles**: `~/dotfiles` synced to GitHub.

## Deployment
- **Always** use `npm install` on VPS, not `npm ci` (cross-platform lockfile incompatibility).
- **Always** remove stale WAL/SHM files before and after DB file operations on VPS.
- **Always** verify SSH connectivity before starting file transfers.
- **Pre-deploy**: Run full local build first. Never deploy unbuildable code.
- **Post-deploy**: Hit at least one health endpoint to confirm the service is alive.

## Error Handling Rules
- **Build fails**: Read the error, fix the root cause. Don't retry blindly.
- **Deploy fails**: Check VPS connectivity first, then logs (`pm2 logs` or `journalctl`), then fix.
- **Test fails**: Fix the code, not the test (unless the test is genuinely wrong).
- **Dependency conflict**: Identify the conflicting versions, resolve explicitly. Don't use `--force` as first resort.
- **If stuck after 2 attempts**: Stop, explain what you tried, ask me for direction.

## Workflow Orchestration (ACE)

### Planning
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions).
- If something goes sideways, STOP and re-plan immediately.
- Write detailed specs upfront to reduce ambiguity.

### Execution
- Don't ask for confirmation on routine tasks when intent is clear.
- Offer numbered options for choices.
- Action first, explain only if needed.
- Offload research and parallel work to subagents, keep main context clean.
- One task per subagent for focused execution.
- **Max 10 parallel agents per batch**. For larger tasks, run in waves of 10, collecting results to /tmp between waves.

### Self-Improvement
- After ANY correction: update project `tasks/lessons.md` with the pattern.
- Write rules that prevent the same mistake.
- Review lessons at session start.

### Verification
- Never mark a task complete without proving it works.
- Run the project's build/test command after every change set.
- After multi-file refactors or route rewrites: grep for all references to removed/renamed variables and fix before building.
- Ask: "Would a staff engineer approve this?"

### Standards
- **Simplicity First**: Make every change as simple as possible.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes touch only what is necessary.

## Per-Project Instructions
- Each project may have its own `CLAUDE.md` at the repo root with project-specific rules.
- Project-level instructions override global ones where they conflict.
- If a project has no `CLAUDE.md`, these global rules apply fully.
