#!/bin/bash
# Start of session: pull everything, deploy configs + data symlinks, verify.
set -e
DOTFILES_DIR="${HOME}/dotfiles"
source "$DOTFILES_DIR/paths.sh"

echo "=== sit ($MACHINE_NAME) ==="
echo ""

# Pull dotfiles (stash local changes if needed)
echo "Pulling dotfiles..."
cd "$DOTFILES_DIR"
DOTFILES_STASHED=false
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    if git stash push -m "sit-auto-$(date +%s)" 2>/dev/null; then
        DOTFILES_STASHED=true
        echo "  (stashed local changes)"
    fi
fi
git pull --ff-only 2>/dev/null || git pull --rebase 2>/dev/null || git pull
if $DOTFILES_STASHED; then
    if git stash pop 2>/dev/null; then
        echo "  (restored local changes)"
    else
        echo "  CONFLICT in dotfiles (changes in stash@{0}, resolve manually)"
    fi
fi
echo ""

# One-time repo rename migration (safe to re-run)
if [ -f "$DOTFILES_DIR/bin/migrate-repo-names.sh" ]; then
    bash "$DOTFILES_DIR/bin/migrate-repo-names.sh"
    echo ""
fi

# Clone any missing repos
for repo in $REPOS; do
    if [ ! -d "$HOME/$repo" ]; then
        echo "Cloning $repo..."
        git clone "https://github.com/$GITHUB_USER/$repo.git" "$HOME/$repo"
    fi
done

# Pull all project repos (stash dirty trees, update submodules)
echo "Pulling project repos..."
for repo in $REPOS; do
    if [ -d "$HOME/$repo/.git" ]; then
        printf "  %-20s" "$repo"
        cd "$HOME/$repo"

        # Check for uncommitted changes
        DIRTY=false
        if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
            DIRTY=true
        fi

        # Stash if dirty
        STASHED=false
        if $DIRTY; then
            if git stash push -m "sit-auto-$(date +%s)" --include-untracked 2>/dev/null; then
                STASHED=true
            else
                printf "DIRTY (stash failed, resolve manually)\n"
                continue
            fi
        fi

        # Pull
        PULL_OK=false
        if git pull --ff-only 2>/dev/null; then
            PULL_OK=true
        elif git pull 2>/dev/null; then
            PULL_OK=true
        fi

        # Update submodules if any
        if [ -f ".gitmodules" ]; then
            git submodule update --init --recursive 2>/dev/null || true
        fi

        # Pop stash
        if $STASHED; then
            if git stash pop 2>/dev/null; then
                if $PULL_OK; then
                    printf "OK (stashed + restored)\n"
                else
                    printf "DIVERGED (stash restored, merge manually)\n"
                fi
            else
                printf "CONFLICT (changes in stash@{0}, resolve manually)\n"
                continue
            fi
        else
            if $PULL_OK; then
                printf "OK\n"
            else
                printf "DIVERGED (merge manually)\n"
            fi
        fi
    fi
done
echo ""

# Clean stale WAL/SHM files from data directories
echo "Cleaning stale WAL/SHM..."
for repo in $REPOS; do
    if [ -d "$HOME/$repo" ]; then
        find "$HOME/$repo" -maxdepth 3 \( -name "*.db-wal" -o -name "*.db-shm" \) -print -delete 2>/dev/null || true
    fi
done
echo ""

# Install configs + data symlinks + memory (runs once, after all repos cloned)
bash "$DOTFILES_DIR/install.sh"
echo ""

# Doctor
bash "$DOTFILES_DIR/bin/doctor.sh"
