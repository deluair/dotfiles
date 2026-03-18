# Memory

## User Info

- **GitHub username**: `$GITHUB_USER` (from `~/dotfiles/config.sh`)

## Workflow Preferences

- **Local-first**: See [feedback_local_first_always.md](feedback_local_first_always.md). NEVER edit files on VPS directly. All changes local, test local, then deploy.
- **Machineless setup**: See [machineless_setup.md](machineless_setup.md) for full details. All 6 projects: git-secret + OneDrive + Makefile + pre-commit hooks. `git clone` + `make setup` = running.
- **New machine bootstrap**: See [new_machine_bootstrap.md](new_machine_bootstrap.md) for step-by-step: dotfiles first, then projects, then push dotfiles after sessions.
- **GPG key**: `$GPG_EMAIL` (from `~/dotfiles/config.sh`). Backed up to OneDrive `gpg_backup/`.
- **No git-lfs**: Decided against it. OneDrive is free via UTK, not worth $5/mo for LFS.
- **"start" = pull + setup**: See [feedback_start_means_pull_and_make.md](feedback_start_means_pull_and_make.md). Git pull all repos, then run make setup for each.
- **Always subagent-driven**: See [feedback_always_subagent_driven.md](feedback_always_subagent_driven.md). Never ask, always use option 1 (subagent-driven) for plan execution.
- **All BD data to datahouse**: See [feedback_all_bd_data_to_datahouse.md](feedback_all_bd_data_to_datahouse.md). All Bangladesh data must be ingested into bdpolicy.db, never left as raw files only.

## OneDrive Data Backup Map

Base path: `$ONEDRIVE` (resolved per-platform by `~/dotfiles/paths.sh`)

| Project | Gitignored Data | OneDrive Location | Notes |
|---------|----------------|-------------------|-------|
| **OMTT** | `data/bdpolicy.db` (41MB) | `db_backups/omtt_bdpolicy_latest.db` | Also timestamped copies |
| **OMTT** | `data/bangladesh.db` (43MB) | `db_backups/omtt_bangladesh_latest.db` | Copy of BDFacts DB for OMTT use |
| **OMTT** | `data/trade/` (3.9GB) | `omtt_trade_data/trade/` | CSV, parquet, xlsx research data |
| **OMTT** | `data/baci.db` (215MB) | `db_backups/omtt_baci_latest.db` | BD trade flows 1995-2024, HS92, 1.9M rows |
| **OMTT** | `data/` (raw source files) | `omtt_raw_data/data/` | CSVs, geo, hdx, fao, bbs, etc. (was `bd_policy/`) |
| **BACI** | All 7 HS revision zips + xlsx | `trade_backup/baci_zips/` | HS92/96/02/07/12/17/22 + HSCodeandDescription.xlsx |
| **OMTT** | `data/trade_flagship_results.json` | `omtt_trade_data/trade_flagship_results.json` | |
| **BDFacts** | `backend/data/bangladesh.db` (43MB) | `db_backups/bddb_latest.sqlite` | Also timestamped copies |
| **BDFacts** | `backend/analytics.db` (1.2MB) | `db_backups/bddb_latest.sqlite` | Bundled in same backup |
| **BDFacts** | `backend/wdi.db` (56KB) | `db_backups/bddb_latest.sqlite` | Bundled in same backup |
| **TradeWeave** | `trade.db` (18GB+) | `db_backups/trade.db` | The big one |
| **TradeWeave** | app db | `db_backups/tradeweave_app_latest.db` | |
| **DulalRatna** | `me.db` (560KB) | `db_backups/dulalratna_me_latest.db` | Personal health/finance DB |
| **DulalRatna** | `identity/` (PII) | `dulalratna_sensitive/identity/` | Immigration docs, SSN-adjacent |
| **DulalRatna** | `health_export/` (3.1MB) | `dulalratna_sensitive/health_export/` | CDA XML, athena PDFs |
| **DulalRatna** | `.env` (API keys) | `dulalratna_sensitive/env.txt` | GEMINI_API_KEY, TELEGRAM_BOT_TOKEN |
| **EconAI** | `.env` | `econai_sensitive/env.txt` | API keys |
| **PMGAI** | `projects/scn_race2_pdil/data/raw/` (1.6GB) | `pmgai_data/scn_race2_pdil_raw/` | Raw experimental data |
| **PMGAI** | `projects/scn_race2_pdil/data/external/` (11MB) | `pmgai_data/scn_race2_pdil_external/` | Reference papers |
| **GPG** | Private key for git-secret | `gpg_backup/deluair_private.asc` | Required to decrypt .env.secret files |

