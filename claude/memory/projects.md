# Project Inventory

## Active Projects
| Project | Dir | Repo | DB File | DB Size |
|---------|-----|------|---------|---------|
| OMTT | ~/bdpolicylab | deluair/bdpolicylab | data/bdpolicy.db | ~31 MB |
| BDFacts | ~/bdfacts | deluair/bdfacts | backend/data/ (no main db currently) | - |
| TradeWeave | ~/tradeweave | deluair/tradeweave | data/trade.db | ~19 GB |
| BDDB | ~/bddb | deluair/bddb (private) | data/bddb.sqlite | ~48 MB |
## Database Backups
- Script: `~/backup_dbs.sh`
- Destination: `OneDrive/hossen_storage/db_backups/`
- Keeps `_latest` files + last 5 timestamped copies
- TradeWeave trade.db also at `OneDrive/hossen_storage/trade.db`

## API Keys
- Stored in `~/tradeweave/.env` (master copy)
- FRED, Comtrade, EIA, NOAA, BLS, Census keys available
- BDDB `.env` configured from these
