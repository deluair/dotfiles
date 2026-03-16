#!/bin/bash
# Redundant incremental backup: critical data to OneDrive + Google Drive.
# Cross-platform: macOS, Windows (Git Bash), Linux.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/paths.sh"

ERRORS=0

backup() {
    local label="$1" src="$2" onedrive_dest="$3" gdrive_dest="$4"
    if [ ! -f "$src" ]; then
        echo "  SKIP  $label (source missing)"
        return
    fi
    local size
    size=$(du -h "$src" | cut -f1)
    # OneDrive
    if [ -n "$onedrive_dest" ] && [ -d "$(dirname "$ONEDRIVE")" ]; then
        mkdir -p "$(dirname "$onedrive_dest")"
        copy_with_progress "$src" "$onedrive_dest" 2>/dev/null || { echo "  FAIL  $label -> OneDrive"; ERRORS=$((ERRORS + 1)); }
    fi
    # GDrive
    if [ -n "$gdrive_dest" ] && [ -n "$GDRIVE" ] && [ -d "$(dirname "$GDRIVE")" ]; then
        mkdir -p "$(dirname "$gdrive_dest")"
        copy_with_progress "$src" "$gdrive_dest" 2>/dev/null || { echo "  FAIL  $label -> GDrive"; ERRORS=$((ERRORS + 1)); }
    fi
    echo "  OK    $label ($size)"
}

echo "Incremental backup ($OS): $(date '+%Y-%m-%d %H:%M')"
echo ""

P="$PROJECTS_DIR"

backup "trade.db" \
    "$P/trade-explorer/data/trade.db" \
    "$ONEDRIVE/db_backups/trade.db" \
    "$GDRIVE/db_backups/trade.db"

backup "tradeweave app.db" \
    "$P/trade-explorer/data/app.db" \
    "$ONEDRIVE/db_backups/tradeweave_app_latest.db" \
    "$GDRIVE/db_backups/tradeweave_app_latest.db"

backup "bangladesh.db" \
    "$P/bddata/backend/data/bangladesh.db" \
    "$ONEDRIVE/db_backups/bddb_latest.sqlite" \
    "$GDRIVE/db_backups/bddb_latest.sqlite"

backup "bdpolicy.db" \
    "$P/omtt/data/bdpolicy.db" \
    "$ONEDRIVE/db_backups/omtt_bdpolicy_latest.db" \
    "$GDRIVE/db_backups/omtt_bdpolicy_latest.db"

backup "bangladesh.db (omtt)" \
    "$P/omtt/data/bangladesh.db" \
    "$ONEDRIVE/db_backups/omtt_bangladesh_latest.db" \
    "$GDRIVE/db_backups/omtt_bangladesh_latest.db"

backup "baci.db" \
    "$P/omtt/data/baci.db" \
    "$ONEDRIVE/db_backups/omtt_baci_latest.db" \
    "$GDRIVE/db_backups/omtt_baci_latest.db"

backup "me.db" \
    "$P/dulalratna/me.db" \
    "$ONEDRIVE/db_backups/dulalratna_me_latest.db" \
    "$GDRIVE/db_backups/dulalratna_me_latest.db"

# Directory backups (rsync incremental)
echo ""
echo "Directory backups..."

backup_dir() {
    local label="$1" src="$2" dest="$3"
    if [ ! -d "$src" ]; then
        echo "  SKIP  $label (source missing)"
        return
    fi
    mkdir -p "$dest"
    if command -v rsync &>/dev/null; then
        rsync -au --delete "$src/" "$dest/" 2>/dev/null || { echo "  FAIL  $label"; ERRORS=$((ERRORS + 1)); return; }
    else
        cp -ru "$src/"* "$dest/" 2>/dev/null || { echo "  FAIL  $label"; ERRORS=$((ERRORS + 1)); return; }
    fi
    local size
    size=$(du -sh "$src" | cut -f1)
    echo "  OK    $label ($size)"
}

backup_dir "bd_gis/outputs" \
    "$P/omtt/bd_gis/outputs" \
    "$ONEDRIVE/omtt_gis_data/outputs"

backup_dir "bd_gis/local_data" \
    "$P/omtt/bd_gis/local_data" \
    "$ONEDRIVE/omtt_gis_data/local_data"

# Sensitive files (GPG, env) - OneDrive -> GDrive redundancy
echo ""
echo "Syncing sensitive files..."
if [ -n "$GDRIVE" ] && [ -d "$ONEDRIVE/gpg_backup" ]; then
    mkdir -p "$GDRIVE/../sensitive/gpg_backup"
    if command -v rsync &>/dev/null; then
        rsync -au "$ONEDRIVE/gpg_backup/" "$GDRIVE/../sensitive/gpg_backup/" 2>/dev/null
    else
        cp -ru "$ONEDRIVE/gpg_backup/"* "$GDRIVE/../sensitive/gpg_backup/" 2>/dev/null || true
    fi
    echo "  OK    GPG backup"
fi

for f in dulalratna_sensitive/env.txt econai_sensitive/env.txt; do
    if [ -f "$ONEDRIVE/$f" ] && [ -n "$GDRIVE" ]; then
        mkdir -p "$GDRIVE/../sensitive/$(dirname "$f")"
        copy_with_progress "$ONEDRIVE/$f" "$GDRIVE/../sensitive/$f" 2>/dev/null || true
    fi
done
echo "  OK    env files"

echo ""
if [ "$ERRORS" -gt 0 ]; then
    echo "Completed with $ERRORS errors."
    exit 1
fi
echo "All backups current."
