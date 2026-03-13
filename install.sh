#!/bin/bash
# Install dotfiles: link configs, deploy Claude memory, import GPG key.
# Cross-platform: macOS, Windows (Git Bash), Linux.
# Idempotent: safe to run multiple times.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Decrypt or create config.sh if missing
if [ ! -f "$DOTFILES_DIR/config.sh" ]; then
    if [ -f "$DOTFILES_DIR/config.sh.age" ] && command -v age &>/dev/null; then
        echo "Decrypting config.sh from config.sh.age..."
        age -d "$DOTFILES_DIR/config.sh.age" > "$DOTFILES_DIR/config.sh"
        echo "  Decrypted."
    else
        echo "No config.sh found. Creating from template..."
        cp "$DOTFILES_DIR/config.sh.example" "$DOTFILES_DIR/config.sh"
        echo "  Edit $DOTFILES_DIR/config.sh with your values, then re-run."
        [ -f "$DOTFILES_DIR/config.sh.age" ] && echo "  (config.sh.age found but age not installed. Install age to decrypt.)"
        exit 1
    fi
fi

source "$DOTFILES_DIR/paths.sh"

# Validate config.sh has real values (not placeholders)
if [ "$GIT_USER_NAME" = "Your Name" ] || [ "$GIT_USER_EMAIL" = "you@example.com" ] || [ "$GITHUB_USER" = "your-github-username" ]; then
    echo "ERROR: config.sh still has placeholder values. Edit it first:"
    echo "  $DOTFILES_DIR/config.sh"
    exit 1
fi

echo "=== Installing dotfiles ($OS) ==="
echo ""

# ── Shell config ──
echo "Shell config:"

# Determine source file based on OS
if [ "$OS" = "macos" ] || [ "$OS" = "linux" ]; then
    SHELL_SRC="$DOTFILES_DIR/shell/zshrc"
else
    SHELL_SRC="$DOTFILES_DIR/shell/bashrc"
fi

# Preserve existing shell config as .local
if [ -f "$SHELL_RC" ] && [ ! -L "$SHELL_RC" ]; then
    if ! grep -q "Managed by ~/dotfiles" "$SHELL_RC" 2>/dev/null; then
        LOCAL_RC="${SHELL_RC}.local"
        mv "$SHELL_RC" "$LOCAL_RC"
        echo "  Existing $SHELL_RC_NAME moved to ${SHELL_RC_NAME}.local"
    fi
fi
try_link "$SHELL_SRC" "$SHELL_RC"

# .gitconfig (shared settings)
try_link "$DOTFILES_DIR/shell/gitconfig" "$HOME/.gitconfig"

# .gitconfig.local (machine-specific identity, from config.sh)
cat > "$HOME/.gitconfig.local" <<EOF
[user]
	name = $GIT_USER_NAME
	email = $GIT_USER_EMAIL
EOF
echo "  ~/.gitconfig.local -> generated from config.sh"

# ── Claude Code ──
echo ""
echo "Claude Code:"
mkdir -p "$CLAUDE_DIR"

try_link "$DOTFILES_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
try_link "$DOTFILES_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"
try_link "$DOTFILES_DIR/claude/settings.local.json" "$CLAUDE_DIR/settings.local.json"

# Deploy commands (symlink for instant propagation)
if [ -d "$DOTFILES_DIR/claude/commands" ]; then
    # Merge any existing custom commands back to dotfiles first
    if [ -d "$CLAUDE_DIR/commands" ] && [ ! -L "$CLAUDE_DIR/commands" ]; then
        cp -n "$CLAUDE_DIR/commands/"*.md "$DOTFILES_DIR/claude/commands/" 2>/dev/null || true
        rm -rf "$CLAUDE_DIR/commands"
    fi
    if [ "$OS" = "windows" ]; then
        if ln -sf "$DOTFILES_DIR/claude/commands" "$CLAUDE_DIR/commands" 2>/dev/null; then
            echo "  commands -> symlinked"
        else
            mkdir -p "$CLAUDE_DIR/commands"
            cp "$DOTFILES_DIR/claude/commands/"*.md "$CLAUDE_DIR/commands/" 2>/dev/null || true
            echo "  commands -> copied (enable Developer Mode for symlinks)"
        fi
    else
        ln -sf "$DOTFILES_DIR/claude/commands" "$CLAUDE_DIR/commands"
        echo "  commands -> symlinked"
    fi
    count=$(ls "$DOTFILES_DIR/claude/commands/"*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  $count commands available"
fi

# Deploy memory
PROJECT_FOLDER=$(encode_claude_path "$HOME")
PROJECT_MEMORY_DIR="$CLAUDE_DIR/projects/$PROJECT_FOLDER/memory"

if [ -d "$DOTFILES_DIR/claude/memory" ]; then
    mkdir -p "$PROJECT_MEMORY_DIR"
    cp -n "$DOTFILES_DIR/claude/memory/"*.md "$PROJECT_MEMORY_DIR/" 2>/dev/null || true
    count=$(ls "$PROJECT_MEMORY_DIR/"*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  memory -> deployed ($count files)"
fi

# ── GPG key ──
echo ""
echo "GPG key:"
if gpg --list-keys "$GPG_EMAIL" &>/dev/null; then
    echo "  Already imported"
else
    KEY=""
    [ -f "$ONEDRIVE/gpg_backup/${GPG_KEY_NAME}.asc" ] && KEY="$ONEDRIVE/gpg_backup/${GPG_KEY_NAME}.asc"
    [ -z "$KEY" ] && [ -n "$GDRIVE" ] && [ -f "$GDRIVE/../sensitive/gpg_backup/${GPG_KEY_NAME}.asc" ] && KEY="$GDRIVE/../sensitive/gpg_backup/${GPG_KEY_NAME}.asc"
    if [ -n "$KEY" ]; then
        gpg --import "$KEY" 2>/dev/null && echo "  Imported from cloud storage" || echo "  Import failed (check passphrase)"
    else
        echo "  Not found in cloud storage. Import manually:"
        echo "    gpg --import /path/to/${GPG_KEY_NAME}.asc"
    fi
fi

echo ""
echo "Done. Run 'make doctor' to verify."
