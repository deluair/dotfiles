# Global Preferences

## About Me
- Md Deluair Hossen, PhD, Post-Doc, University of Tennessee
- Domain: BD policy, economics, trade, open data, genomics, geospatial, AI/ML
- GitHub: github.com/deluair
- Default language: Python

## Projects (4 repos, 3 public platforms + 1 private life OS)

All 4 share one OVH VPS (vps-45aafae5.vps.ovh.us, ubuntu@40.160.2.223). All use SQLite. All have deploy.sh scripts. Never confuse or mislabel them.

### BDPolicyLab (bdpolicylab.com) -- ~/bdpolicylab
- **What**: Solo AI-augmented policy think tank for Bangladesh. Called "OMTT" (One Man Think Tank) internally. This is a policy project that uses technology, not a tech project.
- **Stack**: FastAPI + aiosqlite + Jinja2 templates, Python 3.11, uv
- **DB**: bdpolicy.db (aiosqlite, async, key tables: data_series, data_points, publications, collection_log), govtwin.db (government digital twin)
- **Async everywhere**: all DB ops, collectors, analyzers, generators are async
- **Key modules**:
  - 58 analyzer modules (banking, climate, education, fiscal, energy, agriculture, etc.)
  - 37 data collectors (BB, FRED, WB, IMF, ILO, HDX x5, FAO, EIA, BLS, NOAA, Comtrade, etc.)
  - 73 publication generators (policy briefs, use assemble_html() from base.py, register in registry.py)
  - Narrative engine (Pueyo-style long-form, YAML frontmatter + {{chart:name}} directives, Plotly charts)
  - EconAI toolkit (app/econai/, 47 files, 13.5K lines): 12 estimators (OLS, IV, Panel FE, DiD, RDD, Double ML, Causal Forest, Synthetic DiD, Staggered DiD, Shift-Share, Bounds, Randomization Inference), figures (binscatter, coefficient, event study), tables (regression, balance, summary stats), research gap finder (6 modules), literature search (OpenAlex, Semantic Scholar, BibTeX)
  - GovTwin (app/govtwin/): 5-layer government digital twin (263 entities, 35 relationship types, 50 policy domains, 100 legal frameworks, 20 committees). Claude Sonnet 4 brain with 6 tools, counterfactual simulation (merge/dissolve/split/transfer), 5 peer countries (Vietnam, India, Sri Lanka, Malaysia, Philippines), 225 comparative metrics. Schema v5, 20+ tables.
  - Stories engine (AI data stories via Anthropic)
  - Forecasting engine (time-series)
  - Charts (embeddable SVG/PNG/HTML)
- **CLI**: `python -m app.cli` (serve, generate-pulse, generate-all, collect-all, collect bb, narrative-list, narrative-build, narrative-build-all, govtwin seed/scrape/bridge/query/stats/tree/simulate, status)
- **API gotchas**: IMF uses DataMapper API (NOT SDMX), ILO uses SDMX-JSON 2.0, FAO uses local bulk zips (Area Code 16 = Bangladesh), Plotly 6 add_vline with annotation_text + string x-axis broken (use add_shape + add_annotation)
- **Deploy**: systemd (bdpolicylab), port 8001, rsync to VPS (excludes data/), health check /api/health
- **Tests**: 499 tests, pytest-asyncio (asyncio_mode=auto), skip test_collectors.py::test_scheduler_config
- **Env**: FRED_API_KEY, COMTRADE_API_KEY, ANTHROPIC_API_KEY, GEMINI_API_KEY, EIA_API_KEY, BLS_API_KEY, NOAA_TOKEN, ADMIN_KEY, DATABASE_PATH

