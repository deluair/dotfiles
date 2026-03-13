#!/bin/bash
# Install Claude Code dotfiles
# Works on macOS, Linux, and Git Bash (Windows)

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

# Symlink global instructions
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# Symlink settings (plugins, effort level)
ln -sf "$DOTFILES_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"

# Symlink permission rules
ln -sf "$DOTFILES_DIR/claude/settings.local.json" "$CLAUDE_DIR/settings.local.json"

# Deploy memory to the current machine's project folder
# Claude Code encodes the home dir path as the project folder name
# e.g. C:\Users\mhossen -> C--Users-mhossen, /home/mhossen -> -home-mhossen
encode_path() {
    local p="$1"
    # On Windows (Git Bash), HOME is /c/Users/mhossen but Claude uses C:\Users\mhossen
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        # Convert /c/Users/mhossen -> C--Users-mhossen
        p=$(cygpath -w "$HOME" 2>/dev/null || echo "$HOME")
    fi
    # Replace path separators with dashes, keep leading dash (Claude expects it)
    echo "$p" | sed 's|[/\\:]|-|g' | sed 's|-*$||'
}

PROJECT_FOLDER=$(encode_path "$HOME")
PROJECT_MEMORY_DIR="$CLAUDE_DIR/projects/$PROJECT_FOLDER/memory"

if [ -d "$DOTFILES_DIR/claude/memory" ]; then
    mkdir -p "$PROJECT_MEMORY_DIR"
    cp -n "$DOTFILES_DIR/claude/memory/"*.md "$PROJECT_MEMORY_DIR/" 2>/dev/null || true
    echo "Memory deployed to: $PROJECT_MEMORY_DIR"
fi

echo ""
echo "Claude Code config linked:"
echo "  CLAUDE.md            -> $CLAUDE_DIR/CLAUDE.md"
echo "  settings.json        -> $CLAUDE_DIR/settings.json"
echo "  settings.local.json  -> $CLAUDE_DIR/settings.local.json"
echo "  memory/              -> $PROJECT_MEMORY_DIR/"
echo ""
echo "Not managed (keep local):"
echo "  config.json   (API key)"
echo "  plugins/      (auto-cached)"
