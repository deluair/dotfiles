#!/bin/bash
# Cross-platform path resolution. Source this from all scripts.
# Sets: OS, ONEDRIVE, GDRIVE, PROJECTS_DIR, SHELL_RC
# Sources config.sh for machine-specific values (identity, VPS, repos).

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

if [ -f "$DOTFILES_DIR/config.sh" ]; then
    source "$DOTFILES_DIR/config.sh"
else
    echo "WARNING: $DOTFILES_DIR/config.sh not found. Copy config.sh.example to config.sh and edit." >&2
fi

case "$OSTYPE" in
    darwin*)  OS="macos" ;;
    msys*|cygwin*|mingw*)
        OS="windows"
        # Enable native NTFS symlinks in Git Bash (requires Developer Mode)
        export MSYS=winsymlinks:nativestrict
        ;;
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
        cp "$src" "$dest"
        echo "  copied $(basename "$src")"
    fi
}

# ── Machine identity (auto-detect if not set in config.sh) ──
if [ -z "$MACHINE_NAME" ] || [ "$MACHINE_NAME" = "unknown" ]; then
    if [ "$OS" = "macos" ]; then
        _hw=$(sysctl -n hw.model 2>/dev/null || echo "")
        _sp=""
        if command -v system_profiler &>/dev/null; then
            _sp=$(system_profiler SPHardwareDataType 2>/dev/null | grep "Model Name" || true)
        fi
        if echo "$_hw" | grep -qi "macmini" || echo "$_sp" | grep -qi "mac mini"; then
            MACHINE_NAME="macmini"
        elif echo "$_hw" | grep -qi "macbookair" || echo "$_sp" | grep -qi "macbook air"; then
            MACHINE_NAME="macair"
        else
            MACHINE_NAME="unknown-mac"
        fi
    elif [ "$OS" = "windows" ]; then
        _mfg=$(powershell -NoProfile -Command "(Get-CimInstance Win32_ComputerSystem).Manufacturer" 2>/dev/null | tr -d '\r' || echo "")
        _cpu=$(powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).Name" 2>/dev/null | tr -d '\r' || echo "")
        if echo "$_mfg" | grep -qi "samsung"; then
            MACHINE_NAME="galaxy"
        elif echo "$_mfg" | grep -qi "dell"; then
            MACHINE_NAME="dell"
        elif echo "$_cpu" | grep -qi "snapdragon\|qualcomm"; then
            MACHINE_NAME="galaxy"
        elif echo "$_cpu" | grep -qi "xeon\|core"; then
            MACHINE_NAME="dell"
        else
            MACHINE_NAME="unknown-win"
        fi
    else
        MACHINE_NAME="unknown"
    fi
fi

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

# ── Data symlink helper ──
# Creates symlink from project path → OneDrive path.
# Uses directory listings to check OneDrive (avoids Files On-Demand downloads).
# Usage: link_data "onedrive_rel" "local_rel" "label" [skip_if_tight]
link_data() {
    local src="$ONEDRIVE/$1"
    local dest="$PROJECTS_DIR/$2"
    local label="$3"
    local skip_tight="${4:-false}"

    if [ "$skip_tight" = "true" ] && [ "$STORAGE_TIGHT" = "true" ]; then
        echo "  SKIP  $label (storage-tight machine)"
        return
    fi

    # Skip if project not cloned yet
    local project_dir="${2%%/*}"
    if [ ! -d "$PROJECTS_DIR/$project_dir" ]; then
        return
    fi

    # Already correct symlink
    if [ -L "$dest" ]; then
        local target
        target=$(readlink "$dest" 2>/dev/null || true)
        if [ "$target" = "$src" ]; then
            echo "  OK    $label"
            return
        fi
        # Wrong target, remove and relink
        rm "$dest"
    fi

    # Check source exists via directory listing (avoids OneDrive download trigger)
    local src_dir src_name
    src_dir=$(dirname "$src")
    src_name=$(basename "$src")
    if [ ! -d "$src_dir" ] || ! ls "$src_dir" 2>/dev/null | grep -qx "$src_name"; then
        echo "  MISS  $label (not in OneDrive)"
        return
    fi

    # Local file/dir exists (not symlink), replace with symlink
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        if ! rm -rf "$dest" 2>/dev/null; then
            echo "  WARN  $label (locked, close apps using it then re-run)"
            return
        fi
    fi

    mkdir -p "$(dirname "$dest")"
    if ln -sf "$src" "$dest" 2>/dev/null; then
        echo "  LINK  $label -> OneDrive"
    else
        echo "  FAIL  $label (enable Developer Mode for symlinks)"
    fi
}

export OS ONEDRIVE GDRIVE PROJECTS_DIR SHELL_RC SHELL_RC_NAME
export GIT_USER_NAME GIT_USER_EMAIL GPG_EMAIL GITHUB_USER VPS_HOST VPS_BACKUP_PATH REPOS
export MACHINE_NAME MACHINE_DESC STORAGE_TIGHT
