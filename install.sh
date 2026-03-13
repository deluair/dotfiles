#!/bin/bash
# Install dotfiles: link configs, deploy Claude memory, import GPG key.
# Cross-platform: macOS, Windows (Git Bash), Linux.
# Idempotent: safe to run multiple times.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

source "$DOTFILES_DIR/paths.sh"

echo "=== Installing dotfiles ($OS) ==="
echo ""

# ── Shell config ──
echo "Shell config:"

# Determine source file based on OS
if [ "$OS" = "macos" ] || [ "$OS" = "linux" ]; then
    SHELL_SRC="$DOTFILES_DIR/shell/zshrc"
else
    SHELL_SRC="$DOTFILES_DIR/shell/bashrc"
fi

# Preserve existing shell config as .local
if [ -f "$SHELL_RC" ] && [ ! -L "$SHELL_RC" ]; then
    if ! grep -q "Managed by ~/dotfiles" "$SHELL_RC" 2>/dev/null; then
        LOCAL_RC="${SHELL_RC}.local"
        mv "$SHELL_RC" "$LOCAL_RC"
        echo "  Existing $SHELL_RC_NAME moved to ${SHELL_RC_NAME}.local"
    fi
fi
try_link "$SHELL_SRC" "$SHELL_RC"

# .gitconfig
try_link "$DOTFILES_DIR/shell/gitconfig" "$HOME/.gitconfig"

# ── Claude Code ──
echo ""
echo "Claude Code:"
mkdir -p "$CLAUDE_DIR"

try_link "$DOTFILES_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
try_link "$DOTFILES_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"
try_link "$DOTFILES_DIR/claude/settings.local.json" "$CLAUDE_DIR/settings.local.json"

# Deploy memory
PROJECT_FOLDER=$(encode_claude_path "$HOME")
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
    KEY=""
    [ -f "$ONEDRIVE/gpg_backup/deluair_private.asc" ] && KEY="$ONEDRIVE/gpg_backup/deluair_private.asc"
    [ -z "$KEY" ] && [ -n "$GDRIVE" ] && [ -f "$GDRIVE/../sensitive/gpg_backup/deluair_private.asc" ] && KEY="$GDRIVE/../sensitive/gpg_backup/deluair_private.asc"
    if [ -n "$KEY" ]; then
        gpg --import "$KEY" 2>/dev/null && echo "  Imported from cloud storage" || echo "  Import failed (check passphrase)"
    else
        echo "  Not found in cloud storage. Import manually:"
        echo "    gpg --import /path/to/deluair_private.asc"
    fi
fi

echo ""
echo "Done. Run 'make doctor' to verify."
