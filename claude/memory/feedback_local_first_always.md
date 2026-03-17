---
name: feedback_local_first_always
description: ALWAYS work locally first, test, then push/deploy to VPS. Never edit files directly on VPS.
type: feedback
---

ALWAYS work local-first. Never edit files directly on VPS via SSH.

**Why:** User has explicitly corrected this multiple times. VPS SSH is slow, debugging remotely is painful, and changes made directly on VPS get lost on next deploy. Local iteration is faster.

**How to apply:**
1. Make all code changes locally in the project directory
2. Test/verify locally (run dev server, check imports, run tests)
3. Commit and push to git
4. Deploy via deploy.sh or scp changed files
5. Verify on production after deploy
6. NEVER use `ssh ... "sed ..."` or `ssh ... "cat > file"` to edit code on VPS
7. Only SSH for: checking logs, restarting services, verifying state, downloading data
