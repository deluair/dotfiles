#!/bin/bash
# DEPRECATED: Data now lives on OneDrive, accessed via symlinks.
# This script exists for backward compatibility.
# Run install.sh to create/update data symlinks.
echo "Data is now symlinked to OneDrive (no copy needed)."
echo "Running install.sh to ensure symlinks are current..."
echo ""
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$DOTFILES_DIR/install.sh"
