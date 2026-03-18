# Dotfiles Cheatsheet

## Fresh machine

```bash
curl -fsSL https://raw.githubusercontent.com/deluair/dotfiles/main/bootstrap.sh | bash
```

Then close and reopen Git Bash (or Terminal), sign into OneDrive + GDrive, then:
```bash
sit
```

That's it. Machine auto-detected, repos cloned, data symlinked from OneDrive.

If bootstrap fails midway:
```bash
cd ~/dotfiles
age -d config.sh.age > config.sh
bash install.sh
bash bin/clone-all.sh
bash bin/doctor.sh
```

## Daily

```bash
sit        # start of session: pull, symlink data, clone missing repos, verify
standup    # end of session: sync memory, push, GDrive redundancy
dr         # quick health check
```

## Machines (auto-detected)

| Name | Machine | Storage |
|------|---------|---------|
| macmini | Mac Mini M4, 256GB | tight (skips 18GB trade.db) |
| macair | MacBook Air M4, 256GB | tight (skips 18GB trade.db) |
| galaxy | Samsung Galaxy Book Edge, 512GB | ok |
| dell | Dell Precision 5560, 1TB | ok |

## Data architecture

- **OneDrive** is the source of truth for all data files
- Project dirs have **symlinks** pointing to OneDrive (no local copies)
- **GDrive** is a redundancy backup (synced during `standup`)
- No `restore` step needed. `install.sh` creates symlinks.

## Add a new project

1. Add repo name to REPOS in `config.sh`
2. Re-encrypt: `cd ~/dotfiles && age -p config.sh > config.sh.age`
3. If it has data files, add symlink mapping to `install.sh` and checks to `bin/doctor.sh`
