#!/usr/bin/env bash
# Pull VPS database backups to OneDrive for offsite storage
set -euo pipefail

VPS="ubuntu@40.160.2.223"
ONEDRIVE="$HOME/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage/vps_backups"

mkdir -p "$ONEDRIVE"

echo "Pulling backups from VPS..."
rsync -avz --progress "$VPS:/home/ubuntu/backups/" "$ONEDRIVE/"

# Keep only last 3 days locally (OneDrive cloud retains history)
find "$ONEDRIVE" -name "*.db" -mtime +3 -delete 2>/dev/null || true

echo ""
echo "Backups synced to OneDrive (keeping last 3 days locally):"
ls -lh "$ONEDRIVE"/*.db 2>/dev/null || echo "  No .db files found"
echo ""
echo "OneDrive syncs to cloud automatically. ~85MB per day."
