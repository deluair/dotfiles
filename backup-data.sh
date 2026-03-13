#!/bin/bash
# Redundant incremental backup: critical data to OneDrive + Google Drive.
# Uses rsync --update to skip unchanged files (mtime+size check).
set -e

ONEDRIVE="$HOME/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage"
GDRIVE="$HOME/Library/CloudStorage/GoogleDrive-dulal1986@gmail.com/My Drive/dev_backups"

ERRORS=0

backup() {
    local label="$1" src="$2" onedrive_dest="$3" gdrive_dest="$4"
    if [ ! -f "$src" ]; then
        echo "  SKIP  $label (source missing)"
        return
    fi
    local size
    size=$(du -h "$src" | cut -f1)
    for dest in "$onedrive_dest" "$gdrive_dest"; do
        mkdir -p "$(dirname "$dest")"
        if rsync -u --progress "$src" "$dest" 2>/dev/null; then
            :
        else
            echo "  FAIL  $label -> $dest"
            ERRORS=$((ERRORS + 1))
        fi
    done
    echo "  OK    $label ($size)"
}

echo "Incremental backup: $(date '+%Y-%m-%d %H:%M')"
echo ""

# Databases
backup "trade.db" \
    "$HOME/trade-explorer/data/trade.db" \
    "$ONEDRIVE/db_backups/trade.db" \
    "$GDRIVE/db_backups/trade.db"

backup "tradeweave app.db" \
    "$HOME/trade-explorer/data/app.db" \
    "$ONEDRIVE/db_backups/tradeweave_app_latest.db" \
    "$GDRIVE/db_backups/tradeweave_app_latest.db"

backup "bangladesh.db" \
    "$HOME/bddata/backend/data/bangladesh.db" \
    "$ONEDRIVE/db_backups/bddb_latest.sqlite" \
    "$GDRIVE/db_backups/bddb_latest.sqlite"

backup "bdpolicy.db" \
    "$HOME/omtt/data/bdpolicy.db" \
    "$ONEDRIVE/db_backups/omtt_bdpolicy_latest.db" \
    "$GDRIVE/db_backups/omtt_bdpolicy_latest.db"

backup "bangladesh.db (omtt)" \
    "$HOME/omtt/data/bangladesh.db" \
    "$ONEDRIVE/db_backups/omtt_bangladesh_latest.db" \
    "$GDRIVE/db_backups/omtt_bangladesh_latest.db"

backup "baci.db" \
    "$HOME/omtt/data/baci.db" \
    "$ONEDRIVE/db_backups/omtt_baci_latest.db" \
    "$GDRIVE/db_backups/omtt_baci_latest.db"

backup "me.db" \
    "$HOME/dulalratna/me.db" \
    "$ONEDRIVE/db_backups/dulalratna_me_latest.db" \
    "$GDRIVE/db_backups/dulalratna_me_latest.db"

# Sensitive files (GPG, env)
echo ""
echo "Syncing sensitive files..."
mkdir -p "$GDRIVE/sensitive/gpg_backup"
rsync -au "$ONEDRIVE/gpg_backup/" "$GDRIVE/sensitive/gpg_backup/" 2>/dev/null && echo "  OK    GPG backup" || echo "  SKIP  GPG backup"

for f in dulalratna_sensitive/env.txt econai_sensitive/env.txt; do
    if [ -f "$ONEDRIVE/$f" ]; then
        mkdir -p "$GDRIVE/sensitive/$(dirname "$f")"
        rsync -u "$ONEDRIVE/$f" "$GDRIVE/sensitive/$f" 2>/dev/null
    fi
done
echo "  OK    env files"

echo ""
if [ "$ERRORS" -gt 0 ]; then
    echo "Completed with $ERRORS errors."
    exit 1
fi
echo "All backups current. OneDrive + GDrive."
