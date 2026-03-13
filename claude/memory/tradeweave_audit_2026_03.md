---
name: TradeWeave 3-Wave Expert Audit (2026-03-12)
description: Comprehensive data integrity audit of TradeWeave, 49 CRITICAL fixes across 44 files. Key corrections to FAOSTAT multipliers, ECI/PCI citations, HHI thresholds, unit values, and API security.
type: project
---

Completed a 3-wave expert audit of TradeWeave (tradeweave.org) on 2026-03-12 using 30 parallel agents across 52 pages, 135 API routes, and 15 viz components.

**Results**: 49 CRITICAL, 120+ WARN issues found and fixed. 44 files changed, 644 insertions, 1633 deletions.

**Key data accuracy fixes** (patterns to never repeat):
- FAOSTAT values multiply by 1e3 (not 1e6) for display
- ECI/PCI primary citation: Hidalgo & Hausmann (2009) PNAS 106(26), NOT the 2011 Atlas
- PCI is zero-centered, negative values are normal. Don't color negatives red.
- EXPY (PCI-weighted): dimensionless, no dollar formatting. EXPY (PRODY-based): in USD.
- HHI thresholds: DOJ standard 0.15 (moderate) / 0.25 (highly concentrated)
- Unit values: USD/metric ton (not $/kg), computed as (export_value * 1000) / export_qty
- HS Section 3: "Animal and Vegetable Fats and Oils" (not "Bi-Products")
- Grubel-Lloyd bilateral values in TradeWeave are approximated via uniform scaling; must disclose
- Export rank queries must use full COUNT, not findIndex on a LIMIT'd result
- Global UV benchmarks must use trade-value-weighted averages, not unweighted AVG()

**Security fixes**:
- Internal API endpoints (crawl) need auth tokens
- x-forwarded-for must be split on comma, take first IP

**Why:** Data accuracy is the core credibility of a trade analytics platform. These corrections prevent misleading researchers and policymakers.

**How to apply:** When adding or modifying any data display, calculation, or citation in TradeWeave, cross-check against these patterns. Run `/audit` or `/trade-check` after significant changes.
