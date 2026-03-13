#!/bin/bash
# Cross-platform path resolution. Source this from all scripts.
# Sets: OS, ONEDRIVE, GDRIVE, PROJECTS_DIR, SHELL_RC, LINK_CMD

case "$OSTYPE" in
    darwin*)  OS="macos" ;;
    msys*|cygwin*|mingw*) OS="windows" ;;
    linux*)   OS="linux" ;;
    *)        OS="unknown" ;;
esac

# ── Cloud storage paths ──
if [ "$OS" = "macos" ]; then
    ONEDRIVE="$HOME/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage"
    GDRIVE="$HOME/Library/CloudStorage/GoogleDrive-dulal1986@gmail.com/My Drive/dev_backups"
elif [ "$OS" = "windows" ]; then
    # Git Bash on Windows: OneDrive syncs to user profile
    WIN_HOME=$(cygpath -u "$USERPROFILE" 2>/dev/null || echo "$HOME")
    ONEDRIVE="$WIN_HOME/OneDrive - University of Tennessee/hossen_storage"
    # Google Drive for Desktop: check common mount points
    if [ -d "/g/My Drive" ]; then
        GDRIVE="/g/My Drive/dev_backups"
    elif [ -d "$WIN_HOME/Google Drive/My Drive" ]; then
        GDRIVE="$WIN_HOME/Google Drive/My Drive/dev_backups"
    else
        GDRIVE=""
    fi
else
    # Linux: OneDrive via rclone mount or similar
    ONEDRIVE="$HOME/OneDrive/hossen_storage"
    GDRIVE="$HOME/GDrive/dev_backups"
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

export OS ONEDRIVE GDRIVE PROJECTS_DIR SHELL_RC SHELL_RC_NAME
