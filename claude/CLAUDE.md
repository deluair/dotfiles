# Global Preferences

## About Me
- Md Deluair Hossen, PhD, Post-Doc, University of Tennessee
- Domain: BD policy, economics, trade, open data, genomics, geospatial, AI/ML
- GitHub: github.com/deluair
- Default language: Python

## Projects (4 repos, 3 public platforms + 1 private life OS)

### BDPolicyLab (bdpolicylab.com) -- ~/bdpolicylab
- **What**: Solo AI-augmented policy think tank for Bangladesh (OMTT)
- **Stack**: FastAPI + aiosqlite + Jinja2, Python 3.11, uv
- **DB**: bdpolicy.db (aiosqlite, async), govtwin.db (government digital twin)
- **Key modules**:
  - 18 analyzer modules (banking, climate, education, fiscal, etc.)
  - 32 data collectors (BB, FRED, WB, IMF, ILO, HDX, etc.)
  - 17 publication generators (policy briefs)
  - Narrative engine (Pueyo-style long-form, YAML frontmatter + chart directives)
  - EconAI toolkit (47 files): 12 estimators (OLS, IV, DiD, RDD, Double ML, Causal Forest, etc.), figures, tables, research gap finder, literature search
  - GovTwin: 5-layer government digital twin (263 entities, 35 relationships, Claude brain with 6 tools, counterfactual simulation, peer country benchmarking)
  - Stories engine (AI data stories)
- **CLI**: `python -m app.cli` (serve, generate-*, collect-*, narrative-*, govtwin)
- **Deploy**: systemd, port 8001, rsync to VPS
- **Tests**: 158 tests, pytest-asyncio

### BDFacts (bdfacts.org) -- ~/bdfacts
- **What**: Bangladesh open data education platform (free public good, no ads/login)
- **Stack**: React 19 + Vite 7 SPA, FastAPI backend, bilingual (Bangla-first)
- **DB**: analytics.db, wdi.db (57MB WDI), bangladesh.db (symlink to OneDrive), baci.db (215MB trade)
- **Key modules**:
  - 69 lazy-loaded routes, 48 page components
  - 40 life simulators (salary, education, family, fiscal impact)
  - 41 sector projections (growth, fiscal, poverty, HDI, ARIMA, OLS)
  - 9 economic models (Solow, Harrod-Domar, Phillips, Taylor, ERPT, fiscal multiplier)
  - 100 data narratives (25 story series)
  - PWA with Workbox (292 precache entries)
- **CLI**: npm scripts (dev, build, test)
- **Deploy**: rsync dist/ + backend to VPS, systemd (bddata-backend), Nginx
- **Tests**: Playwright E2E (33 routes + 10 journeys)

### TradeWeave (tradeweave.org) -- ~/tradeweave
- **What**: International trade analytics platform
- **Stack**: Next.js 16 + React 19 + TypeScript (strict), Tailwind v4, D3.js v7, Deck.gl v9
- **DB**: trade.db (19GB, read-only, IMMUTABLE on VPS), app.db (writable), imf.db (627MB, read-only)
- **Key modules**:
  - 52 pages, 135 API routes, 15 D3/Deck.gl visualizations
  - Live vessel AIS + cargo flight tracking (3D globe)
  - Product space (Hausmann-Hidalgo), gravity model, tariff simulation
  - ECI/PCI rankings, RCA analysis, supply chain mapping
  - Commodities (71 Pink Sheet prices, FAOSTAT food security)
  - 200-year historical trade flows, Sankey diagrams
  - 10 Python data ingest scripts (BACI, Gravity, CHELEM, FAOSTAT, etc.)
  - AI weekly intelligence briefings
- **Data conventions**: BACI in thousands USD, PCI zero-centered (never filter negatives), RCA dimensionless, ISO3 uppercase
- **Deploy**: pm2, rsync to VPS, chmod 444 trade.db + imf.db post-deploy
- **Tests**: npm run lint

### DulalRatna (private) -- ~/dulalratna
- **What**: Personal life OS (health, finance, career, family, discipline, AI assistant)
- **Stack**: FastAPI + SQLite (WAL) + vanilla JS SPA, Python 3.11, uv
- **DB**: me.db (schema v5, 30+ tables, append-only, FTS5 memories)
- **Key modules**:
  - AI brain: GLM-4.7 via z.ai, NanoClaw v3 agentic loop, 28 tools, 12 rounds
  - Analytics engine: trends, anomaly detection (z-score + IQR), Holt's forecasting, cross-domain correlations
  - Config system: centralized thresholds, tax brackets, rates
  - Projections: Monte Carlo retirement/house/NC move, Framingham CVD, prediabetes
  - Alerts: health, finance, goals, documents, TTL cleanup
  - Discipline: wins/slips/streaks, heartbeat (morning briefing, evening check-in)
  - Telegram bot: 14 commands + free-form NLP + proactive heartbeat
  - Ingestion: CDA XML health, bank CSV, Apple Health, Amazon orders, Taptap remittance
  - 12-tab dashboard (overview, health, finance, projections, risk, goals, timeline, monte carlo, AI, jobs, discipline, analytics)
- **CLI**: `uv run python run_me.py`
- **Deploy**: systemd, port 8050
- **Repo**: PRIVATE (github.com/deluair/dulalratna)

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
- ALL work happens locally. VPS only receives finished, tested code via deploy.sh
- NEVER run generators, collectors, or any data-modifying commands on VPS via SSH
- NEVER touch, delete, replace, or modify database files on VPS. Ask first
- VPS is a dumb server: receives code, installs deps, restarts service. That is all
- If deploy health-check fails, check logs (journalctl), fix code LOCALLY, redeploy
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
