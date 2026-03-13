---
name: machineless-setup
description: Complete machineless dev setup across all 6 projects - git-secret, OneDrive backup/restore, Makefiles, pre-commit hooks, GPG key
type: feedback
---

All 6 projects must be machineless: git clone + one command = running on any machine.

**Why:** User wants full portability. No manual file copying, no forgotten secrets, no "works on my machine" issues.

**How to apply:**

## Stack (do not change without asking)

| Layer | Tool | Notes |
|-------|------|-------|
| Secrets (.env) | git-secret | Encrypted `.env.secret` committed to repo. `git secret reveal` decrypts. |
| Pre-commit | auto `git secret hide` | Hook in `.git/hooks/pre-commit`. Never forget to re-encrypt. |
| Data sync | OneDrive + `restore.sh` / `backup.sh` | Free via UTK account. No git-lfs (not worth $5/mo). |
| Setup automation | `Makefile` | `make setup` = restore + decrypt + install. `make run` starts app. |
| GPG key | `deluair@gmail.com` | Fingerprint: 8A4821AE71E9AB760CD4BCB845AA56DF3876E02B. Backed up to OneDrive `gpg_backup/`. |

## New machine workflow

```bash
# 1. Import GPG key (one-time)
gpg --import ~/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage/gpg_backup/deluair_private.asc

# 2. Per project
git clone git@github.com:deluair/<repo>.git
cd <repo>
make setup
```

## Rules

- Every new project gets: `.gitignore`, `git-secret init`, `restore.sh`, `backup.sh`, `Makefile`
- After modifying `.env`: pre-commit hook handles encryption automatically
- After modifying gitignored data: run `make backup` or `./backup.sh`
- Never use git-lfs (decided against it, OneDrive is free and sufficient)
- Large data (>2GB) stays OneDrive-only: omtt trade data (3.9GB), tradeweave trade.db (18GB)

## Projects with git-secret (5/6)

dulalratna, omtt, bddata, trade-explorer, econai (pmgai has no .env)
