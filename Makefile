.PHONY: install sync push all doctor backup brew

# Full setup on a new machine
install:
	bash install.sh

# Install system dependencies via Homebrew
brew:
	brew bundle --file=Brewfile

# Sync memory from local Claude back to dotfiles
sync:
	bash sync-memory.sh

# Sync + commit + push
push: sync
	git add -A && git diff --cached --quiet || git commit -m "sync memory" && git push

# Verify all prerequisites and data files are present
doctor:
	@echo "Checking prerequisites..."
	@command -v git >/dev/null    && echo "  git:    OK" || echo "  git:    MISSING"
	@command -v node >/dev/null   && echo "  node:   OK ($(node -v))" || echo "  node:   MISSING"
	@command -v uv >/dev/null     && echo "  uv:    OK" || echo "  uv:     MISSING"
	@command -v gpg >/dev/null    && echo "  gpg:    OK" || echo "  gpg:    MISSING"
	@command -v gh >/dev/null     && echo "  gh:     OK" || echo "  gh:     MISSING"
	@command -v pm2 >/dev/null    && echo "  pm2:    OK" || echo "  pm2:    MISSING"
	@echo ""
	@echo "Checking cloud storage..."
	@[ -d "$(HOME)/Library/CloudStorage/OneDrive-UniversityofTennessee" ] && echo "  OneDrive: mounted" || echo "  OneDrive: NOT MOUNTED"
	@[ -d "$(HOME)/Library/CloudStorage/GoogleDrive-dulal1986@gmail.com" ] && echo "  GDrive:   mounted" || echo "  GDrive:   NOT MOUNTED"
	@echo ""
	@echo "Checking critical data files..."
	@[ -f "$(HOME)/trade-explorer/data/trade.db" ] && echo "  trade.db (18GB):     present" || echo "  trade.db:            MISSING - restore from OneDrive/GDrive"
	@[ -f "$(HOME)/bddata/backend/data/bangladesh.db" ] && echo "  bangladesh.db:       present" || echo "  bangladesh.db:       MISSING"
	@[ -f "$(HOME)/omtt/data/bdpolicy.db" ] && echo "  bdpolicy.db:         present" || echo "  bdpolicy.db:         MISSING"
	@[ -f "$(HOME)/omtt/data/baci.db" ] && echo "  baci.db:             present" || echo "  baci.db:             MISSING"
	@echo ""
	@echo "Checking GPG key..."
	@gpg --list-keys deluair@gmail.com >/dev/null 2>&1 && echo "  GPG key:  imported" || echo "  GPG key:  NOT IMPORTED - run: gpg --import from OneDrive/GDrive gpg_backup/"
	@echo ""
	@echo "Checking Claude memory..."
	@[ -d "$(HOME)/.claude/projects/-Users-$(shell whoami)/memory" ] && echo "  Claude memory: present ($(ls $(HOME)/.claude/projects/-Users-$(shell whoami)/memory/*.md 2>/dev/null | wc -l | tr -d ' ') files)" || echo "  Claude memory: MISSING - run make install"

# Backup critical data to OneDrive + Google Drive
backup:
	bash backup-data.sh

# New machine one-liner: make all
all: brew install
