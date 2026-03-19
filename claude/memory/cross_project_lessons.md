---
name: cross_project_lessons
description: Shared lessons across BDFacts, TradeWeave, and BDPolicyLab that apply to all three projects
type: feedback
---

# Cross-Project Shared Lessons

These patterns apply to all three projects (BDFacts, TradeWeave, BDPolicyLab). Per-project lessons are in each project's `tasks/lessons.md`.

## Data Integrity (CRITICAL)

- [CRITICAL] **No mock data.** Every data point from a real, verifiable source. No placeholder or fake data in production. If unavailable, show "data unavailable". This is the #1 historical bug across all projects.
- [CRITICAL] **No hallucination.** AI-generated content (Gemini, Claude) must be grounded in real data. No fabricated statistics, citations, or claims.
- [CRITICAL] **No shady things.** No dark patterns, no deceptive metrics, no inflated counters, no misleading visualizations. Trust is the product.

## Database Operations

- [HIGH] **WAL/SHM cleanup on DB replacement.** Before and after replacing a `.db` file on VPS: `rm -f *.db-wal *.db-shm`. Stale WAL files cause corruption or stale reads.
- [HIGH] **DB files are gitignored.** All `.db` files live on VPS, backed up to OneDrive. Never commit them.

## Deploy Safety

- [HIGH] **Always build locally before deploying.** Past deploys pushed unbuildable code. Run `npm run build` (JS) or `pytest` (Python) before any deploy.
- [HIGH] **npm ci fails on VPS** due to cross-platform lockfile incompatibility. Use `npm install --force` (TradeWeave) or `npm install --legacy-peer-deps` (BDFacts).
- [HIGH] **All three projects use deploy.sh.** Each has project-specific exclusions. Check deploy.sh before modifying deploy behavior.
- [HIGH] **VPS is OVH** (`vps-45aafae5.vps.ovh.us`, user `ubuntu`). SSH key auth. Do not switch to password auth.

## Security

- [CRITICAL] **.env never committed.** All API keys in `.env` (gitignored). Use git-secret for encrypted `.env.secret` in repo.
- [CRITICAL] **Grep for secrets before committing.** Past credential leak in BDFacts (commit f51f7f8). Search for API keys, passwords, IPs.

## Branding

- [HIGH] **Signature watermarks (6-layer) are in place** across all three projects. The `del` marker is the common thread. Do not remove or modify without explicit request.
- [HIGH] **Cross-reference footer links** between BDFacts, TradeWeave, and BDPolicyLab. Keep in sync when any project's URL or branding changes.

## Workflow

- [HIGH] **Max 10 parallel agents.** Never launch more than 10 at once. Batch in waves, write results to /tmp between waves.
- [HIGH] **Large file transfers: think first.** Never naive scp for >1GB. Use rsync with keepalive and resume. Consider if transfer is even necessary.
- [HIGH] **After ANY correction: update tasks/lessons.md** with the pattern. This is how projects learn.
