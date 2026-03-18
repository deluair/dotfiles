#!/bin/bash
# Zero-to-running bootstrap. Works on macOS and Windows (Git Bash).
#
# macOS:   curl -fsSL https://raw.githubusercontent.com/deluair/dotfiles/main/bootstrap.sh | bash
# Windows: open Git Bash, then: curl -fsSL https://raw.githubusercontent.com/deluair/dotfiles/main/bootstrap.sh | bash
set -e

echo "=== Deluair Dev Bootstrap ==="
echo ""

# Detect OS
case "$OSTYPE" in
    darwin*)  OS="macos" ;;
    msys*|cygwin*|mingw*) OS="windows" ;;
    linux*)   OS="linux" ;;
    *)        OS="unknown" ;;
esac
echo "Platform: $OS"
echo ""

# ── 1. System package manager ──
if [ "$OS" = "macos" ]; then
    if ! xcode-select -p &>/dev/null; then
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install
        echo "Press Enter after Xcode tools finish installing."
        read -r
    fi
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
elif [ "$OS" = "windows" ]; then
    # winget lives in WindowsApps, which Git Bash often misses in PATH
    for p in "$LOCALAPPDATA/Microsoft/WindowsApps" "$LOCALAPPDATA/Microsoft/WinGet/Links"; do
        [ -d "$p" ] && export PATH="$p:$PATH"
    done
    if ! command -v winget &>/dev/null && ! command -v winget.exe &>/dev/null; then
        echo "winget not found. Install 'App Installer' from Microsoft Store, then re-run."
        exit 1
    fi
fi

# ── 2. Clone dotfiles ──
if [ ! -d "$HOME/dotfiles" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/deluair/dotfiles.git "$HOME/dotfiles"
fi

# ── 3. Install system deps FIRST (need age before decryption) ──
cd "$HOME/dotfiles"

if [ "$OS" = "macos" ]; then
    brew bundle --file=Brewfile
elif [ "$OS" = "windows" ]; then
    echo "Installing dependencies via winget..."
    winget.exe install -e --id Git.Git --accept-package-agreements --accept-source-agreements 2>/dev/null || true
    winget.exe install -e --id OpenJS.NodeJS.LTS --accept-package-agreements 2>/dev/null || true
    winget.exe install -e --id astral-sh.uv --accept-package-agreements 2>/dev/null || true
    winget.exe install -e --id GnuPG.GnuPG --accept-package-agreements 2>/dev/null || true
    winget.exe install -e --id GitHub.cli --accept-package-agreements 2>/dev/null || true
    winget.exe install -e --id Google.GoogleDrive --accept-package-agreements 2>/dev/null || true
    winget.exe install -e --id Microsoft.OneDrive --accept-package-agreements 2>/dev/null || true
    winget.exe install -e --id FiloSottile.age --accept-package-agreements 2>/dev/null || true
    echo ""
fi

# ── 4. Decrypt config.sh (age is now installed) ──
# Refresh PATH: winget installs don't update current shell
if [ "$OS" = "windows" ]; then
    for p in "$HOME/bin" "$LOCALAPPDATA/Microsoft/WinGet/Links" "/c/Program Files/age" "/c/Program Files (x86)/age"; do
        [ -d "$p" ] && export PATH="$p:$PATH"
    done
fi
if [ ! -f "config.sh" ]; then
    if [ -f "config.sh.age" ] && command -v age &>/dev/null; then
        echo ""
        echo "Decrypting config.sh..."
        age -d config.sh.age > config.sh
        echo "  Done."
    else
        cp config.sh.example config.sh
        echo ""
        echo "WARNING: age not available. Created config.sh from template."
        echo "  Edit $HOME/dotfiles/config.sh with your values, then re-run."
        exit 1
    fi
fi
echo ""

# ── 5. Install configs ──
bash install.sh

echo ""
echo "=== Bootstrap complete ==="
echo ""
echo "Next steps:"
echo "  1. Sign into OneDrive and Google Drive (if not already)"
echo "  2. Close and reopen your terminal (to load aliases)"
echo "  3. Run: sit"
echo ""
echo "That's it. sit will clone repos, symlink data from OneDrive, and verify."
