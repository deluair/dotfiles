#!/bin/bash
# Sync Claude Code memory back to dotfiles repo for backup
# Run this after sessions where memory was updated

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Find the project memory directory
encode_path() {
    local p="$1"
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        p=$(cygpath -w "$HOME" 2>/dev/null || echo "$HOME")
    fi
    echo "$p" | sed 's|[/\\:]|-|g' | sed 's|^-*||' | sed 's|-*$||'
}

PROJECT_FOLDER=$(encode_path "$HOME")
PROJECT_MEMORY_DIR="$CLAUDE_DIR/projects/$PROJECT_FOLDER/memory"

if [ -d "$PROJECT_MEMORY_DIR" ]; then
    mkdir -p "$DOTFILES_DIR/claude/memory"
    cp "$PROJECT_MEMORY_DIR/"*.md "$DOTFILES_DIR/claude/memory/"
    echo "Memory synced to dotfiles/claude/memory/"
    echo "Files:"
    ls "$DOTFILES_DIR/claude/memory/"
else
    echo "No memory directory found at $PROJECT_MEMORY_DIR"
fi

# Also sync global CLAUDE.md if it's not a symlink
if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]; then
    cp "$CLAUDE_DIR/CLAUDE.md" "$DOTFILES_DIR/claude/CLAUDE.md"
    echo "CLAUDE.md synced."
fi
