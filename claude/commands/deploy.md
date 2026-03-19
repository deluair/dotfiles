Deploy $ARGUMENTS to VPS. Follow this checklist strictly, report status at each step:

1. **Pre-flight**: Identify the project (tradeweave, bdfacts, bdpolicylab). Read its deploy.sh.
2. **Local build**: Run the project's build command (`npm run build` or equivalent). Fix any errors before proceeding.
3. **Grep for stale refs**: After any recent refactors, grep for removed/renamed variables or imports. Fix before deploying.
4. **SSH check**: Verify SSH connectivity to VPS (`$VPS_HOST` from `~/dotfiles/config.sh`). If it fails, stop and report.
5. **Deploy**: Run the project's `deploy.sh`. Use `npm install` (NOT `npm ci`) for Node projects.
6. **WAL cleanup**: If deploying database files, remove stale WAL/SHM files on VPS.
7. **Health check**: Hit the project's health endpoint and at least one key API route. Report response status.
8. **Report**: Summarize what was deployed and verified.

If any step fails, diagnose the root cause and fix it. Do not retry blindly. If stuck after 2 attempts, stop and ask for direction.
