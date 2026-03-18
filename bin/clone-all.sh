#!/bin/bash
# Clone all project repos.
DOTFILES_DIR="${HOME}/dotfiles"
source "$DOTFILES_DIR/paths.sh"

echo "Cloning repos..."
for repo in $REPOS; do
    if [ ! -d "$HOME/$repo" ]; then
        echo "  Cloning $repo..."
        git clone "https://github.com/$GITHUB_USER/$repo.git" "$HOME/$repo"
    else
        echo "  $repo already exists"
    fi
done
