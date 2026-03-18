---
name: GTAP CGE Model Implementation
description: GTAP-type CGE model for Bangladesh trade policy analysis — progress, architecture, and remaining tasks
type: project
---

## GTAP CGE Model for Bangladesh (OMTT)

**Branch:** `feat/cge-model` on `D:/omtt`
**Plan:** `D:/omtt/docs/superpowers/plans/2026-03-11-gtap-cge-model.md`
**Spec:** `D:/omtt/docs/superpowers/specs/2026-03-11-gtap-cge-model-design.md`

### Architecture
- Pure Python CGE calibrated from real GTAP 10A data (HAR files via `harpy3`)
- 65 GTAP sectors aggregated to 15, 141 regions to 9, 8 endowments to 5 factors
- Hat calculus linearized system solved with scipy
- Johansen (1-step), multi-step Euler, and Gragg extrapolation solvers
- 3 pre-built scenarios: LDC graduation, US tariffs, regional FTA

### Completed (Tasks 1-10)
- `app/cge/mappings.py` — sector/region/factor aggregation maps
- `app/cge/har_parser.py` — harpy3 wrapper for GEMPACK HAR files
- `app/cge/data_extract.py` — GTAP ZIP extraction + aggregation pipeline
- `app/cge/sam.py` — Social Accounting Matrix builder
- `app/cge/calibration.py` — cost shares, Armington shares, elasticities
- `app/cge/model.py` — linearized GTAP model (A @ endo = B @ exo)
- `app/cge/solver.py` — Johansen, multi-step Euler, Gragg solvers
- `app/cge/simulation.py` — shock translation + orchestration
- `app/cge/results.py` — welfare/output analysis
- `app/cge/scenarios/` — ldc_graduation, us_tariffs, regional_fta
- `tests/test_cge.py` — 12/12 tests passing
- 3 commits pushed to `origin/feat/cge-model`

### Remaining (Tasks 11-15, Chunk 4: OMTT Integration)
- **Task 11:** Public API exports in `app/cge/__init__.py`
- **Task 12:** CLI commands (`cge-extract`, `cge-simulate`) in `app/cli.py`
- **Task 13:** API router at `app/api/cge.py`, register in main.py
- **Task 14:** Publication generator `app/publications/pubs/cge_brief.py`
- **Task 15:** Final lint, full test suite, verification

### Key Technical Notes
- GTAP data at `D:/omtt/GTAP10A_GTAP_AY.pkg` (ZIP format)
- VDFM is (65, 66, 141) — slice to (65, 65, 141) to skip CGDS column
- EVFA (8, 66, 141) is factor-by-sector; EVOA (8, 141) is factor-by-region only
- HAR set headers: H1=REG, H2=TRAD_COMM, H6=ENDW_COMM
- Tiny 2x2 synthetic data produces ill-conditioned matrices (expected, not a bug)
- Windows paths: use `D:/omtt` not `/d/omtt` in Python Path objects
