# VPS Deployment Info

- **Provider**: OVH VPS
- **Host**: ubuntu@40.160.2.223
- **Auth**: SSH key (password removed for security)
- **App path**: /opt/tradeweave/app
- **Data path**: /opt/tradeweave/data
- **trade.db**: Symlinked from /opt/tradeweave/data/trade.db → /opt/tradeweave/app/data/trade.db
- **Process manager**: PM2 (name: tradeweave)
- **Deploy script**: deploy.sh --full (syncs DB too)
- **Domain**: tradeweave.org (Cloudflare DNS/SSL)

## Notes
- After replacing trade.db, always remove stale WAL/SHM files: `rm -f /opt/tradeweave/data/trade.db-wal /opt/tradeweave/data/trade.db-shm`
- npm ci fails on VPS due to Windows lockfile; use `npm install --force` instead
