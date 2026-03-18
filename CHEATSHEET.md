# Dotfiles Cheatsheet

## Fresh machine

```bash
curl -fsSL https://raw.githubusercontent.com/deluair/dotfiles/main/bootstrap.sh | bash
```

Then close and reopen Git Bash, then:
```bash
sit
```

If bootstrap fails midway:
```bash
cd ~/dotfiles
age -d config.sh.age > config.sh
bash install.sh
bash bin/clone-all.sh
bash restore-data.sh
bash setup-projects.sh
bash bin/doctor.sh
```

## Daily

```bash
sit        # start of session
standup    # end of session
dr         # quick health check
```

## Machines (auto-detected)

| Name | Machine | Storage |
|------|---------|---------|
| macmini | Mac Mini M4, 256GB | tight (skips 18GB trade.db) |
| macair | MacBook Air M4, 256GB | tight (skips 18GB trade.db) |
| galaxy | Samsung Galaxy Book Edge, 512GB | ok |
| dell | Dell Precision 5560, 1TB | ok |

## Add a new project

1. Add repo name to REPOS in `config.sh`
2. Re-encrypt: `cd ~/dotfiles && age -p config.sh > config.sh.age`
3. If it has data files, add to `backup-data.sh` and `restore-data.sh`
