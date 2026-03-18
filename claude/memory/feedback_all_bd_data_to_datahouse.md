---
name: feedback_all_bd_data_to_datahouse
description: All Bangladesh data from any source must be ingested into OMTT datahouse (bdpolicy.db), never left as raw files only
type: feedback
---

All Bangladesh-related data, wherever it exists (OneDrive, raw CSVs, HDX, DHS, HIES, BBS, IPUMS, SDG, any source), must always be ingested into the OMTT datahouse (bdpolicy.db) via the collector pipeline.

**Why:** The datahouse is the single source of truth for all BD policy analysis. Raw files sitting in OneDrive or bd_gis/outputs without DB ingestion are invisible to the publication pipeline, API, and narratives.

**How to apply:** When generating or discovering new BD data CSVs, always: (1) register them in `app/collectors/gis.py` GIS_CSV_REGISTRY, (2) run `collect gis` to ingest, (3) verify series appear in DB. Never leave data as CSV-only.
