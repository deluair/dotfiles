# Project Inventory

## Active Projects
| Project | Dir | Repo | DB File | DB Size |
|---------|-----|------|---------|---------|
| BDPolicyLab | ~/bdpolicylab | deluair/bdpolicylab | data/bdpolicy.db | ~31 MB |
| BDFacts | ~/bdfacts | deluair/bdfacts | backend/data/ (no main db currently) | - |
| TradeWeave | ~/tradeweave | deluair/tradeweave | data/trade.db | ~19 GB |
| BDDB | ~/bddb | deluair/bddb (private) | data/bddb.sqlite | ~48 MB |
| EconAI | ~/econai | deluair/econai | - | - |

## BDDB
- Canonical Bangladesh data layer: 40 collectors, 11,967 series, 204K data points
- 15 BD-native sources (BB, BBS, NBR, BGMEA, DSE, BPDB, Petrobangla, BTRC, BMET, MoF, MRA, SREDA, BANBEIS, DGHS, DMB, BMD)
- 21 international sources (WB, IMF, FRED, Comtrade, ILO, FAO, WHO, etc.)
- CLI: `bddb collect/status/export/serve`
- Imported all BDPolicyLab data via import_bdpolicylab.py

## Database Backups
- Script: `~/backup_dbs.sh`
- Destination: `OneDrive/hossen_storage/db_backups/`
- Keeps `_latest` files + last 5 timestamped copies
- TradeWeave trade.db also at `OneDrive/hossen_storage/trade.db`

## API Keys
- Stored in `~/tradeweave/.env` (master copy)
- FRED, Comtrade, EIA, NOAA, BLS, Census keys available
- BDDB `.env` configured from these
