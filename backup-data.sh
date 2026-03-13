#!/bin/bash
# Redundant backup: critical data to both OneDrive and Google Drive
# OneDrive = primary (UTK account), GDrive = redundant (personal account)

set -e

ONEDRIVE="$HOME/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage"
GDRIVE="$HOME/Library/CloudStorage/GoogleDrive-dulal1986@gmail.com/My Drive/dev_backups"

# Verify both mounts exist
if [ ! -d "$ONEDRIVE" ]; then
    echo "ERROR: OneDrive not mounted at $ONEDRIVE"
    exit 1
fi
if [ ! -d "$(dirname "$GDRIVE")" ]; then
    echo "ERROR: Google Drive not mounted"
    exit 1
fi

mkdir -p "$GDRIVE/db_backups"
mkdir -p "$GDRIVE/sensitive"

echo "Backing up critical databases..."

# TradeWeave trade.db (the big one, 18GB+)
if [ -f "$HOME/trade-explorer/data/trade.db" ]; then
    echo "  trade.db -> OneDrive + GDrive"
    cp "$HOME/trade-explorer/data/trade.db" "$ONEDRIVE/db_backups/trade.db"
    cp "$HOME/trade-explorer/data/trade.db" "$GDRIVE/db_backups/trade.db"
fi

# TradeWeave app.db
if [ -f "$HOME/trade-explorer/data/app.db" ]; then
    echo "  tradeweave app.db -> OneDrive + GDrive"
    cp "$HOME/trade-explorer/data/app.db" "$ONEDRIVE/db_backups/tradeweave_app_latest.db"
    cp "$HOME/trade-explorer/data/app.db" "$GDRIVE/db_backups/tradeweave_app_latest.db"
fi

# BDFacts
if [ -f "$HOME/bddata/backend/data/bangladesh.db" ]; then
    echo "  bangladesh.db -> OneDrive + GDrive"
    cp "$HOME/bddata/backend/data/bangladesh.db" "$ONEDRIVE/db_backups/bddb_latest.sqlite"
    cp "$HOME/bddata/backend/data/bangladesh.db" "$GDRIVE/db_backups/bddb_latest.sqlite"
fi

# OMTT
for db in bdpolicy.db bangladesh.db baci.db; do
    if [ -f "$HOME/omtt/data/$db" ]; then
        echo "  omtt/$db -> OneDrive + GDrive"
        cp "$HOME/omtt/data/$db" "$ONEDRIVE/db_backups/omtt_${db%.db}_latest.db"
        cp "$HOME/omtt/data/$db" "$GDRIVE/db_backups/omtt_${db%.db}_latest.db"
    fi
done

# DulalRatna
if [ -f "$HOME/dulalratna/me.db" ]; then
    echo "  me.db -> OneDrive + GDrive"
    cp "$HOME/dulalratna/me.db" "$ONEDRIVE/db_backups/dulalratna_me_latest.db"
    cp "$HOME/dulalratna/me.db" "$GDRIVE/db_backups/dulalratna_me_latest.db"
fi

# GPG key (to GDrive as redundancy)
if [ -d "$ONEDRIVE/gpg_backup" ]; then
    echo "  GPG backup -> GDrive"
    cp -r "$ONEDRIVE/gpg_backup" "$GDRIVE/sensitive/gpg_backup"
fi

# Sensitive env files (to GDrive as redundancy)
for f in dulalratna_sensitive/env.txt econai_sensitive/env.txt; do
    if [ -f "$ONEDRIVE/$f" ]; then
        target_dir="$GDRIVE/sensitive/$(dirname "$f")"
        mkdir -p "$target_dir"
        cp "$ONEDRIVE/$f" "$target_dir/"
    fi
done

echo ""
echo "Done. Data backed up to:"
echo "  Primary:   $ONEDRIVE"
echo "  Redundant: $GDRIVE"
echo ""
echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
