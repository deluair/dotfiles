#!/bin/bash
# Verify all prerequisites, data, and configs.
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$DOTFILES_DIR/paths.sh"

echo "=== $MACHINE_NAME ($MACHINE_DESC) ==="
echo "=== Platform: $OS ==="
echo ""

echo "=== Prerequisites ==="
command -v git >/dev/null    && printf "  OK   git\n"        || printf "  MISS git\n"
command -v node >/dev/null   && printf "  OK   node %s\n" "$(node -v 2>/dev/null)" || printf "  MISS node\n"
command -v uv >/dev/null     && printf "  OK   uv\n"         || printf "  MISS uv\n"
command -v gpg >/dev/null    && printf "  OK   gpg\n"        || printf "  MISS gpg\n"
command -v gh >/dev/null     && printf "  OK   gh\n"         || printf "  MISS gh\n"
command -v rsync >/dev/null  && printf "  OK   rsync\n"      || printf "  WARN rsync (optional, using cp fallback)\n"
command -v age >/dev/null    && printf "  OK   age\n"        || printf "  WARN age (optional)\n"
echo ""

echo "=== Cloud Storage ==="
[ -d "$ONEDRIVE" ] && printf "  OK   OneDrive\n" || printf "  MISS OneDrive (sign in and sync)\n"
if [ -n "$GDRIVE" ] && [ -d "$(dirname "$GDRIVE")" ]; then printf "  OK   GDrive\n"; else printf "  MISS GDrive (sign in and sync)\n"; fi
echo ""

echo "=== Configs ==="
if [ -L "$SHELL_RC" ]; then printf "  OK   $SHELL_RC_NAME (symlinked)\n"
elif [ -f "$SHELL_RC" ] && grep -q "Managed by ~/dotfiles" "$SHELL_RC" 2>/dev/null; then printf "  OK   $SHELL_RC_NAME (copied)\n"
else printf "  WARN $SHELL_RC_NAME (not managed, run bash install.sh)\n"; fi
[ -L "$HOME/.gitconfig" ] || [ -f "$HOME/.gitconfig" ] && printf "  OK   .gitconfig\n" || printf "  WARN .gitconfig\n"
([ -L "$HOME/.claude/CLAUDE.md" ] || [ -f "$HOME/.claude/CLAUDE.md" ]) && printf "  OK   CLAUDE.md\n" || printf "  WARN CLAUDE.md\n"
echo ""

echo "=== GPG ==="
if timeout 5 gpg --list-keys "$GPG_EMAIL" >/dev/null 2>&1; then printf "  OK   GPG key imported\n"
elif [ $? -eq 124 ]; then printf "  WARN GPG check timed out (gpg-agent may be stuck)\n"
else printf "  MISS GPG key (run: bash ~/dotfiles/bin/gpg-import.sh)\n"; fi
echo ""

echo "=== Data Files ==="
P="$PROJECTS_DIR"
[ -f "$P/trade-explorer/data/trade.db" ]     && printf "  OK   trade.db\n"      || printf "  MISS trade.db\n"
[ -f "$P/bddata/backend/data/bangladesh.db" ] && printf "  OK   bangladesh.db\n" || printf "  MISS bangladesh.db\n"
[ -f "$P/omtt/data/bdpolicy.db" ]             && printf "  OK   bdpolicy.db\n"   || printf "  MISS bdpolicy.db\n"
[ -f "$P/omtt/data/baci.db" ]                 && printf "  OK   baci.db\n"       || printf "  MISS baci.db\n"
[ -f "$P/dulalratna/me.db" ]                  && printf "  OK   me.db\n"         || printf "  MISS me.db\n"
echo ""

echo "=== Backup Redundancy ==="
[ -f "$ONEDRIVE/db_backups/trade.db" ] && printf "  OK   trade.db in OneDrive\n" || printf "  MISS trade.db in OneDrive\n"
if [ -n "$GDRIVE" ] && [ -f "$GDRIVE/db_backups/trade.db" ]; then printf "  OK   trade.db in GDrive\n"; else printf "  MISS trade.db in GDrive\n"; fi
echo ""

echo "=== Claude Code ==="
MEM_DIR="$HOME/.claude/projects/$(encode_claude_path "$HOME")/memory"
if [ -d "$MEM_DIR" ]; then printf "  OK   memory: %s files\n" "$(ls $MEM_DIR/*.md 2>/dev/null | wc -l | tr -d ' ')"; else printf "  MISS memory\n"; fi
if [ -d "$HOME/.claude/commands" ]; then printf "  OK   commands: %s\n" "$(ls $HOME/.claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ')"; else printf "  MISS commands\n"; fi
echo ""

echo "=== Disk Space ==="
if [ "$OS" = "macos" ]; then
    FREE=$(df -h / | tail -1 | awk '{print $4}')
    printf "  INFO %s free on /\n" "$FREE"
elif [ "$OS" = "windows" ]; then
    FREE=$(df -h /c 2>/dev/null | tail -1 | awk '{print $4}' || echo "?")
    printf "  INFO %s free on C:\n" "$FREE"
fi
