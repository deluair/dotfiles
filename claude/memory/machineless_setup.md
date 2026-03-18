---
name: machineless-setup
description: SOTA machineless dev setup - dotfiles repo with Brewfile, symlinked configs, dual cloud backup (OneDrive + GDrive), auto GPG import, curl bootstrap
type: feedback
---

All 6 projects must be machineless: git clone + one command = running on any machine.

**Why:** User wants full portability. No manual file copying, no forgotten secrets, no "works on my machine" issues.

**How to apply:**

## Stack (do not change without asking)

| Layer | Tool | Notes |
|-------|------|-------|
| Bootstrap | `~/dotfiles` repo | `curl \| bash` or `make all` from zero |
| System deps | `Brewfile` | `make brew` installs git, node, uv, gpg, gh, casks |
| Shell config | `shell/zshrc`, `shell/gitconfig` | Symlinked. Machine-local overrides in `~/.zshrc.local` |
| Secrets (.env) | git-secret | Encrypted `.env.secret` committed to repo. `git secret reveal` decrypts. |
| Pre-commit | auto `git secret hide` | Hook in `.git/hooks/pre-commit`. |
| Data sync | OneDrive + GDrive + `backup.sh`/`restore.sh` | Dual cloud, incremental rsync |
| Setup automation | `Makefile` | `make setup` = restore + decrypt + install. |
| GPG key | `deluair@gmail.com` | Auto-imported during `make install`. Backed up to both clouds. |
| Claude memory | `sync-memory.sh` | Synced to dotfiles, deployed on install. |

## New machine workflow

```bash
curl -fsSL https://raw.githubusercontent.com/deluair/dotfiles/main/bootstrap.sh | bash
make clone-all    # clone all 7 repos
make restore      # pull data from OneDrive/GDrive
make doctor       # verify everything (7 categories)
```

## Key make targets

| Target | What |
|--------|------|
| `make all` | brew + install (full setup) |
| `make doctor` | verify prereqs, cloud, configs, GPG, data, backups, memory |
| `make push` | sync Claude memory + commit + push dotfiles |
| `make backup` | incremental rsync to OneDrive + GDrive |
| `make restore` | restore data from cloud (OneDrive primary, GDrive fallback) |
| `make sites` | health check all 3 sites |
| `make clone-all` | clone all 7 repos |
| `make gpg-import` | import GPG key from cloud |

## Rules

- Every new project gets: `.gitignore`, `git-secret init`, `restore.sh`, `backup.sh`, `Makefile`
- After modifying `.env`: pre-commit hook handles encryption automatically
- After modifying gitignored data: run `make backup`
- Never use git-lfs (decided against it, OneDrive is free and sufficient)
- Large data (>2GB) stays cloud-only: omtt trade data (3.9GB), tradeweave trade.db (18GB)
- New data files: update `backup-data.sh`, `restore-data.sh`, and Makefile doctor checks

## Dual cloud backup

- **OneDrive** (UTK): primary. `~/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage/`
- **GDrive** (personal `dulal1986@gmail.com`): redundant. `~/GDrive/My Drive/dev_backups/`
- GDrive exists so losing the UTK account doesn't lose 18GB+ of trade data

## Projects with git-secret (5/6)

dulalratna, omtt, bddata, trade-explorer, econai (pmgai has no .env)
