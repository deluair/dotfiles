---
name: data_inventory
description: Complete data inventory across all projects (BDFacts, OMTT, TradeWeave). Databases, sources, row counts, coverage, freshness, gaps.
type: reference
---

# Data Inventory (updated 2026-03-14)

## 1. BDFacts (bdfacts.org)

### bangladesh.db (34 MB, ~/bdfacts/backend/data/)

Multi-source Bangladesh indicator database. 7 active sources, ~17K indicators, ~457K data points.

| Source | Indicators | Data Points | Years | Last Fetch |
|--------|-----------|-------------|-------|------------|
| FAO | 14,271 | 385,383 | 1950-2100 | 2026-02-28 |
| World Bank | 2,115 | 52,846 | 1960-2025 | 2026-03-14 |
| FRED | 399 | 10,491 | 1960-2026 | 2026-02-28 |
| UN SDG | 504 | 5,215 | 1983-2025 | 2026-02-28 |
| WHO | 350 | 3,127 | 1950-2030 | 2026-02-28 |
| IMF | 12+7 | 588 | 1980-2030 | 2026-03-14 |
| ILO | 12 | 239 | 1984-2025 | 2026-02-28 |
| UNESCO | 0 | 0 | - | BROKEN |
| UN Comtrade | 0 | 0 | - | PURGED (replaced by BACI) |

**Fetcher**: `backend/bangladesh_fetch.py --source {wb|imf|who|unsdg|fao|ilo|fred} --stale-days 0`

### baci.db (215 MB, ~/bdfacts/backend/data/)

BACI bilateral trade database (copy from OMTT). HS92 revision.

| Metric | Value |
|--------|-------|
| Total rows | 1,898,667 |
| Years | 1995-2024 |
| Countries | 238 |
| HS6 products | 5,022 |
| BGD export partners | 224 |
| BGD export products | 4,569 |

### wdi.db (56 KB, ~/bdfacts/backend/)

World Bank WDI specialized database. 4 WB sources (WDI, Governance, Debt, Gender).

**Fetcher**: `backend/wdi_fetch.py`

### analytics.db (1.2 MB, ~/bdfacts/backend/)

User sessions, events, feedback, crawler tracking. Auto-pruned at 90 days.

### Hardcoded arrays (backend/data/bangladesh.py)

12 calibrated macro series, 2000-2024 (25 years). Sources: BBS, WB, IMF, BB, UNDP.
GDP growth, inflation, unemployment, poverty, remittances, exports, investment rate, exchange rate, HDI, per capita GDP, govt expenditure, tax revenue.

### DataHouse (backend/datahouse.py)

Unified access layer: 97 concepts across 15 domains.
Authority chain: bangladesh.db > wdi.db > BACI > hardcoded arrays.

| Domain | Concepts |
|--------|----------|
| economy | 24 |
| trade | 16 |
| external | 8 |
| health | 7 |
| financial | 7 |
| fiscal | 6 |
| education | 4 |
| labor | 4 |
| energy | 4 |
| agriculture | 4 |
| poverty | 3 |
| governance | 3 |
| gender | 3 |
| digital | 2 |
| water | 2 |

14 headline snapshot indicators. 12 IMF projection concepts (to 2030). 7 BACI trade concepts.

### Frontend Data (src/data/bangladeshData.js)

19 section pages, 95 metric cards (all real sourced values, zero fabricated).
85 charts: 58 filled by live API (bangladesh.db), 27 static with real data.
Sources: World Bank, IMF, WHO, ILO, FAO, UNESCO, BGMEA, BPDB, DSE, MoF, BB, BMET, ICC, Petrobangla, IDCOL, TI, UNDP, EC.

### New OMTT Collectors (added 2026-03-14)

- **WITS** (`app/collectors/wits.py`): 24 BD tariff series (MFN, applied, sector, preferential by partner). SDMX API, no auth.
- **UNCTAD** (`app/collectors/unctad.py`): 21 indicators via WB API (FDI, trade composition, tech exports). UNCTADstat API undocumented, uses WB fallback.

---

## 2. OMTT (bdpolicylab.com)

### bdpolicy.db (41 MB, ~/bdpolicylab/data/)

Policy think tank database. 136 publications, 11.7K series, 162K data points.

