#!/bin/bash
# Verify all prerequisites, data, and configs.
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$DOTFILES_DIR/paths.sh"

echo "=== $MACHINE_NAME ($MACHINE_DESC) ==="
echo "=== Platform: $OS ==="
echo ""

echo "=== Prerequisites ==="
command -v git >/dev/null    && printf "  OK   git\n"        || printf "  MISS git\n"
command -v node >/dev/null   && printf "  OK   node %s\n" "$(node -v 2>/dev/null)" || printf "  MISS node\n"
command -v uv >/dev/null     && printf "  OK   uv\n"         || printf "  MISS uv\n"
command -v gpg >/dev/null    && printf "  OK   gpg\n"        || printf "  MISS gpg\n"
command -v gh >/dev/null     && printf "  OK   gh\n"         || printf "  MISS gh\n"
command -v rsync >/dev/null  && printf "  OK   rsync\n"      || printf "  WARN rsync (optional, using cp fallback)\n"
command -v age >/dev/null    && printf "  OK   age\n"        || printf "  WARN age (optional)\n"
echo ""

echo "=== Cloud Storage ==="
[ -d "$ONEDRIVE" ] && printf "  OK   OneDrive\n" || printf "  MISS OneDrive (sign in and sync)\n"
if [ -n "$GDRIVE" ] && [ -d "$(dirname "$GDRIVE")" ]; then printf "  OK   GDrive\n"; else printf "  MISS GDrive (sign in and sync)\n"; fi
echo ""

echo "=== Configs ==="
if [ -L "$SHELL_RC" ]; then printf "  OK   $SHELL_RC_NAME (symlinked)\n"
elif [ -f "$SHELL_RC" ] && grep -q "Managed by ~/dotfiles" "$SHELL_RC" 2>/dev/null; then printf "  OK   $SHELL_RC_NAME (copied)\n"
else printf "  WARN $SHELL_RC_NAME (not managed, run bash install.sh)\n"; fi
[ -L "$HOME/.gitconfig" ] || [ -f "$HOME/.gitconfig" ] && printf "  OK   .gitconfig\n" || printf "  WARN .gitconfig\n"
([ -L "$HOME/.claude/CLAUDE.md" ] || [ -f "$HOME/.claude/CLAUDE.md" ]) && printf "  OK   CLAUDE.md\n" || printf "  WARN CLAUDE.md\n"
echo ""

echo "=== GPG ==="
if command -v timeout &>/dev/null; then
    timeout 5 gpg --list-keys "$GPG_EMAIL" >/dev/null 2>&1
else
    gpg --list-keys "$GPG_EMAIL" >/dev/null 2>&1
fi
GPG_RC=$?
if [ $GPG_RC -eq 0 ]; then printf "  OK   GPG key imported\n"
elif [ $GPG_RC -eq 124 ]; then printf "  WARN GPG check timed out (gpg-agent may be stuck)\n"
else printf "  MISS GPG key (run: bash ~/dotfiles/install.sh)\n"; fi
echo ""

# Check data symlinks (OneDrive is source of truth)
# Uses directory listings to avoid triggering OneDrive Files On-Demand downloads.
check_data() {
    local label="$1" link_path="$2" onedrive_path="$3" skip_tight="${4:-false}"

    if [ "$skip_tight" = "true" ] && [ "$STORAGE_TIGHT" = "true" ]; then
        printf "  SKIP %s (storage-tight)\n" "$label"
        return
    fi

    # Skip if project not cloned
    local project_dir="${2#$PROJECTS_DIR/}"
    project_dir="${project_dir%%/*}"
    if [ ! -d "$PROJECTS_DIR/$project_dir" ]; then
        return
    fi

    # Check OneDrive source via directory listing (avoids download trigger)
    local src_dir src_name in_onedrive=false
    src_dir=$(dirname "$onedrive_path")
    src_name=$(basename "$onedrive_path")
    if [ -d "$src_dir" ] && ls "$src_dir" 2>/dev/null | grep -qx "$src_name"; then
        in_onedrive=true
    fi

    if [ -L "$link_path" ]; then
        if $in_onedrive; then
            printf "  OK   %s (symlinked)\n" "$label"
        else
            printf "  WARN %s (symlink but source missing in OneDrive)\n" "$label"
        fi
    elif [ -e "$link_path" ]; then
        printf "  WARN %s (local copy, not symlinked)\n" "$label"
    elif $in_onedrive; then
        printf "  MISS %s (in OneDrive but not symlinked, run: bash install.sh)\n" "$label"
    else
        printf "  MISS %s (not in OneDrive)\n" "$label"
    fi
}

