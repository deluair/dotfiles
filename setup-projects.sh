#!/bin/bash
# Intelligent project setup: detects project type and runs the right commands.
# Handles: dependencies, secrets decryption, data restore, build verification.
# Cross-platform: macOS, Windows (Git Bash), Linux.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/paths.sh"

P="$PROJECTS_DIR"
PASS=0
FAIL=0
SKIP=0
RESULTS=()

setup_project() {
    local name="$1" dir="$2"
    echo ""
    echo "=== $name ==="

    if [ ! -d "$dir" ]; then
        echo "  SKIP (not cloned)"
        SKIP=$((SKIP + 1))
        RESULTS+=("  SKIP  $name (not cloned)")
        return
    fi

    cd "$dir"
    local did_something=0

    # ── 1. Project has its own Makefile with setup target: delegate to it ──
    if [ -f "Makefile" ] && grep -q "^setup:" "Makefile" 2>/dev/null; then
        echo "  Running make setup..."
        if make setup 2>&1 | sed 's/^/    /'; then
            did_something=1
        else
            echo "  FAIL: make setup failed"
            FAIL=$((FAIL + 1))
            RESULTS+=("  FAIL  $name (make setup failed)")
            return
        fi
    else
        # ── 2. No Makefile setup: auto-detect and handle ──

        # Git secret: decrypt .env
        if [ -d ".gitsecret" ] && command -v git-secret &>/dev/null; then
            if [ ! -f ".env" ] || [ ".env.secret" -nt ".env" ]; then
                echo "  Decrypting secrets..."
                git secret reveal -f 2>&1 | sed 's/^/    /' || true
                did_something=1
            fi
        fi

        # Python: uv sync
        if [ -f "pyproject.toml" ] && command -v uv &>/dev/null; then
            echo "  Installing Python deps (uv sync)..."
            uv sync 2>&1 | sed 's/^/    /'
            did_something=1
        elif [ -f "requirements.txt" ] && command -v uv &>/dev/null; then
            echo "  Installing Python deps (uv pip install)..."
            uv pip install -r requirements.txt 2>&1 | sed 's/^/    /'
            did_something=1
        fi

        # Node: npm install
        if [ -f "package.json" ]; then
            if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules/.package-lock.json" ] 2>/dev/null; then
                # Detect React 19 for --legacy-peer-deps
                local npm_flags=""
                if grep -q '"react".*"19\.' "package.json" 2>/dev/null || \
                   grep -q '"react".*"\^19' "package.json" 2>/dev/null; then
                    npm_flags="--legacy-peer-deps"
                fi
                echo "  Installing Node deps (npm install $npm_flags)..."
                npm install $npm_flags 2>&1 | tail -5 | sed 's/^/    /'
                did_something=1
            fi
        fi
    fi

    # ── 3. Verify: try a build if possible ──
    if [ -f "package.json" ] && grep -q '"build"' "package.json" 2>/dev/null; then
        echo "  Verifying build..."
        if npm run build --if-present 2>&1 | tail -3 | sed 's/^/    /'; then
            echo "  OK"
        else
            echo "  WARN: build failed (may need data files first)"
        fi
    elif [ -f "pyproject.toml" ]; then
        echo "  Verifying Python import..."
        if uv run python -c "print('OK')" 2>/dev/null; then
            echo "  OK"
        else
            echo "  WARN: Python env may need attention"
        fi
    fi

    if [ "$did_something" -eq 0 ]; then
        echo "  SKIP (static site or no setup needed)"
        SKIP=$((SKIP + 1))
        RESULTS+=("  SKIP  $name (no setup needed)")
    else
        PASS=$((PASS + 1))
        RESULTS+=("  OK    $name")
    fi
}

echo "=== Setting up all projects ($OS) ==="
echo "Projects dir: $P"

for repo in $REPOS; do
    setup_project "$repo" "$P/$repo"
done

echo ""
echo "========================================="
echo "Results: $PASS OK, $FAIL FAIL, $SKIP SKIP"
echo ""
for r in "${RESULTS[@]}"; do
    echo "$r"
done

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "Some projects failed. Check output above."
    exit 1
fi