| Source | Series | Data Points | Coverage |
|--------|--------|-------------|----------|
| HDX (30+ datasets) | 10,113 | 102,106 | 1960-2030 |
| FRED | 6 | 29,587 | 1976-2026 |
| World Bank (peers) | 923 | 18,971 | 1960-2025 |
| World Bank (BD) | 188 | 6,763 | 1960-2025 |
| BLS | 5 | 1,150 | 2006-2026 |
| IMF | 15 | 661 | 1980-2026 |
| V-Dem | 15 | 375 | 2000-2024 |
| ADB | 15 | 375 | 2000-2024 |
| Bangladesh Bank | 22 | 340 | 2000-2026 |
| UNESCO | 20 | 321 | 2000-2025 |
| Zila SDG | 267 | 267 | 1991-2061 |
| WHO | 13 | 255 | 1990-2030 |
| ND-GAIN | 10 | 240 | 2000-2023 |
| FAO | 10 | 214 | 2000-2024 |
| IRENA | 8 | 186 | 2000-2024 |
| Comtrade | 7 | 122 | 2006-2025 |
| ILO | 10 | 116 | 1991-2025 |
| EIA | 3 | 104 | 1990-2024 |
| EM-DAT | 4 | 92 | 2000-2025 |
| BBS Census | 49 | 49 | 2022 |
| Freedom House | 4 | 48 | 2013-2024 |
| TI CPI | 1 | 17 | 2001-2017 |

**Collectors**: 23 registered, automated via APScheduler.
**DataHouse**: `app/datahouse.py` with concept catalog, authority-weighted resolution, parquet for IMF WEO.

### baci.db (215 MB, ~/bdpolicylab/data/)

Same as BDFacts copy. Source of truth.

### OECD ICIO matrices (6.4 GB, ~/bdpolicylab/data/icio/v2025/)

28 years (1995-2022) of Inter-Country Input-Output tables. 4 matrix types per year (Z, FD, VA, X).
50 industries x 85 countries raw, aggregated to 13x9 for BD policy analysis.
Used by: Caliendo-Parro CGE model, IO analysis, TiVA decomposition, GVC analysis.

### Downloaded Raw Data (3.9 GB, ~/bdpolicylab/data/trade/)

197 files of manually downloaded Bangladesh research data.

#### COMTRADE (733 MB)
- `bangladesh_comtrade_annual.parquet` (141 MB) -- annual BD trade flows
- `bangladesh_comtrade_monthly.parquet` (466 MB) -- monthly BD trade flows
- `bangladesh_customs.parquet` (126 MB) -- customs data

#### CEPII Gravity (10 MB, gravity/)
- `cepii_bd_Gravity_V202211.parquet` (1.4 MB) -- gravity model variables
- `cepii_bd_TRADHIST_v4.parquet` (798 KB) -- historical trade
- `dist_cepii.dta`, `geo_cepii.dta`, `country_dist.dta` -- distance/geo data
- `ling_web.dta` -- linguistic proximity
- `hsind_hs6.dta` -- HS6 industry mapping

#### BACI Derivatives (8 MB)
- `baci_XUVI_isic.csv` (3.2 MB) -- export unit values by ISIC
- `baci_MUVI_isic.csv` (4.4 MB) -- import unit values by ISIC
- `baci_XUVI.csv`, `baci_MUVI.csv`, `baci_ProTEE_0_1.csv`, `baci_LAB_isic.csv`

#### WTO Tariff Data (268 MB)
- `wto_bd_WtoData_20250411214537.csv` (131 MB) -- full WTO tariff dump
- `wto_td_bd_bd_tariff_wto.csv` (131 MB) -- BD tariff data
- `wto_overall_average_tariff_data_1995_onward.xlsx` -- average tariffs
- `wto_wood_tariff_data_2024.xlsx` (5.3 MB) -- sector detail
- `wto_WtoDataInventory_20250411150114.xlsx` -- WTO data catalog
- `wto_bd_wood_tariff_data_2023.parquet` -- parquet format

#### WITS/TRAINS (5 MB)
- `wits_trains_bd/DataJobID-2565997_2565997_bd.csv` (4.7 MB) -- full TRAINS tariff dump
- `wits_trains_bd_tariffmeasures_by_countries.csv` -- tariff by partner
- `wits_trains_bd_beneficiaries_by_fta.csv` -- FTA beneficiary analysis
- `wits_bulk_files_SIC.xlsx` -- SIC classification

#### UNCTAD (183 MB)
- `unctad_bd_US_TradeFoodProcCat_Proc_19952008.csv` (86 MB) -- food processing trade 1995-2008
- `unctad_bd_US_TradeFoodProcCat_Proc_20092022.csv` (86 MB) -- food processing trade 2009-2022
- `unctad_bd_US_OceanTrade_20230718044639.csv` (10 MB) -- ocean/maritime trade
- `unctad_bd_US_ExchangeRateCrosstab_20230726120002.csv` (1.7 MB) -- exchange rates
- `unctad_bd_US_TotAndComServicesQuarterly.csv` (322 KB) -- services trade quarterly
- `unctad_bd_US_TermsOfTrade_20231229020542.csv` -- terms of trade
- `unctad_bd_US_Cpi_A_20230707022429.csv` -- CPI

