#!/bin/bash
# One-time migration: rename local repo folders and update git remotes.
# Run on each machine after pulling dotfiles.
# Safe to re-run (skips already-renamed repos).

DOTFILES_DIR="${HOME}/dotfiles"
source "$DOTFILES_DIR/paths.sh"

RENAMES=(
    "omtt:bdpolicylab"
    "bddata:bdfacts"
    "trade-explorer:tradeweave"
)

echo "=== Repo rename migration ==="

for pair in "${RENAMES[@]}"; do
    old="${pair%%:*}"
    new="${pair##*:}"

    if [ -d "$HOME/$new" ]; then
        echo "  $new already exists, skipping"
        cd "$HOME/$new" && git remote set-url origin "https://github.com/$GITHUB_USER/$new.git" 2>/dev/null
        continue
    fi

    if [ -d "$HOME/$old" ]; then
        echo "  Renaming $old -> $new"
        mv "$HOME/$old" "$HOME/$new"
        cd "$HOME/$new"
        git remote set-url origin "https://github.com/$GITHUB_USER/$new.git"
        echo "    remote updated to $GITHUB_USER/$new"
    else
        echo "  $old not found, cloning $new fresh"
        git clone "https://github.com/$GITHUB_USER/$new.git" "$HOME/$new"
    fi
done

echo ""
echo "Done. Run 'sit' to verify."
