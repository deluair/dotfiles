#!/bin/bash
# Sync Claude Code memory back to dotfiles repo for backup.
# Cross-platform: macOS, Windows (Git Bash), Linux.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/paths.sh"

PROJECT_FOLDER=$(encode_claude_path "$HOME")
PROJECT_MEMORY_DIR="$HOME/.claude/projects/$PROJECT_FOLDER/memory"

if [ -d "$PROJECT_MEMORY_DIR" ]; then
    mkdir -p "$DOTFILES_DIR/claude/memory"
    cp "$PROJECT_MEMORY_DIR/"*.md "$DOTFILES_DIR/claude/memory/" 2>/dev/null || true
    echo "Memory synced to dotfiles/claude/memory/"
    echo "Files:"
    ls "$DOTFILES_DIR/claude/memory/"
else
    echo "No memory directory found at $PROJECT_MEMORY_DIR"
fi

# Sync commands back to dotfiles
if [ -d "$HOME/.claude/commands" ]; then
    mkdir -p "$DOTFILES_DIR/claude/commands"
    cp "$HOME/.claude/commands/"*.md "$DOTFILES_DIR/claude/commands/" 2>/dev/null || true
    echo "Commands synced to dotfiles/claude/commands/"
fi

# Also sync global CLAUDE.md if it's not a symlink
if [ -f "$HOME/.claude/CLAUDE.md" ] && [ ! -L "$HOME/.claude/CLAUDE.md" ]; then
    cp "$HOME/.claude/CLAUDE.md" "$DOTFILES_DIR/claude/CLAUDE.md"
    echo "CLAUDE.md synced."
fi
