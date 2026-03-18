---
name: BD GIS Sub-project in OMTT
description: Bangladesh Comprehensive Geospatial Analysis Platform (bd_gis) in ~/omtt/bd_gis. 24 GIS modules + 3 utility modules, full OMTT integration, deployed to bdpolicylab.com.
type: project
---

## BD GIS (~/omtt/bd_gis)

- **Repo**: `deluair/bd_gis` cloned into `~/omtt/bd_gis` on 2026-03-15
- **Stack**: Python 3.9+, Google Earth Engine, flat layout, `run_pipeline.py` orchestrator
- **GEE project**: `gen-lang-client-0432004086`
- **GEE auth**: authenticated on Mac Mini M4 (2026-03-15)
- **Scope system**: `--scope national|sylhet|<division>` via `config.py`

### 24 Analysis Modules (as of 2026-03-15)

Water (5): water_classification, river_analysis, flood_analysis, water_change, haor_analysis
Extended (8): nightlights, urbanization, vegetation, land_cover, air_quality, climate, poverty, infrastructure
Domain (5): crop_detection, slum_mapping, coastal, soil_analysis, health_risk, energy
**New (6)**: brick_kiln, aquaculture, char_accretion, cyclone_damage, groundwater, transportation

Utility modules: timelapse.py, change_alerts.py, run_divisions.py

### Audit + Fixes (2026-03-15)

34 CRITICAL issues found and fixed:
1. GEE scale: `bestEffort+scale=30` at national -> scope-aware (300 for national)
2. DMSP/VIIRS: added sensor labels + sensor-specific lit thresholds
3. River baseline: wider compositing window for pre-1990 + scale by buffer size
4. Haor filtering: drop values <1% of pi*r^2
5. Aerosol QA: qa_value > 0.5 filter + positive-only AAI
6. ee.Number resolution: _resolve_ee() in period comparison CSV
7. **Thread safety**: replaced signal.SIGALRM with concurrent.futures timeout (SIGALRM fails in ThreadPoolExecutor workers)

### Pipeline Optimization

- `_batch_resolve_ee()` / `_batch_resolve_list()`: N getInfo() -> 1 ee.Dictionary call
- `_run_parallel()`: ThreadPoolExecutor(max_workers=4), 3 dependency waves
- Thread-safe timeouts throughout (concurrent.futures, not signal.SIGALRM)
- Confirmed working: test run showed 6,594 km2 dry / 15,220 km2 monsoon (was 40/82 before fixes)

### OMTT Integration (all 3 phases DONE)

**Phase A -- Data Bridge** (DONE):
- `app/collectors/gis.py`: GisCollector with 5 CSV extraction patterns
- 156 series, 872 data points in bdpolicy.db, source="gis"
- CLI: `python -m app.cli collect gis`

**Phase B -- Cross-Domain Analyzers** (DONE):
- `app/analysis/climate_vulnerability.py`: flood + rainfall + LST + NDVI + ag dependence -> score 0-100
- `app/analysis/urban_development.py`: nightlights + built-up + UHI + NO2 + slums -> score 0-100
- `app/analysis/environmental_change.py`: NDVI + forest + water bodies + cropland -> score 0-100

**Phase C -- Policy Publications** (DONE):
- 3 briefs: climate_vulnerability_brief, urban_development_brief, environmental_change_brief
- All registered in registry.py, generating HTML with cards + charts + narrative
- Published to bdpolicy.db (139 total publications)
- Deployed to bdpolicylab.com

### Web Pages (DONE)

- `/maps`: 22 interactive GIS maps in 4 categories
- `/gis-3d`: Deck.gl 3D visualization (nightlights + NO2 + poverty columns)
- Narrative: "Bangladesh is Drowning" (content/narratives/2026-03-15-bangladesh-drowning/)

### Automation (DONE)

- `scripts/refresh-gis.sh`: collect gis + regenerate 3 publications
- `scripts/monthly-gis-update.sh`: run airquality + nightlights + refresh
- `.github/workflows/monthly-gis.yml`: 1st of each month, needs GOOGLE_APPLICATION_CREDENTIALS_JSON secret

### BDFacts Integration (DONE)

- `bddata/scripts/ingest-gis.py`: 14 satellite indicators, 185 data values in bangladesh.db

### Academic Paper

- Outline at `docs/paper-satellite-vulnerability-index.md`
- "Satellite-Derived Climate Vulnerability Index for Bangladesh: A Multi-Sensor Approach (1985-2025)"
- 20 real citations, grounded in actual bd_gis methodology and output data

### Local Hybrid Compute (2026-03-15)

**Architecture shift**: GEE is too slow for national reductions (hangs on getInfo). New hybrid approach:
- **Local compute** (`local_compute.py`): rasterio/numpy on downloaded GeoTIFFs. 5 modules in 3 seconds.
- **Planetary Computer** (`pystac-client` + `planetary-computer`): Landsat COGs streamed directly from Azure. No GEE queue.
- **GEE retained only for**: custom compositing that needs raw scene access (cloud masking, multi-temporal fusion)