#### USDA Baseline Projections (11 MB)
- 24 annual baseline xlsx files (2002-2025), each with long-term projections
- `usda_baseline_bd_2025*.csv` -- BD-specific 2025 baseline
- `usda_RealGDP_bangladesh.csv`, `usda_RealPerCapitaGDP_bangladesh.csv`
- `usda_Population_bangladesh.csv`, `usda_CPI_bangladesh.csv`
- `usda_*exchangerates*_bangladesh.csv` -- nominal/real exchange rates

#### ITPD (International Trade and Production Database) (822 MB)
- `itpd_bd_ITPD_S_R1.csv` (357 MB) -- full ITPD sectoral release 1
- `itpd_bd_ITPD_S_R1_no_names.csv` (189 MB) -- same without names
- `itpd_bd_ITPDE_R03.csv` (119 MB) -- ITPD extended release 3
- `itpd_bd_ITPD_E_R02.csv` (74 MB), `itpd_bd_ITPD_E_R01.csv` (57 MB)
- Decade splits: release 2.0 and 2.1 (1970-2019, 8 files each)
- `itpd_bd_dicl_database.parquet`, `itpd_bd_mreid_public_release_1.0.parquet`

#### Tariff Research Data (14 MB, parquet)
- `tariffs_bd_tariff_GTAP_88_21_vbeta1-2024-12.parquet` (5.1 MB) -- GTAP-classified
- `tariffs_bd_tariff_isic33_88_21_vbeta1-2024-12.parquet` (4.6 MB) -- ISIC-classified
- `tariffs_bd_tariff_section_88_21_vbeta1-2024-12.parquet` (3.6 MB) -- HS section
- `tariffs_bd_tariffs_Ag-NonAg_88_21_vbeta1-2024-12.parquet` -- Ag vs Non-Ag
- `tariffs_bd_tariffsPairs_88_21_vbeta1-2024-12.parquet` -- bilateral pairs

#### OEC (Observatory of Economic Complexity)
- `oec_indicators_bangladesh.parquet` (504 KB) -- ECI/PCI/trade indicators
- `oec_imports_2021_bangladesh.xlsx` (292 KB) -- 2021 import detail

#### SPAM (Spatial Production Allocation Model) (5.7 MB, spam/)
- 12 CSV files: spam2020V1r0 for BD (production, harvest area, yield by crop)

#### BD Research / Stata (1.4 GB, bd_research_130783/)
- `bangladesh_data.dta`, `bgd2.dta` -- large Stata datasets (research use)

#### GIS / Shapefiles
- `gadm41_BGD_shp.zip` (105 MB) -- Bangladesh admin boundaries (GADM v4.1)

#### Other
- `exchange_rates.csv` (52 KB) -- historical rates
- `WDICountry-Series.csv` (1 MB) -- WDI metadata
- `wb_enterprise_bangladesh.xls` (1.4 MB) -- Enterprise Survey
- `gvc_bd_gvc_output_WITS.csv` (180 KB) -- GVC analysis output
- `HS classification files` (11 MB, hs_classifications/) -- HS-SITC-BEC mappings, Comtrade codes, CHELEM classifications

### IMF Bulk CSVs (OneDrive, 65 files)

Location: `OneDrive/hossen_storage/omtt_raw_data/imf_csvs_2026-03-13/`

65 CSV files downloaded from IMF SDMX/data center on 2026-03-13. Covers:
- IFS (International Financial Statistics)
- BOP (Balance of Payments)
- GFS (Government Finance Statistics)
- CPI, PPI, trade indices
- COFER (Currency Composition of Foreign Exchange Reserves)
- WEO regional (Asia Pacific)
- ESG finance, exchange rates
- NSDP (National Summary Data Page)

### IMF WEO parquet (~/bdpolicylab/data/imf_all.parquet)

IMF World Economic Outlook indicators in parquet format. Dot notation (e.g., BGD.NGDP_RPCH.A).

---

## 3. TradeWeave (tradeweave.org)

### trade.db (18 GB, ~/tradeweave/data/)

Comprehensive global trade database. 51 tables.

