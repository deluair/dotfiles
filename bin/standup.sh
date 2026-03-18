#!/bin/bash
# End of session: sync memory, push everything, backup data.
set -e
DOTFILES_DIR="${HOME}/dotfiles"
source "$DOTFILES_DIR/paths.sh"

echo "=== standup ($MACHINE_NAME) ==="
echo ""

# Sync Claude memory
bash "$DOTFILES_DIR/sync-memory.sh"
echo ""

# Push dotfiles
echo "dotfiles:"
cd "$DOTFILES_DIR"
git add -A && git diff --cached --quiet || git commit -m "sync memory"
git push 2>/dev/null && echo "  OK" || echo "  already up to date"
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
            cd "$HOME/$repo" && git push 2>/dev/null && printf "OK\n" || printf "FAILED\n"
        fi
    fi
done
echo ""

# Backup data
bash "$DOTFILES_DIR/backup-data.sh"