echo "=== Data (symlinked to OneDrive) ==="
P="$PROJECTS_DIR"
check_data "trade.db" "$P/tradeweave/data/trade.db" "$ONEDRIVE/db_backups/trade.db" true
check_data "imf.db" "$P/tradeweave/data/imf.db" "$ONEDRIVE/db_backups/tradeweave_imf_latest.db"
check_data "app.db" "$P/tradeweave/data/app.db" "$ONEDRIVE/db_backups/tradeweave_app_latest.db"
check_data "bangladesh.db" "$P/bdfacts/backend/data/bangladesh.db" "$ONEDRIVE/db_backups/bddb_latest.sqlite"
check_data "bdpolicy.db" "$P/bdpolicylab/data/bdpolicy.db" "$ONEDRIVE/db_backups/omtt_bdpolicy_latest.db"
check_data "bangladesh.db (omtt)" "$P/bdpolicylab/data/bangladesh.db" "$ONEDRIVE/db_backups/omtt_bangladesh_latest.db"
check_data "baci.db" "$P/bdpolicylab/data/baci.db" "$ONEDRIVE/db_backups/omtt_baci_latest.db"
check_data "me.db" "$P/dulalratna/me.db" "$ONEDRIVE/db_backups/dulalratna_me_latest.db"
check_data "gis outputs" "$P/bdpolicylab/bd_gis/outputs" "$ONEDRIVE/omtt_gis_data/outputs"
check_data "gis local_data" "$P/bdpolicylab/bd_gis/local_data" "$ONEDRIVE/omtt_gis_data/local_data"
echo ""

echo "=== GDrive Redundancy ==="
if [ -n "$GDRIVE" ] && [ -d "$(dirname "$GDRIVE")" ]; then
    GDRIVE_DBS=$(ls "$GDRIVE/db_backups/" 2>/dev/null || true)
    echo "$GDRIVE_DBS" | grep -qx "trade.db" && printf "  OK   trade.db\n" || printf "  MISS trade.db (run: standup)\n"
    echo "$GDRIVE_DBS" | grep -qx "bddb_latest.sqlite" && printf "  OK   bangladesh.db\n" || printf "  MISS bangladesh.db\n"
else
    printf "  SKIP GDrive not available\n"
fi
echo ""

echo "=== Claude Code ==="
MEM_DIR="$HOME/.claude/projects/$(encode_claude_path "$HOME")/memory"
if [ -d "$MEM_DIR" ]; then printf "  OK   memory: %s files\n" "$(ls $MEM_DIR/*.md 2>/dev/null | wc -l | tr -d ' ')"; else printf "  MISS memory\n"; fi
if [ -d "$HOME/.claude/commands" ]; then printf "  OK   commands: %s\n" "$(ls $HOME/.claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ')"; else printf "  MISS commands\n"; fi
echo ""

echo "=== Disk Space ==="
if [ "$OS" = "macos" ]; then
    FREE=$(df -h / | tail -1 | awk '{print $4}')
    printf "  INFO %s free on /\n" "$FREE"
elif [ "$OS" = "windows" ]; then
    FREE=$(df -h /c 2>/dev/null | tail -1 | awk '{print $4}' || echo "?")
    printf "  INFO %s free on C:\n" "$FREE"
fi