### BDFacts (bdfacts.org) -- ~/bdfacts
- **What**: Bangladesh open data education platform. Free public good: no ads, no login, no paywall. Bilingual (Bangla-first).
- **Stack**: React 19 + Vite 7 SPA (frontend), FastAPI + SQLite (backend). --legacy-peer-deps always (React 19). Recharts 3, Leaflet, Framer Motion.
- **DB**: analytics.db (sessions/events/feedback), wdi.db (57MB World Bank WDI), bangladesh.db (symlink to OneDrive), baci.db (215MB trade)
- **Routes**: src/config/routes.js is single source of truth. routeMeta.js for bilingual SEO.
- **Key modules**:
  - 81 lazy-loaded routes, 57 page components, 15 model pages, 10 game pages
  - 40 life simulators (src/components/simulators/, preloaded via requestIdleCallback)
  - 5 sector simulations (agriculture, climate, trade, energy, health)
  - 9 economic models (Solow, Harrod-Domar, Phillips, Taylor, ERPT, fiscal multiplier, poverty-growth, HDI, budget sustainability)
  - 400 data narratives in 25 story series (src/data/narrativeData.js, migrated from OMTT)
  - PWA with Workbox (292 precache entries, autoUpdate, installable)
  - 7 React contexts (Language, Theme, Analytics, LifeSim, Trails, Bookmarks, DataMode)
  - Backend: ~60 endpoints with SlowAPI rate limiting
- **Styling**: dark mode default, glassmorphism, CSS variables, Noto Sans Bengali + Sora + Manrope fonts
- **CLI**: npm run dev/build/lint/test/deploy, deploy.sh reads .env for VPS_HOST/VPS_USER
- **Deploy**: rsync dist/ to /var/www/bddata/dist/, rsync backend/, systemd (bddata-backend), Nginx, health check /api/health. index.html no-cache, /assets/ immutable 1yr.
- **Tests**: Playwright E2E only (NOT Vitest/Jest). smoke.routes.spec.js (33 routes), e2e.journeys.spec.js (10 flows). Config: 45s timeout, Chromium, 127.0.0.1:4173
- **Bundle budgets**: React 240KB, Charts 450KB, total JS 2.7MB max (enforced in CI)
- **Gotchas**: react-is must be installed explicitly (recharts dep). Vite proxies /api to production in dev. Bengali numerals need toBnAscii() conversion.

### TradeWeave (tradeweave.org) -- ~/tradeweave
- **What**: International trade analytics platform. 238 countries, 5,022 HS6 products, 30 years BACI data (1995-2024), 200+ years historical.
- **Stack**: Next.js 16 (App Router) + React 19 + TypeScript (strict), Tailwind v4, D3.js v7 (12 components), Deck.gl v9 + MapLibre (3 components), better-sqlite3
- **DB**: trade.db (19GB, read-only, WAL mode, 64MB cache, 4GB mmap, IMMUTABLE on VPS), app.db (writable, auto-created), imf.db (627MB, read-only, 32MB cache, 1GB mmap). Local: data/. VPS: /opt/tradeweave/data (DATA_DIR env).
- **All pages 'use client' except layout.tsx.** useSearchParams() requires Suspense wrapper.
- **Key modules**:
  - 64 pages, 150 API routes, 16 D3/Deck.gl visualizations (Treemap, BarChart, LineChart, ScatterPlot, StackedArea, GeoMap, AnimatedGeoMap, ProductSpace, Sankey, TradeNetwork, GravityScatter, RadarChart, ResidualMap, TradeFlowMap, TradeGlobe, SankeyChart)
  - Live vessel AIS + cargo flight tracking (3D Deck.gl globe, OpenSky + Digitraffic + Barentswatch)
  - Product space (Hausmann-Hidalgo), gravity model, tariff simulation, ML forecasting, trade costs
  - ECI/PCI rankings, RCA analysis, supply chain mapping, structural change
  - Commodities (71 Pink Sheet prices, FAOSTAT food security, agricultural trade)
  - 200-year historical trade flows (TRADHIST), Sankey diagrams
  - 10 Python data ingest scripts (BACI, Gravity, CHELEM, TUV, TRADHIST, FAOSTAT, Pink Sheet, WDI, ESCAP, tariffs)
  - 5,400+ sitemap URLs, /llms.txt for AI crawlers, JSON-LD structured data
