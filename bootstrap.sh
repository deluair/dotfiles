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
    # winget is built into Windows 11. Verify it exists.
    if ! command -v winget &>/dev/null; then
        echo "winget not found. Install 'App Installer' from Microsoft Store, then re-run."
        exit 1
    fi
fi

# ── 2. Clone dotfiles ──
if [ ! -d "$HOME/dotfiles" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/deluair/dotfiles.git "$HOME/dotfiles"
fi

# ── 3. Decrypt or create config.sh ──
cd "$HOME/dotfiles"
if [ ! -f "config.sh" ]; then
    if [ -f "config.sh.age" ] && command -v age &>/dev/null; then
        echo "Decrypting config.sh from config.sh.age..."
        age -d config.sh.age > config.sh
    else
        cp config.sh.example config.sh
        echo "Created config.sh from template. Edit it with your values:"
        echo "  $HOME/dotfiles/config.sh"
    fi
    echo ""
fi

# ── 4. Install system deps + configs ──

if [ "$OS" = "macos" ]; then
    make all
elif [ "$OS" = "windows" ]; then
    # Install deps via winget (idempotent, skips already installed)
    echo "Installing dependencies via winget..."
    winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements 2>/dev/null || true
    winget install -e --id OpenJS.NodeJS.LTS --accept-package-agreements 2>/dev/null || true
    winget install -e --id astral-sh.uv --accept-package-agreements 2>/dev/null || true
    winget install -e --id GnuPG.GnuPG --accept-package-agreements 2>/dev/null || true
    winget install -e --id GitHub.cli --accept-package-agreements 2>/dev/null || true
    winget install -e --id Google.GoogleDrive --accept-package-agreements 2>/dev/null || true
    winget install -e --id Microsoft.OneDrive --accept-package-agreements 2>/dev/null || true
    winget install -e --id FiloSottile.age --accept-package-agreements 2>/dev/null || true
    echo ""
    # Install make (not in winget, download standalone binary)
    if ! command -v make &>/dev/null; then
        echo "Installing GNU Make..."
        mkdir -p "$HOME/.local/bin"
        curl -fsSL "https://raw.githubusercontent.com/deluair/dotfiles/main/bin/make.exe" -o "$HOME/.local/bin/make.exe"
        chmod +x "$HOME/.local/bin/make.exe"
        export PATH="$HOME/.local/bin:$PATH"
        echo "  Installed make to ~/.local/bin/"
    fi
    make install
else
    make install
fi

echo ""
echo "=== Bootstrap complete ==="
echo ""
echo "Next steps:"
echo "  1. Sign into Google Drive and OneDrive"
echo "  2. Wait for cloud storage to sync/mount"
echo "  3. Import GPG key:  make gpg-import"
echo "  4. Clone projects:  make clone-all"
echo "  5. Restore data:    make restore"
echo "  6. Setup projects:  make setup-all"
echo "  7. Verify:          make doctor"
