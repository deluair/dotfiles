#!/bin/bash
# Zero-to-running bootstrap. Run on a fresh Mac:
#   curl -fsSL https://raw.githubusercontent.com/deluair/dotfiles/main/bootstrap.sh | bash
set -e

echo "=== Deluair Dev Bootstrap ==="
echo ""

# 1. Xcode CLI tools (provides git)
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Press Enter after Xcode tools finish installing."
    read -r
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 3. Clone dotfiles
if [ ! -d "$HOME/dotfiles" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/deluair/dotfiles.git "$HOME/dotfiles"
fi

# 4. Run full setup
cd "$HOME/dotfiles"
make all

echo ""
echo "=== Bootstrap complete ==="
echo ""
echo "Next steps:"
echo "  1. Sign into Google Drive and OneDrive (apps installed)"
echo "  2. Wait for cloud storage to mount"
echo "  3. Import GPG key:  make gpg-import"
echo "  4. Clone projects:  make clone-all"
echo "  5. Restore data:    make restore"
echo "  6. Verify:          make doctor"
