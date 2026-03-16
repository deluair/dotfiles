# Deploy All Projects

Deploy one or all projects to the OVH VPS.

## Quick Deploy (specify project)
If user says "deploy bddata" or "deploy bdfacts":
- `cd ~/bddata && bash scripts/deploy.sh`

If user says "deploy omtt" or "deploy bdpolicylab":
- `cd ~/omtt` and follow OMTT deploy process

If user says "deploy trade-explorer" or "deploy tradeweave":
- `cd ~/trade-explorer && bash scripts/deploy.sh`

## Full Deploy (all 3)
Run sequentially (they share the same VPS):

1. **BDFacts**: `cd ~/bddata && npm run build && bash scripts/deploy.sh --skip-build`
2. **TradeWeave**: `cd ~/trade-explorer && npm run build && bash scripts/deploy.sh --skip-build`
3. **OMTT**: `cd ~/omtt` and deploy (FastAPI + static)

## Post-Deploy Verification
After each deploy:
1. Health check: `curl -s https://{domain}/api/health`
2. Spot check: load homepage in browser or take screenshot
3. Check for stale cache: verify new asset hashes in page source

## VPS Info
- Host: `vps-45aafae5.vps.ovh.us`
- User: `ubuntu`
- Frontend paths: `/var/www/{project}/dist/`
- Backend services: systemd (`bddata-backend`, etc.)
- Nginx manages all 3 domains
