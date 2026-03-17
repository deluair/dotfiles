---
name: feedback_local_first_always
description: ABSOLUTE PRIORITY. Test locally first, never waste time on VPS. Smart time management. No retrying blindly.
type: feedback
---

ABSOLUTE PRIORITY RULE. Test and verify EVERYTHING locally before touching VPS.

**Why:** The 2026-03-16 session wasted massive time: stuck VPS generation, zombie processes locking SQLite, shell quoting failures, multiple failed SSH attempts. Every single issue would have been caught in seconds locally. User explicitly said "always be smart about time" and "do local first, then vps" and "smart time, and local first."

**How to apply:**
1. Make all code changes locally
2. Test imports locally (`uv run python -c "from app.main import app"`)
3. Run tests locally (`pytest`)
4. Generate/verify output locally before deploying
5. Only THEN deploy: one combined command (rsync + pip install + generate + restart + health check)
6. NEVER retry blindly on VPS. If VPS fails, come back to local, fix, re-test, then redeploy.
7. NEVER run multiple sequential SSH commands when one combined command works
8. NEVER use TaskOutput polling loops. If something takes long, investigate why, don't wait.
9. Kill zombie processes on VPS before running anything (check `ps aux | grep python`)
10. Clean WAL/SHM files before DB operations on VPS
