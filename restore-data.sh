#!/bin/bash
# Restore gitignored data files from cloud storage to project directories.
# Cross-platform: macOS, Windows (Git Bash), Linux.
# Tries OneDrive first, falls back to GDrive.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/paths.sh"

restore() {
    local label="$1" dest="$2" onedrive_src="$3" gdrive_src="$4"
    if [ -f "$dest" ]; then
        echo "  SKIP  $label (already exists)"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -f "$onedrive_src" ]; then
        echo "  COPY  $label <- OneDrive"
        copy_with_progress "$onedrive_src" "$dest"
    elif [ -n "$GDRIVE" ] && [ -f "$gdrive_src" ]; then
        echo "  COPY  $label <- GDrive"
        copy_with_progress "$gdrive_src" "$dest"
    else
        echo "  MISS  $label (not found in either cloud)"
    fi
}

echo "Restoring project data ($OS)..."
echo ""

P="$PROJECTS_DIR"

restore "trade.db (18GB)" \
    "$P/trade-explorer/data/trade.db" \
    "$ONEDRIVE/db_backups/trade.db" \
    "$GDRIVE/db_backups/trade.db"

restore "tradeweave app.db" \
    "$P/trade-explorer/data/app.db" \
    "$ONEDRIVE/db_backups/tradeweave_app_latest.db" \
    "$GDRIVE/db_backups/tradeweave_app_latest.db"

restore "bangladesh.db" \
    "$P/bddata/backend/data/bangladesh.db" \
    "$ONEDRIVE/db_backups/bddb_latest.sqlite" \
    "$GDRIVE/db_backups/bddb_latest.sqlite"

restore "omtt/bdpolicy.db" \
    "$P/omtt/data/bdpolicy.db" \
    "$ONEDRIVE/db_backups/omtt_bdpolicy_latest.db" \
    "$GDRIVE/db_backups/omtt_bdpolicy_latest.db"

restore "omtt/bangladesh.db" \
    "$P/omtt/data/bangladesh.db" \
    "$ONEDRIVE/db_backups/omtt_bangladesh_latest.db" \
    "$GDRIVE/db_backups/omtt_bangladesh_latest.db"

restore "omtt/baci.db" \
    "$P/omtt/data/baci.db" \
    "$ONEDRIVE/db_backups/omtt_baci_latest.db" \
    "$GDRIVE/db_backups/omtt_baci_latest.db"

restore "me.db" \
    "$P/dulalratna/me.db" \
    "$ONEDRIVE/db_backups/dulalratna_me_latest.db" \
    "$GDRIVE/db_backups/dulalratna_me_latest.db"

echo ""
echo "Done. Run 'make doctor' to verify."
