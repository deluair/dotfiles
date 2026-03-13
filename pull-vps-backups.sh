#!/usr/bin/env bash
# Pull VPS database backups to OneDrive for offsite storage
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/paths.sh"

BACKUP_DEST="$ONEDRIVE/vps_backups"
mkdir -p "$BACKUP_DEST"

echo "Pulling backups from VPS..."
rsync -avz --progress "$VPS_HOST:$VPS_BACKUP_PATH/" "$BACKUP_DEST/"

# Keep only last 3 days locally (OneDrive cloud retains history)
find "$BACKUP_DEST" -name "*.db" -mtime +3 -delete 2>/dev/null || true

echo ""
echo "Backups synced to OneDrive (keeping last 3 days locally):"
ls -lh "$BACKUP_DEST"/*.db 2>/dev/null || echo "  No .db files found"
echo ""
echo "OneDrive syncs to cloud automatically. ~85MB per day."
