#!/bin/bash
# Restore gitignored data files from cloud storage to project directories.
# Cross-platform: macOS, Windows (Git Bash), Linux.
# Tries OneDrive first, falls back to GDrive.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/paths.sh"

human_size() {
    local src="$1"
    if [ -f "$src" ]; then
        du -h "$src" 2>/dev/null | cut -f1
    else
        echo "?"
    fi
}

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
    local size
    size=$(human_size "$src")
    echo "  COPY  $label ($size) <- $cloud"
    copy_with_progress "$src" "$dest"
}

echo "Restoring project data ($OS)..."
echo ""

# Show total size estimate before starting
TOTAL=0
for f in \
    "$ONEDRIVE/db_backups/trade.db" \
    "$ONEDRIVE/db_backups/tradeweave_app_latest.db" \
    "$ONEDRIVE/db_backups/bddb_latest.sqlite" \
    "$ONEDRIVE/db_backups/omtt_bdpolicy_latest.db" \
    "$ONEDRIVE/db_backups/omtt_bangladesh_latest.db" \
    "$ONEDRIVE/db_backups/omtt_baci_latest.db" \
    "$ONEDRIVE/db_backups/dulalratna_me_latest.db"; do
    if [ -f "$f" ]; then
        SIZE=$(du -k "$f" 2>/dev/null | cut -f1)
        TOTAL=$((TOTAL + SIZE))
    fi
done
if [ "$TOTAL" -gt 0 ]; then
    TOTAL_H=$(echo "$TOTAL" | awk '{if ($1 > 1048576) printf "%.1fGB", $1/1048576; else if ($1 > 1024) printf "%.0fMB", $1/1024; else printf "%dKB", $1}')
    echo "Total source data: ~$TOTAL_H (files already present will be skipped)"
    echo ""
fi

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

echo ""
echo "Done. Run 'make doctor' to verify."
