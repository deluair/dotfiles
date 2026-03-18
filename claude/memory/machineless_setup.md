---
name: machineless-setup
description: SOTA machineless dev setup - dotfiles repo with symlinked configs, data symlinked to OneDrive, auto machine detection, sit/standup workflow
type: feedback
---

All 6 projects must be machineless: git clone + sign into cloud + one command = running on any machine.

**Why:** User wants full portability. No manual file copying, no forgotten secrets, no "works on my machine" issues.

**How to apply:**

## Stack (do not change without asking)

| Layer | Tool | Notes |
|-------|------|-------|
| Bootstrap | `~/dotfiles` repo | `curl \| bash` from zero |
| System deps | `Brewfile` (macOS), `winget` (Windows) | bootstrap.sh handles both |
| Shell config | `shell/zshrc`, `shell/bashrc`, `shell/gitconfig` | Symlinked. Machine-local overrides in `~/.{zsh,bash}rc.local` |
| Secrets (.env) | git-secret | Encrypted `.env.secret` committed to repo. `git secret reveal` decrypts. |
| Data files | OneDrive symlinks | `install.sh` creates symlinks from project dirs to OneDrive. No copy/restore. |
| Data redundancy | GDrive | `standup` syncs OneDrive to GDrive for disaster recovery. |
| Machine detection | `paths.sh` | Auto-detects macmini, macair, galaxy, dell from hardware. |
| Setup automation | `install.sh` + bash aliases | `sit`/`standup` for daily use. |
| GPG key | `deluair@gmail.com` | Auto-imported during `install.sh`. Backed up to both clouds. |
| Claude memory | `sync-memory.sh` | Synced to dotfiles, deployed on install. |

## New machine workflow

```bash
curl -fsSL https://raw.githubusercontent.com/deluair/dotfiles/main/bootstrap.sh | bash
# Sign into OneDrive + GDrive, reopen terminal
sit
```

## Daily workflow

```bash
sit        # pull, symlink data, clone missing repos, verify
standup    # sync memory, push, GDrive redundancy
dr         # quick health check
```

## Data architecture

- **OneDrive** is the single source of truth for all data (databases, GIS, sensitive files)
- Project dirs have **symlinks** pointing to OneDrive (zero local copies)
- **GDrive** is a redundancy backup (synced during `standup`)
- Storage-tight machines (macmini, macair) skip 18GB trade.db and 5GB+ GIS data
- Uses directory listings (not stat) to check OneDrive (avoids Files On-Demand download triggers)

## Rules

- Every new project gets: `.gitignore`, `git-secret init`, `Makefile`
- After modifying `.env`: pre-commit hook handles encryption automatically
- New data files: add symlink mapping to `install.sh`, checks to `bin/doctor.sh`, GDrive sync to `backup-data.sh`
- Never use git-lfs (decided against it, OneDrive is free and sufficient)
- Large data (>2GB) stays cloud-only: omtt trade data (3.9GB), tradeweave trade.db (18GB)

## Dual cloud backup

- **OneDrive** (UTK): primary source of truth. All data lives here.
- **GDrive** (personal `dulal1986@gmail.com`): redundant. Synced during `standup`.
- GDrive exists so losing the UTK account doesn't lose 18GB+ of trade data

## Projects with git-secret (5/6)

dulalratna, omtt, bddata, trade-explorer, econai (pmgai has no .env)
