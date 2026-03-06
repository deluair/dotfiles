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

echo "Claude Code config linked:"
echo "  CLAUDE.md          -> $CLAUDE_DIR/CLAUDE.md"
echo "  settings.json      -> $CLAUDE_DIR/settings.json"
echo "  settings.local.json -> $CLAUDE_DIR/settings.local.json"
echo ""
echo "Not managed (keep local):"
echo "  config.json   (API key)"
echo "  projects/     (per-project memory)"
echo "  plugins/      (auto-cached)"
