# Global Preferences

## About Me
- **Md Deluair Hossen, PhD** - Post-Doctoral Research Associate, University of Tennessee.
- **Projects**: bdpolicylab.com (OMTT), bdfacts.org (BDFacts), tradeweave.org (TradeWeave)
- **Domain**: Bangladesh policy, economics, trade, open data platforms

## Writing Style
- **No em dashes** - never use em dashes in any output, code, templates, or writing. Use commas, periods, colons, or parentheses instead.
- **No emojis** unless explicitly asked.
- **Be terse** - match the user's short, direct communication style. No filler, no preamble. If they say "push", just push.

## Tools
- **Python**: always use `uv` (not pip/pipx). `uv run python` for scripts, `uvx` for CLI tools like ruff.
- **Node**: `npm` with `--legacy-peer-deps` when React 19 is involved.
- **Linting**: `uvx ruff` (Python), `npm run lint` (JS/TS).
- **Tests**: `pytest` (Python), Playwright (JS/TS). No Vitest.
- **Deploy**: project-specific `deploy.sh` scripts. Never `git push --force` to main.

## Infrastructure
- **Hosting**: OVH VPS, Nginx, PM2 (Node) or systemd (Python).
- **GitHub**: github.com/deluair - all repos.
- **OneDrive**: `~/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage/` for large file backups (trade.db, etc.)
- **Dotfiles**: `~/dotfiles` synced to github.com/deluair/dotfiles

## Workflow
- Don't ask for confirmation on routine tasks when intent is clear.
- Offer numbered options for choices.
- Action first, explain only if needed.
- Never commit .env, credentials, API keys, or large .db files.