**Downloaded data** (~4.4GB in `local_data/`, gitignored):
- Hansen GFC v1.11 (treecover2000, lossyear, gain) BD-clipped
- JRC Global Surface Water v1.4 (occurrence) BD-clipped
- CHIRPS v2.0 monthly rainfall 2023
- WorldPop Bangladesh 2020 1km
- GHSL Built-up Surface 2020
- Landsat 7/8/9 single scenes: 2000/2010/2020/2024 dry+monsoon (8 files)
- Landsat 8 full BD mosaics: 2020 dry (525MB) + monsoon (619MB), NIR-only
- 6-band mosaics (building): 2020 dry+monsoon with blue/green/red/nir/swir1/swir2

**Dependencies added**: `pystac-client`, `planetary-computer` (pip)

**Key finding**: GEE `signal.SIGALRM` timeouts fail in ThreadPoolExecutor threads. Replaced with `concurrent.futures` timeout throughout.

**GEE pipeline results** (sequential run):
- 9/12 extended modules completed (landcover, slums, coastal hung)
- Confirmed corrected scale values (dry: 6,594 km2, monsoon: 15,220 km2)

### Poverty Ground Truth Integration (2026-03-17)

**Data sources acquired:**
- DHS Program: 227 zips (607MB), all BD survey rounds 1993-2023
- IPUMS International: 30.2M person records, 66 cols, BD censuses 1991/2001/2011
- HIES 2022: BBS Final Report PDF (8.7MB), official poverty statistics

**New scripts:**
- `hies_ground_truth.py`: Extracts HIES 2022 tables (HCR, income, facilities, poverty gap by division)
- `ipums_poverty.py`: Builds MPI from IPUMS census data (housing/education/employment), 180 district-year cells
- `dhs_wealth.py`: Extracts DHS wealth quintile distributions by division (5 surveys: 2007-2022)
- `calibrate_poverty.py`: Satellite vs HIES calibration diagnostic

**Key finding:** Satellite poverty index r=0.20 against HIES (useless). Division spread 0.01 vs real 12pp. Use HIES directly for division-level, satellite only for within-division spatial disaggregation.

**Poverty outputs (13 CSVs in outputs/poverty/):**
- hies_division_hcr.csv, hies_national_hcr_timeseries.csv, hies_division_poverty_gap.csv
- hies_division_income.csv, hies_division_facilities.csv, hies_hcr_by_education.csv, hies_hcr_by_land.csv
- ipums_district_mpi.csv (60 districts x 3 years)
- dhs_wealth_by_division.csv (8 divisions x 5 surveys)
- calibration_results.csv

**OMTT integration updated:** GIS collector now ingests 1018 data points (was 872). Added HIES poverty, kilns, aquaculture, crops, groundwater registrations.

### Fixes Applied (2026-03-17)

- ESA WorldCover asset path: `v100` -> `v100/2020`, `v200` -> `v200/2021`
- Crop detection pipeline: fixed result key mismatch (aman_timeseries/boro_timeseries vs rice_timeseries), now produces 4 CSVs

### 6 New Modules Run (2026-03-17)

All 6 new modules executed successfully:
- kilns: 5 files (thermal hotspots, spectral area, density by district, timeseries, emissions)
- aquaculture: 6 files (pond area, Cox's Bazar, Noakhali, timeseries, mangrove conversion, by district)
- chars: 8 files (accretion timeseries, vulnerability, + Drive exports)
- cyclones: 1 file (damage summary)
- groundwater: 3 files (timeseries, spatial stats)
- transportation: 6 files

### Remaining / Future Sessions

1. Add `GOOGLE_APPLICATION_CREDENTIALS_JSON` GitHub secret for monthly cron
2. ~~Run 6 new modules~~ DONE
3. Run `run_divisions.py` for per-division breakdowns
4. Run `--timelapse` for animated GIFs
5. Run `--alerts` for 2024 anomaly detection
6. Write full paper from outline at `docs/paper-satellite-vulnerability-index.md`
7. Create publications for the 6 new modules
8. Expand local_compute.py to use 6-band Landsat mosaics for full NDWI/MNDWI water classification
9. Download more years from Planetary Computer (2000, 2010, 2024 full mosaics)
10. Fix CHIRPS local rainfall (decompression/clipping issue)
11. Landcover/slums/coastal: running national 2026-03-17, may still timeout on GEE
12. ~~ESA WorldCover v200 asset path~~ FIXED
13. ~~Crops zero output~~ FIXED (key mismatch in run_pipeline.py)
14. SOTA poverty mapping ML paper (DHS + IPUMS + satellite features)