## Personal Page

- **Repo**: `$GITHUB_USER/hossen` (`~/hossen`)
- **URL**: `$GITHUB_USER`.github.io/hossen/
- **Hosting**: GitHub Pages (master branch)
- **Stack**: Single static `index.html`, no framework
- **Tone**: Understated, introverted, let work speak. No salesy copy.
- **Design**: Dark theme, JetBrains Mono + Source Serif 4, accent #0ef0c2
- **Linked from**: bdpolicylab.com about page (author name links here)

## 3 Work Sites

| Project | Repo / Dir | Domain | Purpose | Stack |
|---------|-----------|--------|---------|-------|
| **BDFacts** | `$GITHUB_USER/bddata` (`~/bddata`) | bdfacts.org | Charity: BD open data dissemination | React 19 + FastAPI + SQLite |
| **TradeWeave** | `$GITHUB_USER/trade-explorer` (`~/trade-explorer`) | tradeweave.org | Job/skill: International trade analytics | Full-stack, D3/Deck.gl, BACI data |
| **OMTT** | `$GITHUB_USER/omtt` (`~/omtt`) | bdpolicylab.com | Future business: pure think tank, consultancy | Policy-first, AI-augmented |

- All hosted on OVH VPS (`$VPS_HOST` from `~/dotfiles/config.sh`)

## Core Values / Project Purpose Hierarchy

1. **Greater good for all of humanity** (highest)
2. **Greater good for Bangladesh** (primary focus)
3. **Surviving and doing well professionally** (sustenance)

Project alignment:
- BDFacts (charity) -> values 1 & 2: open data for Bangladesh, free public good
- TradeWeave (job/skill) -> value 3: professional credibility in trade economics
- OMTT (future business) -> values 1, 2, 3: pure think tank for BD, consultancy/business revenue

## Hard Rules for All Projects

- **No mock data**: Every data point must come from a real source. No placeholder/fake data in production.
- **No hallucination**: AI-generated content must be grounded in real data. No fabricated statistics, citations, or claims.
- **No shady things**: No dark patterns, no deceptive metrics, no inflated visitor counters, no misleading visualizations. Everything transparent and honest.

## Secret Signature (Anti-Copy Watermark)

All 3 projects have a 6-layer signature. The marker `δελ` (Greek for "del", from Deluair) is the common thread.

1. **HTML comment**: `<!-- ꧁ Conceived, designed & built by Md Deluair Hossen, PhD ꧂ -->` + `<!-- δελ::{project}::2024::hossen::utm -->`
2. **Steganographic code comment**: `// δελ::{project}::mdh::utm::2024` in core files (App.jsx, db.ts, database.py)
3. **Meta tags**: `<meta name="author">` + `<meta name="creator" content="deluair">`
4. **Console message**: Styled `console.log` with project-branded colors on page load
5. **HTTP header**: `X-Crafted-By: Md Deluair Hossen, PhD` + `X-Origin: {domain}` on all responses
6. **Combination**: All 5 above present in every project

## Cross-Project Reference

See `projects-overview.md` for detailed cross-project design system comparison, shared infrastructure, key files, and cross-referencing status.

## Document Formatting Preferences

- **All paper/document generation scripts**: Tables and figures must NOT be embedded inline in body text. Body sections should be prose only. All main-text tables/figures are collected into a queue during body text generation, then rendered after References but before Appendix, each on its own page.
- Pattern: use a `table_queue = []` list, append table data dicts (`title`, `headers`, `rows`, `note`, etc.), then render them in a loop after References with page breaks.
- See `patterns.md` for detailed format reference.

## PMGAI Toolkit

