#!/bin/bash
# Cross-platform path resolution. Source this from all scripts.
# Sets: OS, ONEDRIVE, GDRIVE, PROJECTS_DIR, SHELL_RC, LINK_CMD
# Sources config.sh for machine-specific values (identity, VPS, repos).

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

if [ -f "$DOTFILES_DIR/config.sh" ]; then
    source "$DOTFILES_DIR/config.sh"
else
    echo "WARNING: $DOTFILES_DIR/config.sh not found. Copy config.sh.example to config.sh and edit." >&2
fi

case "$OSTYPE" in
    darwin*)  OS="macos" ;;
    msys*|cygwin*|mingw*) OS="windows" ;;
    linux*)   OS="linux" ;;
    *)        OS="unknown" ;;
esac

# ── Cloud storage paths (built from config.sh values) ──
ONEDRIVE_ORG_NOSPACE=$(echo "$ONEDRIVE_ORG" | tr -d ' ')
if [ "$OS" = "macos" ]; then
    ONEDRIVE="$HOME/Library/CloudStorage/OneDrive-${ONEDRIVE_ORG_NOSPACE}/${ONEDRIVE_FOLDER}"
    GDRIVE="$HOME/Library/CloudStorage/GoogleDrive-${GDRIVE_EMAIL}/My Drive/${GDRIVE_FOLDER}"
elif [ "$OS" = "windows" ]; then
    WIN_HOME=$(cygpath -u "$USERPROFILE" 2>/dev/null || echo "$HOME")
    ONEDRIVE="$WIN_HOME/OneDrive - ${ONEDRIVE_ORG}/${ONEDRIVE_FOLDER}"
    if [ -d "/g/My Drive" ]; then
        GDRIVE="/g/My Drive/${GDRIVE_FOLDER}"
    elif [ -d "$WIN_HOME/Google Drive/My Drive" ]; then
        GDRIVE="$WIN_HOME/Google Drive/My Drive/${GDRIVE_FOLDER}"
    else
        GDRIVE=""
    fi
else
    ONEDRIVE="$HOME/OneDrive/${ONEDRIVE_FOLDER}"
    GDRIVE="$HOME/GDrive/${GDRIVE_FOLDER}"
fi

# ── Project root ──
PROJECTS_DIR="$HOME"

# ── Shell config file ──
if [ "$OS" = "macos" ] || [ "$OS" = "linux" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_RC_NAME=".zshrc"
else
    SHELL_RC="$HOME/.bashrc"
    SHELL_RC_NAME=".bashrc"
fi

# ── Symlink or copy ──
# Windows Git Bash symlinks require Developer Mode. Fall back to copy.
try_link() {
    local src="$1" dest="$2"
    if [ "$OS" = "windows" ]; then
        # Try symlink first, fall back to copy
        if ln -sf "$src" "$dest" 2>/dev/null; then
            echo "  $dest -> symlinked"
        else
            cp -f "$src" "$dest"
            echo "  $dest -> copied (symlink failed, enable Developer Mode for symlinks)"
        fi
    else
        ln -sf "$src" "$dest"
        echo "  $dest -> symlinked"
    fi
}

# ── Claude project path encoding ──
encode_claude_path() {
    local p="$1"
    if [ "$OS" = "windows" ]; then
        p=$(cygpath -w "$HOME" 2>/dev/null || echo "$HOME")
    fi
    echo "$p" | sed 's|[/\\:]|-|g' | sed 's|-*$||'
}

# ── File copy with progress (cross-platform) ──
copy_with_progress() {
    local src="$1" dest="$2"
    if command -v rsync &>/dev/null; then
        rsync -u --progress "$src" "$dest"
    else
        cp -u "$src" "$dest" 2>/dev/null || cp "$src" "$dest"
        echo "  copied $(basename "$src")"
    fi
}

# ── Machine identity ──
MACHINE_NAME="${MACHINE_NAME:-unknown}"

# Machine specs lookup (for scripts and doctor)
case "$MACHINE_NAME" in
    macmini)  MACHINE_DESC="Mac Mini M4, 256GB, macOS" ;;
    macair)   MACHINE_DESC="MacBook Air M4, 256GB, macOS" ;;
    galaxy)   MACHINE_DESC="Samsung Galaxy Book Edge, Snapdragon, 512GB, Windows" ;;
    dell)     MACHINE_DESC="Dell Precision 5560, 32GB RAM, 1TB, Windows" ;;
    *)        MACHINE_DESC="Unknown machine (set MACHINE_NAME in config.sh)" ;;
esac

# Storage constraints (256GB Macs are tight with 18GB trade.db)
case "$MACHINE_NAME" in
    macmini|macair) STORAGE_TIGHT=true ;;
    *)              STORAGE_TIGHT=false ;;
esac

export OS ONEDRIVE GDRIVE PROJECTS_DIR SHELL_RC SHELL_RC_NAME
export GIT_USER_NAME GIT_USER_EMAIL GPG_EMAIL GITHUB_USER VPS_HOST VPS_BACKUP_PATH REPOS
export MACHINE_NAME MACHINE_DESC STORAGE_TIGHT
