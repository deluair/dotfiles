---
name: feedback_branches
description: No unnecessary git branches, merge and delete feature branches promptly
type: feedback
---

No unnecessary branches. After merging a feature branch, delete it immediately (local + remote). Keep only `main`.

**Why:** Stale branches confuse the system and clutter the repo. User prefers a clean single-branch state.

**How to apply:** After any merge to main, always delete the source branch (both `git push origin --delete <branch>` and `git branch -d <branch>`, then `git remote prune origin`). Don't leave feature branches lingering.
