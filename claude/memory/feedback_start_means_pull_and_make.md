---
name: feedback_start_means_pull_and_make
description: "start" command means git pull all repos AND run make setup/install for all projects
type: feedback
---

When user says "start", do both:
1. `git pull` all repos (dotfiles, bdpolicylab, bdfacts, tradeweave, dulalratna)
2. Run `make setup` (or equivalent setup target) for each project after pulling

**Why:** Machineless workflow. Pulling code is only half the job; deps and secrets also need syncing.

**How to apply:** Every session start, do both steps automatically without asking.
