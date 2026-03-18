---
name: dulalratna-consolidation-2026-03
description: March 2026 consolidation of 3 repos into dulalratna. GLM-4.7 replaced Gemini. dulal and me repos archived.
type: project
---

On 2026-03-18, consolidated 3 repos into one `dulalratna`:

- `deluair/me` (Life OS with Monte Carlo, projections, web dashboard) -> absorbed, archived on GitHub, ~/me/ deleted
- `deluair/dulal` (GLM-4.7 Telegram bot with NanoClaw agentic loop, discipline system) -> absorbed, archived on GitHub, ~/dulal/ deleted
- `deluair/dulalratna` (canonical, kept) -> now has everything

Key changes:
- AI: Gemini -> GLM-4.7 via z.ai proxy (anthropic SDK), env var ZAI_API_KEY
- Schema: v4 -> v5 (added job_applications, discipline, streaks, reminders)
- Tools: 10 -> 26 (discipline, job search, web search, reminders, platform health)
- Telegram: 10 -> 14 commands
- New modules: brain.py, discipline.py, heartbeat.py, query/jobs.py

**Why:** Both postdocs ending after June 2026. Needed job search tooling urgently. Three repos doing overlapping work was maintenance overhead.

**How to apply:** dulalratna is the only Life OS repo. Never reference deluair/me or deluair/dulal as active. If user asks about GLM setup, it is in melib/ai/brain.py using anthropic SDK at https://api.z.ai/api/anthropic.
