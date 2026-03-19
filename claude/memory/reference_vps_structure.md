---
name: vps-structure
description: Full VPS directory layout, running services, DB files, and nginx sites (as of 2026-03-19)
type: reference
---

## Services

| Service | Type | Port | Directory |
|---------|------|------|-----------|
| tradeweave | PM2 / Next.js | 3000 | cwd: `/opt/tradeweave/app/`, code: `/home/ubuntu/trade_explainer/trade-explorer/` |
| bdfacts | systemd / uvicorn | 8000 | `/home/ubuntu/bddata-backend/` |
| bdpolicylab | systemd / uvicorn | 8001 | `/home/ubuntu/bdpolicylab/` |
| dulalratna-bot | systemd | - | `/home/ubuntu/dulalratna/` |

Nginx sites-enabled: `bddata`, `bdpolicylab`, `tradeweave`, `aram-gp-care`, `00-default-catchall`

## DB Files

| File | Size | Project | Notes |
|------|------|---------|-------|
| `/home/ubuntu/trade_explainer/data/trade.db` | 19GB | TradeWeave | IMMUTABLE (`chattr +i`, `chmod 444`) |
| `/opt/tradeweave/data/imf.db` | 691MB | TradeWeave | |
| `/home/ubuntu/bddata-backend/data/baci.db` | 215MB | BDFacts | |
| `/var/www/bddata/backend/data/baci.db` | 215MB | BDFacts | duplicate of above |
| `/home/ubuntu/bdpolicylab/data/bdpolicy.db` | 102MB | BDPolicyLab | |
| `/home/ubuntu/trade_explainer/data/app.db` | 80KB | TradeWeave | |
| `/home/ubuntu/bdpolicylab/data/govtwin.db` | 72KB | BDPolicyLab | |
| `/var/www/bddata/backend/wdi.db` | 56KB | BDFacts | |
| `/var/www/bddata/backend/analytics.db` | 1.3MB | BDFacts | |
| `/home/ubuntu/bdpolicylab/data/icio/v2025/metadata.db` | 52KB | BDPolicyLab | |
| `/home/ubuntu/dulalratna/me.db` | 484KB | DulalRatna | |
| `/home/ubuntu/backups/*.db` | 85MB total | All | Mar 7 snapshots |

## Symlinks (TradeWeave)

- `/opt/tradeweave/data/trade.db` -> `/home/ubuntu/trade_explainer/data/trade.db`
- `/opt/tradeweave/data/app.db` -> `/home/ubuntu/trade_explainer/data/app.db`
- `/opt/tradeweave/app/data/trade.db` -> `/opt/tradeweave/data/trade.db` (chained)

## Key Directories

- `/home/ubuntu/trade_explainer/` - TradeWeave source + data
- `/opt/tradeweave/` - TradeWeave production deploy (PM2 cwd)
- `/home/ubuntu/bddata-backend/` - BDFacts FastAPI backend
- `/var/www/bddata/` - BDFacts frontend + backend copy
- `/home/ubuntu/bdpolicylab/` - BDPolicyLab FastAPI backend
- `/home/ubuntu/dulalratna/` - Life OS Telegram bot
- `/home/ubuntu/health_center/` - stale, not in any service (1.3GB)
- `/home/ubuntu/aram-gp-care/` - stale, removed from PM2 (998MB)
- `/home/ubuntu/backups/` - manual DB snapshots (85MB)

## Disk

72GB total, ~31GB free (58% used as of 2026-03-19)

## Tools Installed

- rclone: configured with `gdrive:` remote (Google Drive, dulal1986@gmail.com). Token may need refresh.
