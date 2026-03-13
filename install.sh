#!/bin/bash
# Install dotfiles: symlink configs, deploy Claude memory, import GPG key.
# Idempotent: safe to run multiple times.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "=== Installing dotfiles ==="
echo ""

# ── Shell configs ──
echo "Shell configs:"

# .zshrc: preserve machine-local additions
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    # Move existing content to .zshrc.local if it has more than our managed content
    if ! grep -q "Managed by ~/dotfiles" "$HOME/.zshrc" 2>/dev/null; then
        mv "$HOME/.zshrc" "$HOME/.zshrc.local"
        echo "  Existing .zshrc moved to .zshrc.local"
    fi
fi
ln -sf "$DOTFILES_DIR/shell/zshrc" "$HOME/.zshrc"
echo "  .zshrc -> symlinked"

# .gitconfig
ln -sf "$DOTFILES_DIR/shell/gitconfig" "$HOME/.gitconfig"
echo "  .gitconfig -> symlinked"

# ── Claude Code ──
echo ""
echo "Claude Code:"
mkdir -p "$CLAUDE_DIR"

ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  CLAUDE.md -> symlinked"

ln -sf "$DOTFILES_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"
echo "  settings.json -> symlinked"

ln -sf "$DOTFILES_DIR/claude/settings.local.json" "$CLAUDE_DIR/settings.local.json"
echo "  settings.local.json -> symlinked"

# Deploy memory to the current machine's project folder
encode_path() {
    local p="$1"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        p=$(cygpath -w "$HOME" 2>/dev/null || echo "$HOME")
    fi
    echo "$p" | sed 's|[/\\:]|-|g' | sed 's|-*$||'
}

PROJECT_FOLDER=$(encode_path "$HOME")
PROJECT_MEMORY_DIR="$CLAUDE_DIR/projects/$PROJECT_FOLDER/memory"

if [ -d "$DOTFILES_DIR/claude/memory" ]; then
    mkdir -p "$PROJECT_MEMORY_DIR"
    cp -n "$DOTFILES_DIR/claude/memory/"*.md "$PROJECT_MEMORY_DIR/" 2>/dev/null || true
    count=$(ls "$PROJECT_MEMORY_DIR/"*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  memory -> deployed ($count files)"
fi

# ── GPG key ──
echo ""
echo "GPG key:"
if gpg --list-keys deluair@gmail.com &>/dev/null; then
    echo "  Already imported"
else
    ONEDRIVE="$HOME/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage"
    GDRIVE="$HOME/Library/CloudStorage/GoogleDrive-dulal1986@gmail.com/My Drive/dev_backups"
    KEY=""
    if [ -f "$ONEDRIVE/gpg_backup/deluair_private.asc" ]; then
        KEY="$ONEDRIVE/gpg_backup/deluair_private.asc"
    elif [ -f "$GDRIVE/sensitive/gpg_backup/deluair_private.asc" ]; then
        KEY="$GDRIVE/sensitive/gpg_backup/deluair_private.asc"
    fi
    if [ -n "$KEY" ]; then
        gpg --import "$KEY" 2>/dev/null && echo "  Imported from cloud storage" || echo "  Import failed (check passphrase)"
    else
        echo "  Not found in cloud storage. Import manually:"
        echo "    gpg --import /path/to/deluair_private.asc"
    fi
fi

echo ""
echo "Done. Run 'make doctor' to verify."
