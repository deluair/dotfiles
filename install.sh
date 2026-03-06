#!/bin/bash
# Symlink Claude Code global config
mkdir -p ~/.claude
ln -sf ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
echo "Claude config linked."
