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

# Deploy memory (bidirectional merge: newer file wins)
PROJECT_FOLDER=$(encode_claude_path "$HOME")
PROJECT_MEMORY_DIR="$CLAUDE_DIR/projects/$PROJECT_FOLDER/memory"

if [ -d "$DOTFILES_DIR/claude/memory" ]; then
    mkdir -p "$PROJECT_MEMORY_DIR"
    # Merge both directions: newer file wins
    for f in "$DOTFILES_DIR/claude/memory/"*.md; do
        [ -f "$f" ] || continue
        base=$(basename "$f")
        dest="$PROJECT_MEMORY_DIR/$base"
        if [ ! -f "$dest" ] || [ "$f" -nt "$dest" ]; then
            cp "$f" "$dest"
        fi
    done
    # Pull back any files only in active memory
    for f in "$PROJECT_MEMORY_DIR/"*.md; do
        [ -f "$f" ] || continue
        base=$(basename "$f")
        src="$DOTFILES_DIR/claude/memory/$base"
        if [ ! -f "$src" ] || [ "$f" -nt "$src" ]; then
            cp "$f" "$src"
        fi
    done
    count=$(ls "$PROJECT_MEMORY_DIR/"*.md 2>/dev/null | wc -l | tr -d ' ')
    echo "  memory -> merged ($count files)"
fi

# ── Data symlinks (OneDrive is source of truth) ──
echo ""
echo "Data symlinks:"
if [ -d "$ONEDRIVE" ]; then
    link_data "db_backups/trade.db" \
        "trade-explorer/data/trade.db" "trade.db (18GB)" true
    link_data "db_backups/tradeweave_imf_latest.db" \
        "trade-explorer/data/imf.db" "imf.db"
    link_data "db_backups/tradeweave_app_latest.db" \
        "trade-explorer/data/app.db" "app.db"
    link_data "db_backups/bddb_latest.sqlite" \
        "bddata/backend/data/bangladesh.db" "bangladesh.db"
    link_data "db_backups/omtt_bdpolicy_latest.db" \
        "omtt/data/bdpolicy.db" "bdpolicy.db"
    link_data "db_backups/omtt_bangladesh_latest.db" \
        "omtt/data/bangladesh.db" "bangladesh.db (omtt)"
    link_data "db_backups/omtt_baci_latest.db" \
        "omtt/data/baci.db" "baci.db"
    link_data "db_backups/dulalratna_me_latest.db" \
        "dulalratna/me.db" "me.db"
    # Directory symlinks
    link_data "omtt_gis_data/outputs" \
        "omtt/bd_gis/outputs" "gis outputs"
    link_data "omtt_gis_data/local_data" \
        "omtt/bd_gis/local_data" "gis local_data (5GB+)" true
else
    echo "  SKIP  OneDrive not available (sign in first)"
fi

# ── Machine identity for Claude ──
echo ""
echo "Machine identity:"
MACHINE_MARKER="$CLAUDE_DIR/.machine"
echo "$MACHINE_NAME" > "$MACHINE_MARKER"
echo "  $MACHINE_MARKER -> $MACHINE_NAME ($MACHINE_DESC)"

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
echo "Done. Run 'dr' (or 'bash ~/dotfiles/bin/doctor.sh') to verify."
