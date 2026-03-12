---
name: omtt_vision
description: OMTT/BDPolicy Lab strategic vision, McKinsey-grade consultancy research platform for Bangladesh
type: project
---

OMTT is evolving from auto-generated policy briefs to deep, McKinsey-grade research publications.

**Why:** User views BDPolicy Lab as a think tank + consultancy, not a dashboard. Each topic should produce consultancy-grade research with deep data analysis, econometrics, many charts, and actionable strategy.

**How to apply:**
- Each topic gets a `scripts/{topic}_flagship/` pipeline (like `scripts/trade_flagship/`)
- Pipeline: chapter modules, data loader, advanced analytics, 30+ Plotly charts, pre-compute script outputting JSON
- Publication generator reads JSON and assembles HTML
- Current "brief" generators kept as data infrastructure until replaced one by one
- Trade flagship (343KB, 34+ charts) is the gold standard to replicate
- Scope includes: sector deep-dives, policy impact assessments, benchmarking, strategy frameworks
- No more "monthly briefs" framing. Standing research papers, updated with latest data.

**Topics (17 total):** trade (done), pulse/macro, price/inflation, fiscal, development, remittance, energy, banking, health, solar, education, labor, digital, climate, cost_of_living, financial_inclusion, governance, cge
