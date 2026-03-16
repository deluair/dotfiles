---
name: Session start/end dotfiles workflow
description: When user says "start" run dotfiles pull, when user says "end" run dotfiles push. No cheatsheet needed, just do it.
type: feedback
---

User has a dotfiles-based multi-machine workflow. They don't want to remember commands.

**When user says "start" (beginning of session):**
```bash
make -C ~/dotfiles pull
```
This pulls dotfiles + all repos + restores data from OneDrive.

**When user says "end" (ending session):**
```bash
make -C ~/dotfiles push
```
This syncs Claude memory + pushes dotfiles + all repos.

**Why:** User works across 4 machines (Mac Mini M4, MacBook Air M4, Galaxy Book Edge, Dell Precision 5560). The dotfiles Makefile handles all sync. User doesn't want to remember the commands.

**How to apply:** Listen for "start" or "end" as session bookend signals in ANY project, on ANY machine. This is a global instruction, not project-specific. Run the appropriate make command immediately without asking. Also run `make -C ~/dotfiles backup` if user says "backup" or it's been a while.

**Dotfiles location:** `~/dotfiles` (repo: `deluair/dotfiles`)
**Age passphrase:** stage-build-girl-license-benefit-mountain-disorder-marriage-board-fold
**All project repos:** omtt, bddata, trade-explorer, dulalratna, pmgai, econai, hossen
