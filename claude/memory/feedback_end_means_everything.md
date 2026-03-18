---
name: end-means-everything
description: "end" = commit + push + deploy + backup check + dotfiles push. Do ALL steps without asking.
type: feedback
---

When user says "end", do the FULL sequence without asking:
1. `git add` + `git commit` all changes in the active project
2. `git push`
3. Run `./deploy.sh` (or project-specific deploy)
4. Check if any new gitignored data was created this session; if so, backup to OneDrive
5. `make -C ~/dotfiles push`

**Why:** User had to correct twice because I only did step 5. The word "end" is unambiguous. Do not ask for confirmation, do not do partial steps. Execute the full sequence.

**How to apply:** Any time the user says "end", "done", or "wrap up", execute all 5 steps for the current project directory.
