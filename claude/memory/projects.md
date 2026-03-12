# Project Inventory

## Active Projects
| Project | Dir | Repo | DB File | DB Size |
|---------|-----|------|---------|---------|
| OMTT | ~/omtt | deluair/omtt | data/bdpolicy.db | ~31 MB |
| BDFacts | ~/bddata | deluair/bddata | backend/data/ (no main db currently) | - |
| TradeWeave | ~/trade-explorer | deluair/trade-explorer | data/trade.db | ~19 GB |
| BDDB | ~/bddb | deluair/bddb (private) | data/bddb.sqlite | ~48 MB |
| EconAI | ~/econai | deluair/econai | - | - |

## BDDB
- Canonical Bangladesh data layer: 40 collectors, 11,967 series, 204K data points
- 15 BD-native sources (BB, BBS, NBR, BGMEA, DSE, BPDB, Petrobangla, BTRC, BMET, MoF, MRA, SREDA, BANBEIS, DGHS, DMB, BMD)
- 21 international sources (WB, IMF, FRED, Comtrade, ILO, FAO, WHO, etc.)
- CLI: `bddb collect/status/export/serve`
- Imported all OMTT data via import_omtt.py

## Database Backups
- Script: `~/backup_dbs.sh`
- Destination: `OneDrive/hossen_storage/db_backups/`
- Keeps `_latest` files + last 5 timestamped copies
- TradeWeave trade.db also at `OneDrive/hossen_storage/trade.db`

## API Keys
- Stored in `~/trade-explorer/.env` (master copy)
- FRED, Comtrade, EIA, NOAA, BLS, Census keys available
- BDDB `.env` configured from these
