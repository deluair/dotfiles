# Deploy All Projects

Deploy one or all projects to the OVH VPS.

## Quick Deploy (specify project)
If user says "deploy bdfacts":
- `cd ~/bdfacts && bash scripts/deploy.sh`

If user says "deploy bdpolicylab" or "deploy omtt":
- `cd ~/bdpolicylab` and follow OMTT deploy process

If user says "deploy tradeweave":
- `cd ~/tradeweave && bash scripts/deploy.sh`

## Full Deploy (all 3)
Run sequentially (they share the same VPS):

1. **BDFacts**: `cd ~/bdfacts && npm run build && bash scripts/deploy.sh --skip-build`
2. **TradeWeave**: `cd ~/tradeweave && npm run build && bash scripts/deploy.sh --skip-build`
3. **OMTT**: `cd ~/bdpolicylab` and deploy (FastAPI + static)

## Post-Deploy Verification
After each deploy:
1. Health check: `curl -s https://{domain}/api/health`
2. Spot check: load homepage in browser or take screenshot
3. Check for stale cache: verify new asset hashes in page source

## VPS Info
- Host: `vps-45aafae5.vps.ovh.us`
- User: `ubuntu`
- Frontend paths: `/var/www/{project}/dist/`
- Backend services: systemd (`bdfacts-backend`, etc.)
- Nginx manages all 3 domains
