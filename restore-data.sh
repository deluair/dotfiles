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
    local src=""
    local cloud=""
    if [ -f "$onedrive_src" ]; then
        src="$onedrive_src"
        cloud="OneDrive"
    elif [ -n "$GDRIVE" ] && [ -f "$gdrive_src" ]; then
        src="$gdrive_src"
        cloud="GDrive"
    fi
    if [ -z "$src" ]; then
        echo "  MISS  $label (not found in either cloud)"
        return
    fi
    # No du/stat on cloud files -- triggers OneDrive Files On-Demand download.
    echo "  COPY  $label <- $cloud"
    copy_with_progress "$src" "$dest"
}

echo "Restoring project data ($OS)..."
echo ""

# No size estimation here -- accessing OneDrive files triggers Files On-Demand downloads.

P="$PROJECTS_DIR"

restore "trade.db (18GB, may take a while)" \
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

# Directory restores
echo ""
echo "Directory restores..."

restore_dir() {
    local label="$1" dest="$2" src="$3"
    if [ -d "$dest" ] && [ "$(ls -A "$dest" 2>/dev/null)" ]; then
        echo "  SKIP  $label (already exists)"
        return
    fi
    if [ ! -d "$src" ]; then
        echo "  MISS  $label (not found in cloud)"
        return
    fi
    mkdir -p "$dest"
    echo "  COPY  $label <- OneDrive"
    if command -v rsync &>/dev/null; then
        rsync -au "$src/" "$dest/"
    else
        cp -r "$src/"* "$dest/"
    fi
}

restore_dir "bd_gis/outputs" \
    "$P/omtt/bd_gis/outputs" \
    "$ONEDRIVE/omtt_gis_data/outputs"

restore_dir "bd_gis/local_data (5GB+)" \
    "$P/omtt/bd_gis/local_data" \
    "$ONEDRIVE/omtt_gis_data/local_data"

echo ""
echo "Done. Run 'make doctor' to verify."
