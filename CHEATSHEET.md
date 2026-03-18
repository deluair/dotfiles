# Dotfiles Cheatsheet

## Fresh machine

```bash
curl -fsSL https://raw.githubusercontent.com/deluair/dotfiles/main/bootstrap.sh | bash
cd ~/dotfiles && make unlock && make clone-all && make restore && make setup-all
```

If bootstrap fails midway (winget needs admin, etc.), finish manually:
```bash
cd ~/dotfiles
age -d config.sh.age > config.sh
bash install.sh
make clone-all && make restore && make setup-all && make doctor
```

## Daily

```bash
sit        # start of session (pull all repos, merge memory, restore data, doctor)
standup    # end of session (sync memory, push all repos, backup to cloud)
```

## All commands

| Command | What |
|---------|------|
| `sit` | Start session: pull + merge memory + restore + doctor |
| `standup` | End session: sync memory + push all + backup |
| `make doctor` | Verify everything |
| `make clone-all` | Clone all repos |
| `make setup-all` | Install deps, decrypt secrets, verify builds |
| `make restore` | Restore data from cloud |
| `make backup` | Backup data to cloud |
| `make lock` | Encrypt config.sh |
| `make unlock` | Decrypt config.sh |
| `make sites` | Health check all 3 sites |
| `make gpg-import` | Import GPG key from cloud |

## Machines (auto-detected)

| Name | Machine | Storage |
|------|---------|---------|
| macmini | Mac Mini M4, 256GB | tight (skips 18GB trade.db) |
| macair | MacBook Air M4, 256GB | tight (skips 18GB trade.db) |
| galaxy | Samsung Galaxy Book Edge, 512GB | ok |
| dell | Dell Precision 5560, 1TB | ok |

## Add a new project

1. Add repo name to REPOS in `config.sh`
2. Re-encrypt: `make lock`
3. If it has data files, add to `backup-data.sh` and `restore-data.sh`
