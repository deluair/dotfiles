---
name: dulalratna-life-os
description: DulalRatna personal Life OS at ~/dulalratna - Telegram bot with Gemini AI, persistent memory, anomaly detection, smart alerts, charts, pregnancy intelligence
type: project
---

## DulalRatna (Life OS)

- **Location**: `~/dulalratna/` (repo: `deluair/me`, private)
- **Database**: `me.db` (SQLite, WAL mode, schema v4, gitignored)
- **Telegram bot**: Gemini-powered with 10 function-calling tools
- **Model**: `gemini-3.1-flash-lite-preview` (user explicitly said do not change)

### Architecture (as of 2026-03-12)

```
melib/
  db.py               # SQLite schema v4 (23 tables + FTS5 + memories + notification_log)
  alerts.py           # Cross-domain alert engine + pregnancy alerts
  charts.py           # Dark-themed matplotlib PNG charts for Telegram
  ai/
    gemini.py          # SOTA engine: 10 tools, auto-context priming, persistent brain
    query.py           # Pattern-matching NLP (fallback, non-Gemini)
  ingest/             # Health, finance, remittance, career, goals, timeline, apple_health, csv_finance, file_watcher
  query/              # health.py, finance.py, goals.py, overview.py
  projections/        # financial.py (retirement, house, NC move), health.py (CVD, prediabetes, thyroid), montecarlo.py
  telegram_bot.py     # 10 commands, smart alerts, charts, pregnancy, correction learning, auto inbox scan
```

### Intelligence Layers

1. **Auto-context priming**: Every query gets life-state injection (time, baby countdown, alert count, memories)
2. **Persistent brain**: `memories` table + FTS5 full-text search (Porter stemming), `remember`/`recall` tools, dedup on insert
3. **Anomaly detection**: Z-score + Holt's double exponential smoothing on glucose, labs, spending, weight
4. **Pattern detection**: 7 domains (glucose_trends, spending_trends, health_changes, cross_domain, baby_countdown, lifestyle_correlations, pregnancy)
5. **Smart alerts**: Every 6h, urgent (12h cooldown) / warning (24h cooldown) only, DB-backed `notification_log`
6. **Soul**: System prompt embeds Dulal's philosophy, South Asian clinical adjustments, financial context
7. **Charts**: Dark-themed matplotlib PNGs (glucose, spending, net worth, lab trends, health dashboard)
8. **Pregnancy intelligence**: GDM risk scoring, prenatal milestones, trimester-aware alerts, /ratna command
9. **Correction learning**: Detects "wrong"/"no"/"actually" in messages, stores as high-importance correction memories
10. **Auto data refresh**: Inbox scan every 2h, auto-ingests Apple Health XML and bank CSVs

### Telegram Commands

/start, /health, /finance, /goals, /briefing, /alerts, /reflect, /ratna, /chart, /clear

### Key Design Decisions

- No daily notification spam (user explicitly requested removal)
- Model locked to `gemini-3.1-flash-lite-preview` per user preference
- All data must be real, no mock data
- `me.db` and `.env` are gitignored
- Repo is private on GitHub

### Remaining Gap

- Model is lite (intelligence ceiling), but user preference is firm
