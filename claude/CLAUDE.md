# Global Preferences

## About Me
- Md Deluair Hossen, PhD, Post-Doc, University of Tennessee
- Domain: BD policy, economics, trade, open data, genomics, geospatial, AI/ML
- Projects: bdpolicylab.com (OMTT), bdfacts.org (BDFacts), tradeweave.org (TradeWeave)
- GitHub: github.com/deluair
- Default language: Python

## Environment
- Current machine: read `~/.claude/.machine`, then `~/dotfiles/config.sh` for MACHINE_NAME
- Machines: macmini (M4, 256GB), macair (M4, 256GB), galaxy (Snapdragon, 512GB), dell (32GB, 1TB)
- macmini/macair are 256GB: skip 18GB trade.db, warn before large ops
- Cross-platform: macOS, Windows (Git Bash), Linux. OS detection via `~/dotfiles/paths.sh`
- Machine config in `~/dotfiles/config.sh` (gitignored). Never hardcode usernames/IPs/paths in committed files

## Style
- No em/en dashes. Use commas, periods, colons, parentheses
- No emojis unless asked
- Terse. No filler, no preamble, no narrating obvious steps

## Do NOT
- Refactor untouched code, add types/docstrings/comments to unchanged code
- Write tests unless asked
- Add error handling for impossible cases
- Create README/docs unless asked
- Add features beyond request
- Over-abstract (3 similar lines > premature helper)
- Use mock/fake data
- When fixing a bug, fix ONLY the reported issue

## Tools
- Python: `uv` (not pip). `uv run python`, `uvx` for CLI tools
- Node: `npm`, `--legacy-peer-deps` with React 19
- Lint: `uvx ruff check/format` (Python), `npm run lint` (JS/TS)
- Tests: `pytest` (Python), Playwright (JS/TS). No Vitest/Jest
- Deploy: project `deploy.sh` scripts

## New Project Defaults
- Python web: FastAPI + SQLite. Not Flask/Django
- Frontend: Next.js or Vite+React. Tailwind. No CSS-in-JS
- Viz: Plotly (Python), Recharts/D3 (JS/TS)
- DB: SQLite default, PostgreSQL only when needed
- Styling: clean, minimal, professional

## Git
- Commits: imperative, lowercase, concise
- Branches: `feature/`, `fix/`, `data/` + short description
- Never force-push main/master
- Never commit .env, credentials, keys, large .db files
- PR titles: short, under 70 chars

## Data
- Large datasets: never load all into memory without size check
- Stream CSVs over 100MB
- SQLite with WAL mode. Clean stale WAL/SHM on .db replacement
- Project-relative paths only. Backups to OneDrive (`$ONEDRIVE` from paths.sh)

## Infra
- OVH VPS, Ubuntu, Nginx. PM2 (Node) / systemd (Python). Cloudflare DNS/SSL
- Dotfiles: `~/dotfiles` synced to GitHub
- VPS trade.db (19GB) is IMMUTABLE (`chmod 444` + `chattr +i`). Never modify, delete, or replace without explicit permission. To unlock: `sudo chattr -i`, then re-lock after
- VPS trade.db backup: Google Drive root (`trade.db`), not OneDrive. Restore via rclone on VPS

## Deploy
- VPS: `npm install` not `npm ci`. Remove WAL/SHM before/after DB ops
- Verify SSH before transfers. Build locally first. Health-check after deploy

## Errors
- Build fail: read error, fix root cause
- Deploy fail: check SSH, then logs (pm2/journalctl), then fix
- Test fail: fix code not test (unless test is wrong)
- Dep conflict: resolve explicitly, no `--force` first
- Stuck after 2 attempts: stop and ask

## Workflow (ACE)
- Plan mode for 3+ step tasks. Re-plan if things go wrong
- No confirmation needed on routine tasks with clear intent
- Numbered options for choices. Action first, explain if needed
- Subagents for research/parallel work. One task per agent. Max 15 parallel
- After correction: update `tasks/lessons.md`
- Never mark complete without verification. Build/test after every change
- After refactors: grep removed/renamed refs before building
- Simplicity first. Root causes only. Minimal impact

## Per-Project
- Project `CLAUDE.md` overrides global where conflicting