- **Data conventions (CRITICAL)**: BACI/FAOSTAT values in thousands USD (multiply by 1000 for display). PCI is zero-centered, routinely negative (NEVER filter negatives). RCA is dimensionless (no currency formatting). ISO3 always UPPERCASE before DB queries.
- **Styling**: light-only theme, CSS custom properties for ALL colors (--accent-primary: #0891b2 cyan, --accent-secondary: #d97706 amber), glass-card pattern, no emojis in UI
- **API pattern**: params is Promise (always await in Next.js 16), Cache-Control: public max-age=3600 s-maxage=86400, getDb() for trade.db, getAppDb() for app.db
- **Deploy**: pm2, rsync to VPS, npm install (not npm ci). chmod 444 trade.db + imf.db post-deploy. Clean WAL/SHM before syncing. CI: deploy.yml on push to main.
- **VPS**: ubuntu@40.160.2.223, /opt/tradeweave/app, pm2 + Nginx
- **Env**: EIA_API, NOAA_TOKEN, COMTRADE_KEY, FRED_API_KEY, BLS_API, CENSUS_DATA_API, DATA_DIR

### DulalRatna (private) -- ~/dulalratna
- **What**: Personal life OS. Health, finance, career, family, discipline, AI assistant. SQLite-backed, queryable, self-updating.
- **Stack**: FastAPI + SQLite (WAL mode) + vanilla JS SPA (Chart.js), Python 3.11, uv
- **DB**: me.db (schema v5, 30+ tables, append-only ingestion, FTS5 for memories with Porter stemming). Key tables: lab_results, vitals, glucose, conditions, medications, net_worth_snapshots, monthly_expenses, remittances, goals, timeline_events, career, family, documents, bank_accounts, credit_cards, investment_accounts, amazon_orders, job_applications, discipline, streaks, reminders, memories, notification_log
- **sqlite3.Row convention**: use row["key"] or default, NOT row.get("key", default) (Row has no .get)
- **Key modules**:
  - AI brain (melib/ai/brain.py): GLM-4.7 via z.ai (Anthropic SDK), NanoClaw v3 agentic loop, 28 tools, 12 rounds, tool result validation, auto-context priming, FTS5 memory recall, correction learning
  - Analytics engine (melib/analytics.py): time-series trends (linear regression + R-squared), anomaly detection (z-score + IQR dual-method), forecasting (linear + Holt's), cross-domain Pearson correlations, discipline analytics
  - Config system (melib/config.py): all magic numbers centralized (tax brackets, thresholds, rates, ages), env overrides
  - Projections: Monte Carlo (retirement 10k sims, NC move 5k, house 5k), sensitivity analysis, Framingham CVD risk, prediabetes risk (Ratna), TSH trend analysis
  - Alerts (melib/alerts.py): health, finance, goals, documents, Amazon spending, notification TTL cleanup, alert statistics
  - Discipline (melib/discipline.py): wins/slips/urges/reflections, streaks with best counts, soul-voice responses (Gopalpur, Lalon, ektara)
  - Heartbeat (melib/heartbeat.py): morning briefing (7 AM ET), evening check-in (9 PM ET), discipline summary, document warnings
  - Telegram bot (melib/telegram_bot.py): 14 commands (/start /health /finance /goals /jobs /apply /briefing /alerts /reflect /discipline /streak /ratna /chart /clear), free-form NLP via GLM, proactive heartbeat, auth via TELEGRAM_ALLOWED_USERS
  - Ingestion: CDA XML health, bank/CC CSV (auto-detect format), Apple Health (iterparse), Amazon orders, Taptap remittance, file watcher
  - Dashboard: 12 tabs (overview, health, finance, projections, risk, goals, timeline, monte carlo, AI, jobs, discipline, analytics), data entry forms
  - Server: FastAPI v4.0, 41 routes, port 8050, CORS enabled
- **Health conventions**: test_name (not test), flag (not flag_code), panel (not panel_name). Lab queries: use full LOINC names like "Cholesterol in LDL [Mass/volume]". Glucose columns: dulal and ratna per row.
- **CLI**: `uv run python run_me.py` (status, ingest), `uv run python server.py`, `uv run python run_telegram.py`
- **Deploy**: systemd, port 8050
- **Env**: ZAI_API_KEY, TELEGRAM_BOT_TOKEN, TELEGRAM_ALLOWED_USERS
- **Security**: identity/ gitignored (SSN-adjacent), me.db gitignored, repo PRIVATE
- **NOT interested in academic/tenure-track positions.** Job search = industry, policy, consulting, think tank.

## Shared VPS Details
- **Host**: OVH VPS vps-45aafae5.vps.ovh.us (ubuntu@40.160.2.223)
- **Services**: bdpolicylab (systemd, :8001), bddata-backend (systemd, :8000), tradeweave (pm2, :3000), dulalratna (systemd, :8050)
- **Nginx**: reverse proxy for all 4, Cloudflare DNS/SSL
- **Databases on VPS**: trade.db (19GB, IMMUTABLE chmod 444 + chattr +i), imf.db (627MB), bdpolicy.db, govtwin.db, analytics.db, app.db, me.db
- **trade.db backup**: Google Drive root (not OneDrive). Restore via rclone on VPS.

## Environment
- Current machine: read `~/.claude/.machine`, then `~/dotfiles/config.sh` for MACHINE_NAME
- Machines: macmini (M4, 256GB), macair (M4, 256GB), galaxy (Snapdragon, 512GB), dell (32GB, 1TB)
- macmini/macair are 256GB: skip 18GB trade.db, warn before large ops
- Cross-platform: macOS, Windows (Git Bash), Linux. OS detection via `~/dotfiles/paths.sh`
- Machine config in `~/dotfiles/config.sh` (gitignored). Never hardcode usernames/IPs/paths in committed files
- OneDrive folders contain cloud-only files. Never use `du`, `ls -la`, or any command that triggers downloads on OneDrive paths.

## Style
- No em/en dashes. Use commas, periods, colons, parentheses
- No emojis unless asked
- Terse. No filler, no preamble, no narrating obvious steps

## Do NOT
- Refactor untouched code, add types/docstrings/comments to unchanged code
- Write tests unless asked
- Add error handling for impossible cases
- Create README/docs unless asked
- Add features, pages, charts, or files beyond what was requested
- Over-abstract (3 similar lines > premature helper)
- Use mock/fake data. Every data point must come from a real, verifiable source
- When fixing a bug, fix ONLY the reported issue
- Build explorers, extra visualizations, or unnecessary modules speculatively

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

## Data Integrity (absolute, all projects)
- No mock data. No hallucinated numbers. No fabricated statistics or citations.
- If a data source is unavailable, say so rather than inventing values.
- No dark patterns, deceptive metrics, inflated engagement, or misleading visualizations.

## Deploy (all projects)
- ALL work happens locally. VPS only receives finished, tested code via deploy.sh
- NEVER run generators, collectors, or any data-modifying commands on VPS via SSH
- NEVER touch, delete, replace, or modify database files on VPS. Ask first
- VPS is a dumb server: receives code, installs deps, restarts service. That is all
- If deploy health-check fails, check logs (journalctl/pm2), fix code LOCALLY, redeploy
- VPS: `npm install` not `npm ci`. Remove WAL/SHM before/after DB ops
- Verify SSH before transfers. Build locally first. Health-check after deploy
- Always test locally before deploying

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
- Act immediately on clear requests. Do not over-explore or overthink before acting.

## Per-Project
- Project `CLAUDE.md` overrides global where conflicting
