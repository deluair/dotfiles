#!/bin/bash
# Start of session: pull everything, merge memory, restore data, verify.
set -e
DOTFILES_DIR="${HOME}/dotfiles"
source "$DOTFILES_DIR/paths.sh"

echo "=== sit ($MACHINE_NAME) ==="
echo ""

# Pull dotfiles
echo "Pulling dotfiles..."
cd "$DOTFILES_DIR"
git pull --ff-only 2>/dev/null || git pull
echo ""

# Install/merge configs + memory
bash "$DOTFILES_DIR/install.sh"
echo ""

# Pull all project repos
echo "Pulling project repos..."
for repo in $REPOS; do
    if [ -d "$HOME/$repo/.git" ]; then
        printf "  %-20s" "$repo"
        cd "$HOME/$repo" && git pull --ff-only 2>/dev/null && printf "OK\n" || printf "CONFLICT (resolve manually)\n"
    fi
done
echo ""

# Restore data
bash "$DOTFILES_DIR/restore-data.sh"
echo ""

# Doctor
bash "$DOTFILES_DIR/bin/doctor.sh"
