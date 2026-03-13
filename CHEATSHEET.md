# Dotfiles Cheatsheet

## First time on a new machine

```bash
curl -fsSL https://raw.githubusercontent.com/deluair/dotfiles/main/bootstrap.sh | bash
cd ~/dotfiles
make unlock           # decrypt config.sh (passphrase required)
make clone-all        # clone all repos
make restore          # pull databases from OneDrive/GDrive
make setup-all        # install deps, decrypt secrets, verify builds
make doctor           # verify everything
```

On Windows, to enable `make` in CMD/PowerShell, copy the MSYS2 make.exe:
```
mkdir C:\tools   (if needed, add to PATH)
copy C:\Users\%USERNAME%\.local\bin\make.exe C:\tools\make.exe
```
Create `C:\tools\make.cmd`:
```
@"C:\Program Files\Git\bin\bash.exe" -lc "make \"$@\"" _ %*
```

## Daily workflow

```bash
# Sit down (any machine)
make -C ~/dotfiles pull

# Stand up (any machine)
make -C ~/dotfiles push
```

## Weekly

```bash
make -C ~/dotfiles backup
```

## Add a new project

1. Edit `~/dotfiles/config.sh`, add repo name to REPOS:
```bash
REPOS="omtt bddata trade-explorer dulalratna pmgai econai hossen NEW-REPO"
```

2. Re-encrypt config: `make -C ~/dotfiles lock`

3. If it has data files, add entries to:
   - `~/dotfiles/backup-data.sh`
   - `~/dotfiles/restore-data.sh`

## All commands

| Command | Description |
|---------|-------------|
| `make doctor` | Verify everything (prereqs, cloud, configs, GPG, data, commands) |
| `make pull` | Sit down: pull dotfiles + repos + restore data |
| `make push` | Stand up: sync memory + push dotfiles + repos |
| `make setup-all` | Install deps, decrypt secrets, verify builds for all projects |
| `make clone-all` | Clone all project repos |
| `make restore` | Restore data from cloud (OneDrive primary, GDrive fallback) |
| `make backup` | Incremental backup to OneDrive + GDrive |
| `make lock` | Encrypt config.sh with age |
| `make unlock` | Decrypt config.sh.age with age |
| `make sites` | Health check all 3 sites |
| `make gpg-import` | Import GPG key from cloud |
| `make vps-pull` | Pull VPS database backups |
| `make sync` | Sync Claude memory to dotfiles |