- **Location**: `~/pmgai/` (repo: `$GITHUB_USER/pmgai`)
- **Purpose**: AI-augmented plant molecular genetics research toolkit
- **Key modules**:
  - `src/python/latex/pipeline.py`: `PaperPipeline` class (sections + tables + figures -> PDF)
  - `src/python/latex/template.py`: Journal-specific LaTeX templates (frontiers, mpmi_published, etc.)
  - `src/python/latex/compiler.py`: tectonic-based LaTeX compilation
- **Active project**: `projects/scn_race2_pdil/` (see `project_scn_pdil.md`)

## EconAI Toolkit

- **Location**: `~/econai/src/python/`
- **Key modules added (2026-03-08)**:
  - `estimation/iv.py`: `anderson_rubin_ci()` for weak-IV-robust inference
  - `latex/pipeline.py`: `PaperPipeline` class (sections + tables + figures -> PDF)
  - `latex/visual_check.py`: `visual_check()` for automated PDF screenshot inspection
- **Paper generation pattern**: See `global_labor_v2` project as reference implementation

## DulalRatna (Life OS)

See [dulalratna.md](dulalratna.md) for full details.
- **Location**: `~/dulalratna/` (repo: `$GITHUB_USER/dulalratna`, private)
- **Stack**: SQLite (`me.db`, schema v4) + Gemini AI + Telegram bot
- **Model**: `gemini-3.1-flash-lite-preview` (DO NOT CHANGE per user)
- **Intelligence**: 10 tools, FTS5 memory, Holt's forecasting, z-score anomaly detection, auto-context priming
- **Notifications**: Smart alerts only (no daily spam). Urgent=12h cooldown, warning=24h. DB-backed dedup.
- **Commands**: /start /health /finance /goals /briefing /alerts /reflect /ratna /chart /clear
- **Charts**: matplotlib dark-themed PNGs sent via Telegram (glucose, spending, networth, labs, dashboard)
- **Pregnancy**: GDM risk, prenatal milestones, trimester alerts, /ratna command
- **Remaining gap**: lite model intelligence ceiling (user preference is firm)

## Session Analysis (2026-03-08)

### Usage Stats (Oct 2025 - Mar 2026)
- 827 commands, 52 sessions, 13 active days
- Peak hours: 9-14 and 17-21. Weekend heavy.
- 78% of messages under 50 chars. Median 26 chars.

### Custom Automations Created
Global slash commands (`~/.claude/commands/`):
- `/audit` - data integrity audit
- `/reviewer2` - hostile academic reviewer persona
- `/cross-audit` - audit all 3 projects for consistency
- `/paper` - research paper generation pipeline
- `/deploy-all` - deploy one or all projects

Project skills created:
- `bddata/.claude/skills/audit-data/` - BDFacts-specific data audit
- `bddata/.claude/skills/narrative-fix/` - debug narrative rendering
- `trade-explorer/.claude/skills/audit-trade-data/` - trade data unit/calc validation
- `trade-explorer/.claude/skills/add-research-page/` - scaffold new research pages

### Agent Limits
- [Max 10 parallel agents](feedback_max_agents.md): Never launch more than 10 agents at once. Batch in waves, write results to /tmp.

### Key Patterns Identified
- Build-then-audit cycle: build features, then obsessively verify data
- Deploy frequency: 75+ push/deploy commands across 13 days
- Expert framing: "be reviewer 2", "SOTA?", "would you accept this?"
- Delegation style: give direction, then "yes/go on/continue" to keep executing

## Hardware

See [hardware.md](hardware.md). 4 machines: Mac Mini M4, MacBook Air M4 (both 256GB), Samsung Galaxy Book Edge (Snapdragon, 512GB), Dell Precision 5560 (32GB, 1TB). 256GB Macs are tight with 18GB trade.db.

## TradeWeave Audit (2026-03-12)

See [tradeweave_audit_2026_03.md](tradeweave_audit_2026_03.md) for full details. 3-wave audit, 49 CRITICAL fixes, 44 files. Key: FAOSTAT 1e3 not 1e6, ECI citation is Hidalgo 2009 PNAS, PCI negatives are normal, HHI thresholds 0.15/0.25, unit values in USD/t not $/kg.
