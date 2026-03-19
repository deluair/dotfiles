#!/bin/bash
# GDrive redundancy sync: OneDrive -> GDrive.
# OneDrive is the source of truth for all data. This script maintains
# a redundant copy in Google Drive for disaster recovery.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/paths.sh"

if [ -z "$GDRIVE" ] || [ ! -d "$(dirname "$GDRIVE")" ]; then
    echo "GDrive not available, skipping redundancy sync."
    exit 0
fi

if [ ! -d "$ONEDRIVE" ]; then
    echo "OneDrive not available, skipping redundancy sync."
    exit 0
fi

ERRORS=0

sync_file() {
    local label="$1" src="$2" dest="$3"
    # Check existence via directory listing (avoids OneDrive download trigger)
    local src_dir src_name
    src_dir=$(dirname "$src")
    src_name=$(basename "$src")
    if ! ls "$src_dir" 2>/dev/null | grep -qx "$src_name"; then
        echo "  SKIP  $label (not in OneDrive)"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    copy_with_progress "$src" "$dest" 2>/dev/null || { echo "  FAIL  $label"; ERRORS=$((ERRORS + 1)); return; }
    echo "  OK    $label"
}

sync_dir() {
    local label="$1" src="$2" dest="$3"
    local src_dir src_name
    src_dir=$(dirname "$src")
    src_name=$(basename "$src")
    if ! ls "$src_dir" 2>/dev/null | grep -qx "$src_name"; then
        echo "  SKIP  $label (not in OneDrive)"
        return
    fi
    mkdir -p "$dest"
    if command -v rsync &>/dev/null; then
        rsync -au --delete "$src/" "$dest/" 2>/dev/null || { echo "  FAIL  $label"; ERRORS=$((ERRORS + 1)); return; }
    else
        # cp -u not available on macOS; use rsync (installed via Brewfile) or plain cp
        cp -R "$src/"* "$dest/" 2>/dev/null || { echo "  FAIL  $label"; ERRORS=$((ERRORS + 1)); return; }
    fi
    echo "  OK    $label"
}

echo "GDrive redundancy sync ($OS): $(date '+%Y-%m-%d %H:%M')"
echo ""

echo "Database files..."
sync_file "trade.db" \
    "$ONEDRIVE/db_backups/trade.db" \
    "$GDRIVE/db_backups/trade.db"

sync_file "imf.db" \
    "$ONEDRIVE/db_backups/tradeweave_imf_latest.db" \
    "$GDRIVE/db_backups/tradeweave_imf_latest.db"

sync_file "app.db" \
    "$ONEDRIVE/db_backups/tradeweave_app_latest.db" \
    "$GDRIVE/db_backups/tradeweave_app_latest.db"

sync_file "bangladesh.db" \
    "$ONEDRIVE/db_backups/bddb_latest.sqlite" \
    "$GDRIVE/db_backups/bddb_latest.sqlite"

sync_file "bdpolicy.db" \
    "$ONEDRIVE/db_backups/omtt_bdpolicy_latest.db" \
    "$GDRIVE/db_backups/omtt_bdpolicy_latest.db"

sync_file "bangladesh.db (omtt)" \
    "$ONEDRIVE/db_backups/omtt_bangladesh_latest.db" \
    "$GDRIVE/db_backups/omtt_bangladesh_latest.db"

sync_file "baci.db" \
    "$ONEDRIVE/db_backups/omtt_baci_latest.db" \
    "$GDRIVE/db_backups/omtt_baci_latest.db"

sync_file "me.db" \
    "$ONEDRIVE/db_backups/dulalratna_me_latest.db" \
    "$GDRIVE/db_backups/dulalratna_me_latest.db"

echo ""
echo "GIS directories..."
echo "  SKIP  gis (removed from standup, sync manually if needed)"

echo ""
echo "Sensitive files..."
if [ -d "$ONEDRIVE/gpg_backup" ]; then
    mkdir -p "$GDRIVE/../sensitive/gpg_backup"
    if command -v rsync &>/dev/null; then
        rsync -au "$ONEDRIVE/gpg_backup/" "$GDRIVE/../sensitive/gpg_backup/" 2>/dev/null
    else
        cp -ru "$ONEDRIVE/gpg_backup/"* "$GDRIVE/../sensitive/gpg_backup/" 2>/dev/null || true
    fi
    echo "  OK    GPG backup"
fi

for f in dulalratna_sensitive/env.txt econai_sensitive/env.txt; do
    if [ -f "$ONEDRIVE/$f" ]; then
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
echo "GDrive redundancy current."
