#!/usr/bin/env bash
# Quick health check for all 3 sites (cross-platform notifications)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/paths.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
FAIL=0

check() {
    local name=$1 url=$2
    local status
    status=$(curl -sf -o /dev/null -w '%{http_code}' --max-time 10 "$url" 2>/dev/null || echo "000")
    if [ "$status" = "200" ]; then
        printf "  ${GREEN}OK${NC}  %s (%s)\n" "$name" "$url"
    else
        printf "  ${RED}FAIL${NC} %s (HTTP %s)\n" "$name" "$status"
        FAIL=1
    fi
}

notify() {
    local msg="$1"
    if [ "$OS" = "macos" ]; then
        osascript -e "display notification \"$msg\" with title \"Site Monitor\" sound name \"Basso\"" 2>/dev/null || true
    elif [ "$OS" = "windows" ]; then
        powershell.exe -Command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null; [System.Windows.Forms.MessageBox]::Show('$msg','Site Monitor','OK','Warning')" 2>/dev/null || true
    elif [ "$OS" = "linux" ]; then
        notify-send "Site Monitor" "$msg" 2>/dev/null || true
    fi
}

echo "Site health check: $(date)"
echo ""
check "TradeWeave"   "https://tradeweave.org/"
check "BDFacts"      "https://bdfacts.org/"
check "BDPolicy Lab" "https://bdpolicylab.com/api/health"
echo ""

if [ "$FAIL" -eq 1 ]; then
    echo "One or more sites are down!"
    notify "One or more sites are DOWN!"
    exit 1
fi
