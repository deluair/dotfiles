#!/bin/bash
# End of session: sync memory, push everything, sync GDrive redundancy.
set -e
DOTFILES_DIR="${HOME}/dotfiles"
source "$DOTFILES_DIR/paths.sh"

echo "=== standup ($MACHINE_NAME) ==="
echo ""

# Sync Claude memory
bash "$DOTFILES_DIR/sync-memory.sh"
echo ""

# Push dotfiles (only tracked content: memory, commands, claude configs)
echo "dotfiles:"
cd "$DOTFILES_DIR"
git add claude/ shell/ bin/ *.sh Makefile Brewfile 2>/dev/null || true
git diff --cached --quiet || git commit -m "sync memory"
if ! git push 2>/dev/null; then
    echo "  behind remote, rebasing..."
    if git pull --rebase 2>/dev/null && git push 2>/dev/null; then
        echo "  OK (rebased + pushed)"
    else
        echo "  FAILED (resolve manually)"
    fi
else
    echo "  OK"
fi
echo ""

# Push all project repos
echo "Project repos:"
for repo in $REPOS; do
    if [ -d "$HOME/$repo/.git" ]; then
        AHEAD=$(cd "$HOME/$repo" && git rev-list --count @{u}..HEAD 2>/dev/null || echo "?")
        if [ "$AHEAD" = "0" ] || [ "$AHEAD" = "?" ]; then
            printf "  %-20s up to date\n" "$repo"
        else
            printf "  %-20s pushing $AHEAD commit(s)... " "$repo"
            if cd "$HOME/$repo" && git push 2>/dev/null; then
                printf "OK\n"
            else
                # Remote has new commits, rebase and retry
                printf "behind, rebasing... "
                if git pull --rebase 2>/dev/null && git push 2>/dev/null; then
                    printf "OK\n"
                else
                    printf "FAILED (resolve manually)\n"
                fi
            fi
        fi
    fi
done
echo ""

# GDrive redundancy sync (OneDrive -> GDrive)
bash "$DOTFILES_DIR/backup-data.sh"
