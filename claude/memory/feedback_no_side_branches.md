---
name: no-side-branches
description: No feature branches. All work on main. No side branches unless explicitly requested.
type: feedback
---

No feature branches. All work goes directly on main.

**Why:** Feature branches were left stale on both tradeweave and bdpolicylab (2026-03-19), causing merge conflicts and confusion when merging back. Solo developer workflow doesn't benefit from branch isolation.

**How to apply:**
- Never create feature/fix/data branches unless user explicitly asks
- Commit directly to main
- If a branch already exists, merge it to main and delete it immediately
- Delete remote branches after merge too
