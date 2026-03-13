#!/bin/bash
# Restore gitignored data files from cloud storage to project directories.
# Tries OneDrive first, falls back to GDrive.
set -e

ONEDRIVE="$HOME/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage"
GDRIVE="$HOME/Library/CloudStorage/GoogleDrive-dulal1986@gmail.com/My Drive/dev_backups"

restore() {
    local label="$1" dest="$2" onedrive_src="$3" gdrive_src="$4"
    if [ -f "$dest" ]; then
        echo "  SKIP  $label (already exists)"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -f "$onedrive_src" ]; then
        echo "  COPY  $label <- OneDrive"
        rsync --progress "$onedrive_src" "$dest"
    elif [ -f "$gdrive_src" ]; then
        echo "  COPY  $label <- GDrive"
        rsync --progress "$gdrive_src" "$dest"
    else
        echo "  MISS  $label (not found in either cloud)"
    fi
}

echo "Restoring project data from cloud storage..."
echo ""

# TradeWeave
restore "trade.db (18GB)" \
    "$HOME/trade-explorer/data/trade.db" \
    "$ONEDRIVE/db_backups/trade.db" \
    "$GDRIVE/db_backups/trade.db"

restore "tradeweave app.db" \
    "$HOME/trade-explorer/data/app.db" \
    "$ONEDRIVE/db_backups/tradeweave_app_latest.db" \
    "$GDRIVE/db_backups/tradeweave_app_latest.db"

# BDFacts
restore "bangladesh.db" \
    "$HOME/bddata/backend/data/bangladesh.db" \
    "$ONEDRIVE/db_backups/bddb_latest.sqlite" \
    "$GDRIVE/db_backups/bddb_latest.sqlite"

# OMTT
restore "omtt/bdpolicy.db" \
    "$HOME/omtt/data/bdpolicy.db" \
    "$ONEDRIVE/db_backups/omtt_bdpolicy_latest.db" \
    "$GDRIVE/db_backups/omtt_bdpolicy_latest.db"

restore "omtt/bangladesh.db" \
    "$HOME/omtt/data/bangladesh.db" \
    "$ONEDRIVE/db_backups/omtt_bangladesh_latest.db" \
    "$GDRIVE/db_backups/omtt_bangladesh_latest.db"

restore "omtt/baci.db" \
    "$HOME/omtt/data/baci.db" \
    "$ONEDRIVE/db_backups/omtt_baci_latest.db" \
    "$GDRIVE/db_backups/omtt_baci_latest.db"

# DulalRatna
restore "me.db" \
    "$HOME/dulalratna/me.db" \
    "$ONEDRIVE/db_backups/dulalratna_me_latest.db" \
    "$GDRIVE/db_backups/dulalratna_me_latest.db"

echo ""
echo "Done. Run 'make doctor' to verify."
