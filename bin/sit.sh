#!/bin/bash
# Start of session: pull everything, deploy configs + data symlinks, verify.
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

# Install configs + data symlinks + memory
bash "$DOTFILES_DIR/install.sh"
echo ""

# Clone any missing repos
for repo in $REPOS; do
    if [ ! -d "$HOME/$repo" ]; then
        echo "Cloning $repo..."
        git clone "https://github.com/$GITHUB_USER/$repo.git" "$HOME/$repo"
    fi
done

# Pull all project repos
echo "Pulling project repos..."
for repo in $REPOS; do
    if [ -d "$HOME/$repo/.git" ]; then
        printf "  %-20s" "$repo"
        cd "$HOME/$repo" && git pull --ff-only 2>/dev/null && printf "OK\n" || printf "CONFLICT (resolve manually)\n"
    fi
done
echo ""

# Re-run install to symlink data for newly cloned repos
echo "Linking data for newly cloned repos..."
bash "$DOTFILES_DIR/install.sh" 2>/dev/null | grep -E "^  (LINK|MISS)" || true
echo ""

# Doctor
bash "$DOTFILES_DIR/bin/doctor.sh"
