---
name: BDPolicyLab Detailed Data Inventory
description: Complete inventory of all databases, row counts, sources, and coverage in BDPolicyLab and BDFacts as of 2026-03-15. Use when planning cross-data integrations.
type: reference
---

## BDPolicyLab Databases (~/bdpolicylab/data/)

### bdpolicy.db (41MB) -- BDPolicyLab's own collected data
- `data_series`: 11,708 series
- `data_points`: 162,359 points
- `publications`: 136 (100 narratives, 17 brief types with 2 each, 1 trade flagship, 1 paper)
- **Top sources**: hdx (10,113 series), world_bank_peer (923), zila_sdg (267), world_bank (188), bbs_census (49), bangladesh_bank (22)
- **32 collectors**: BB, FRED, WB, IMF, ILO, HDX (5 domains), FAO, ADB, UNESCO, WHO, etc.

### bangladesh.db (43MB) -- Copy of BDFacts DB
- `indicators`: 30,341
- `data_values`: 541,985
- `data_sources`: 9 (WB, IMF, WHO, UN SDG, FAO, ILO, UNESCO, UN Comtrade, FRED)
- **Year coverage**: 1950-2100 (151 distinct years, includes IMF projections)
- **Top categories**: Trade (13,772), Agriculture (8,371), Food Security (3,085), Climate (962), Environment (777), Economy (650), Health (617)

### baci.db (215MB) -- BD trade flows
- 1.9M rows, HS92, 1995-2024

## BDFacts Databases (~/bdfacts/backend/)

### bangladesh.db (43MB) -- master copy
- `indicators`: 14,706
- `data_values`: 423,378
- Same 9 sources as BDPolicyLab copy but fewer indicators (BDPolicyLab copy has more recent fetches)

### analytics.db (1.2MB) -- site analytics
- 78 sessions, 333 events, 3,792 crawler visits

### wdi.db (56KB) -- empty, unused

## bd_gis Outputs (~/bdpolicylab/bd_gis/outputs/)

18 output directories with 70+ CSV files covering:
water, floods, rivers, haors, changes, nightlights, urbanization, vegetation, landcover,
airquality, climate, poverty, infrastructure, slums, crops (empty), coastal (empty),
soil (empty), health (empty), energy (empty)

## Cross-Project Data Flow

BDFacts (bangladesh.db) -> copied to BDPolicyLab -> BDPolicyLab adds bdpolicy.db (HDX, zila SDG, collectors)
TradeWeave (trade.db 18GB) -> BACI subset copied to BDPolicyLab baci.db (215MB, BD only)
bd_gis (GEE satellite) -> CSV outputs in ~/bdpolicylab/bd_gis/outputs/ (NOT yet in any DB)