| Table | Rows | Description |
|-------|------|-------------|
| country_year_product | 24.0M | Core trade flows |
| rca_matrix | 11.7M | Revealed comparative advantage |
| product_proximity | 93.9M | Product space |
| geodep | 2.9M | Geo-dependencies |
| bilateral_year | 870K | Bilateral aggregates |
| product_rankings | 147K | Product-level rankings |
| product_growth | 142K | Product growth rates |
| country_year_totals | 6.7K | Country aggregates |
| country_rankings | 6.7K | ECI/country rankings |
| eci_rankings | 6.7K | Economic Complexity Index |
| country_hhi | 6.7K | Export concentration |
| countries | 238 | Country metadata |
| products | 5,022 | HS product metadata |

### app.db (36 KB, ~/tradeweave/data/)

Application state database.

---

## 4. OneDrive Backups

Base: `~/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage/`

| Backup | Size | Last Updated |
|--------|------|-------------|
| db_backups/omtt_bdpolicy_latest.db | 40 MB | 2026-03-14 |
| db_backups/bddb_latest.sqlite | 43 MB | 2026-03-14 |
| db_backups/bddb_analytics_latest.db | 1.2 MB | 2026-03-14 |
| db_backups/bddb_wdi_latest.db | 56 KB | 2026-03-14 |
| db_backups/omtt_baci_latest.db | 215 MB | 2026-03-10 |
| db_backups/omtt_bangladesh_latest.db | 43 MB | 2026-03-10 |
| db_backups/trade.db | 18 GB | 2026-03-09 |
| db_backups/tradeweave_app_latest.db | 36 KB | 2026-03-14 |
| db_backups/dulalratna_me_latest.db | 560 KB | 2026-03-14 |
| trade_backup/baci_zips/ | ~10 GB | BACI_HS92 (2.3G), HS96 (2.2G), HS02 (1.9G), HS07 (1.6G), HS12 (1.2G), HS17 (758M), HS22 (287M) -- V202601 |
| omtt_trade_data/trade/ | 3.9 GB | 197 research files |
| omtt_trade_data/papers/ | 44 KB | Research papers |
| pmgai_data/paper_output/ | 125 MB | SCN paper + DOCX |
| gpg_backup/ | 7.2 KB | Private key |

---

## 5. Data Gaps (prioritized)

### Done (2026-03-14)

| Source | For | Status |
|--------|-----|--------|
| UNCTAD (21 indicators) | OMTT | Collector built (WB API fallback) |
| WITS/TRAINS (24 tariff series) | OMTT | Collector built, SDMX API |
| DataHouse (97 concepts) | BDFacts | Done, 15 domains |
| BACI (1.9M rows) | BDFacts | Integrated via baci_db.py |
| IMF (12 concepts + projections) | BDFacts | In DataHouse catalog |
| Frontend data cleanup | BDFacts | 95 real metrics, 85 charts, zero fabrication |
| DSE market cap | BDFacts | Scraped, in static data |
| BMET overseas employment | BDFacts | Scraped, in static data |
| BB MFS data | BDFacts | Scraped, in static data |

### Tier 1: Next priority

| Source | For | Notes |
|--------|-----|-------|
| OECD DAC (aid flows) | OMTT | API confirmed working, no auth, JSON. Ready to build. |
| WTO Tariff API | OMTT | Needs free API key registration at apiportal.wto.org |
| Bangladesh Bank Monthly | Both | Excel/PDF scraping, granular monetary data |
| BBS National Accounts | Both | Quarterly GDP, sectoral VA |

### Tier 2: Future

| Source | For | Notes |
|--------|-----|-------|
| CRU/NOAA climate | OMTT | Monthly temp/precip for BD |
| Nightlights (VIIRS) | Both | Subnational economic proxy |
| MPI (Multidimensional Poverty) | Both | OPHI/UNDP |
| Sovereign credit ratings | Both | S&P/Moody's/Fitch history |

---

## 6. Cross-Project Data Flow

```
                      OECD ICIO (6.4GB)
                           |
                      [CGE/IO/TiVA]
                           |
BACI zips (10GB) --> baci.db (215MB) --> BDFacts DataHouse
                           |                    ^
                      OMTT bdpolicy.db          |
                      (23 collectors)     bangladesh.db
                           |              (7 sources)
                      [publications]            |
                           |              [API endpoints]
                           v                    v
                    bdpolicylab.com        bdfacts.org

TradeWeave trade.db (18GB) --> tradeweave.org
```

**Source of truth**:
- OMTT bdpolicy.db: VPS (collectors run there), push from local for publications
- BDFacts bangladesh.db: local (fetcher scripts), deploy to VPS
- baci.db: OMTT is canonical, copied to BDFacts
- trade.db: local, backed up to OneDrive
- ICIO matrices: local only, derivable from OECD downloads
