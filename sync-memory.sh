#!/bin/bash
# Bidirectional sync of Claude Code memory between active and dotfiles.
# Merges both directions: newer file wins. Cross-platform.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/paths.sh"

DOTFILES_MEM="$DOTFILES_DIR/claude/memory"
mkdir -p "$DOTFILES_MEM"

# Find all Claude project memory dirs for $HOME (any OS encoding)
ACTIVE_DIRS=()
CLAUDE_PROJECTS="$HOME/.claude/projects"
if [ -d "$CLAUDE_PROJECTS" ]; then
    # Match the home-dir project (not per-repo projects)
    ENCODED=$(encode_claude_path "$HOME")
    if [ -d "$CLAUDE_PROJECTS/$ENCODED/memory" ]; then
        ACTIVE_DIRS+=("$CLAUDE_PROJECTS/$ENCODED/memory")
    fi
fi

if [ ${#ACTIVE_DIRS[@]} -eq 0 ]; then
    echo "No active memory directory found."
    echo "Deploying from dotfiles..."
    # One-way: dotfiles -> new active dir
    ENCODED=$(encode_claude_path "$HOME")
    TARGET="$CLAUDE_PROJECTS/$ENCODED/memory"
    mkdir -p "$TARGET"
    cp "$DOTFILES_MEM/"*.md "$TARGET/" 2>/dev/null || true
    count=$(ls "$TARGET/"*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  Deployed $count memory files."
    exit 0
fi

SYNCED=0
for ACTIVE_MEM in "${ACTIVE_DIRS[@]}"; do
    echo "Syncing: $ACTIVE_MEM"

    # Merge: for each file in either dir, keep the newer version in both
    ALL_FILES=$(cd "$ACTIVE_MEM" && ls *.md 2>/dev/null; cd "$DOTFILES_MEM" && ls *.md 2>/dev/null)
    ALL_FILES=$(echo "$ALL_FILES" | sort -u)

    for f in $ALL_FILES; do
        ACTIVE="$ACTIVE_MEM/$f"
        BACKUP="$DOTFILES_MEM/$f"

        if [ -f "$ACTIVE" ] && [ ! -f "$BACKUP" ]; then
            cp "$ACTIVE" "$BACKUP"
            SYNCED=$((SYNCED + 1))
        elif [ ! -f "$ACTIVE" ] && [ -f "$BACKUP" ]; then
            cp "$BACKUP" "$ACTIVE"
            SYNCED=$((SYNCED + 1))
        elif [ -f "$ACTIVE" ] && [ -f "$BACKUP" ]; then
            if [ "$ACTIVE" -nt "$BACKUP" ]; then
                cp "$ACTIVE" "$BACKUP"
                SYNCED=$((SYNCED + 1))
            elif [ "$BACKUP" -nt "$ACTIVE" ]; then
                cp "$BACKUP" "$ACTIVE"
                SYNCED=$((SYNCED + 1))
            fi
        fi
    done
done

count=$(ls "$DOTFILES_MEM/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo "Memory synced ($count files, $SYNCED updated)."

# Also sync commands
if [ -d "$HOME/.claude/commands" ]; then
    mkdir -p "$DOTFILES_DIR/claude/commands"
    cp "$HOME/.claude/commands/"*.md "$DOTFILES_DIR/claude/commands/" 2>/dev/null || true
    echo "Commands synced."
fi

# Sync global CLAUDE.md if not a symlink
if [ -f "$HOME/.claude/CLAUDE.md" ] && [ ! -L "$HOME/.claude/CLAUDE.md" ]; then
    cp "$HOME/.claude/CLAUDE.md" "$DOTFILES_DIR/claude/CLAUDE.md"
    echo "CLAUDE.md synced."
fi
