---
name: tradeweave-vps-layout
description: TradeWeave VPS file paths, PM2 config, and trade.db symlink setup
type: reference
---

TradeWeave VPS layout (as of 2026-03-19):

- **PM2 app cwd**: `/opt/tradeweave/app/` (runs `npm start`, Next.js on port 3000)
- **DB location**: `/home/ubuntu/trade_explainer/data/trade.db` (19GB, immutable)
- **Symlink**: `/opt/tradeweave/data/trade.db` -> `/home/ubuntu/trade_explainer/data/trade.db`
- **App DB**: `/opt/tradeweave/data/app.db` (symlinked similarly)
- **IMF DB**: `/opt/tradeweave/data/imf.db` (724MB, at `/opt/tradeweave/data/`)
- **DB path in code**: `path.join(process.cwd(), "..", "data", "trade.db")` (relative to app cwd)
- **rclone configured**: `gdrive:` remote on VPS for Google Drive access (token may expire)
- **Google Drive backup**: `gdrive:trade.db` (root of Google Drive, dulal1986@gmail.com)
