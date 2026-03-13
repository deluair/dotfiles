.PHONY: install brew sync push doctor backup restore clone-all sites vps-pull gpg-import all

# ── Setup ──

# Full setup: brew + install
all: brew install
	@echo ""
	@echo "Setup complete. Next: make clone-all && make restore && make doctor"

# Install system dependencies
brew:
	brew bundle --file=Brewfile

# Symlink configs, deploy Claude memory, import GPG
install:
	bash install.sh

# Import GPG key from cloud storage
gpg-import:
	@bash -c '\
		ONEDRIVE="$$HOME/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage"; \
		GDRIVE="$$HOME/Library/CloudStorage/GoogleDrive-dulal1986@gmail.com/My Drive/dev_backups"; \
		KEY=""; \
		[ -f "$$ONEDRIVE/gpg_backup/deluair_private.asc" ] && KEY="$$ONEDRIVE/gpg_backup/deluair_private.asc"; \
		[ -z "$$KEY" ] && [ -f "$$GDRIVE/sensitive/gpg_backup/deluair_private.asc" ] && KEY="$$GDRIVE/sensitive/gpg_backup/deluair_private.asc"; \
		if [ -n "$$KEY" ]; then gpg --import "$$KEY"; else echo "Key not found in cloud storage"; fi'

# Clone all project repos
clone-all:
	@for repo in omtt bddata trade-explorer dulalratna pmgai econai hossen; do \
		if [ ! -d "$(HOME)/$$repo" ]; then \
			echo "Cloning $$repo..."; \
			git clone "https://github.com/deluair/$$repo.git" "$(HOME)/$$repo"; \
		else \
			echo "$$repo already exists"; \
		fi \
	done

# ── Daily operations ──

# Sync Claude memory to dotfiles
sync:
	bash sync-memory.sh

# Sync + commit + push
push: sync
	git add -A && git diff --cached --quiet || git commit -m "sync memory" && git push

# Incremental backup to OneDrive + GDrive
backup:
	bash backup-data.sh

# Restore data from cloud to project dirs
restore:
	bash restore-data.sh

# Health check all 3 sites
sites:
	bash check-sites.sh

# Pull VPS database backups
vps-pull:
	bash pull-vps-backups.sh

# ── Verification ──

# Verify all prerequisites, data, and configs
doctor:
	@echo "=== Prerequisites ==="
	@command -v git >/dev/null    && printf "  OK   git\n"        || printf "  MISS git\n"
	@command -v node >/dev/null   && printf "  OK   node %s\n" "$$(node -v)" || printf "  MISS node\n"
	@command -v uv >/dev/null     && printf "  OK   uv\n"         || printf "  MISS uv\n"
	@command -v gpg >/dev/null    && printf "  OK   gpg\n"        || printf "  MISS gpg\n"
	@command -v gh >/dev/null     && printf "  OK   gh\n"         || printf "  MISS gh\n"
	@command -v rsync >/dev/null  && printf "  OK   rsync\n"      || printf "  MISS rsync\n"
	@echo ""
	@echo "=== Cloud Storage ==="
	@[ -d "$(HOME)/Library/CloudStorage/OneDrive-UniversityofTennessee" ] \
		&& printf "  OK   OneDrive\n" || printf "  MISS OneDrive\n"
	@[ -d "$(HOME)/Library/CloudStorage/GoogleDrive-dulal1986@gmail.com" ] \
		&& printf "  OK   GDrive\n"   || printf "  MISS GDrive\n"
	@echo ""
	@echo "=== Configs ==="
	@[ -L "$(HOME)/.zshrc" ]     && printf "  OK   .zshrc (symlinked)\n"     || printf "  WARN .zshrc (not symlinked)\n"
	@[ -L "$(HOME)/.gitconfig" ] && printf "  OK   .gitconfig (symlinked)\n" || printf "  WARN .gitconfig (not symlinked)\n"
	@[ -L "$(HOME)/.claude/CLAUDE.md" ] && printf "  OK   CLAUDE.md (symlinked)\n" || printf "  WARN CLAUDE.md (not symlinked)\n"
	@echo ""
	@echo "=== GPG ==="
	@gpg --list-keys deluair@gmail.com >/dev/null 2>&1 \
		&& printf "  OK   GPG key imported\n" \
		|| printf "  MISS GPG key (run: make gpg-import)\n"
	@echo ""
	@echo "=== Data Files ==="
	@[ -f "$(HOME)/trade-explorer/data/trade.db" ]      && printf "  OK   trade.db\n"       || printf "  MISS trade.db (make restore)\n"
	@[ -f "$(HOME)/bddata/backend/data/bangladesh.db" ]  && printf "  OK   bangladesh.db\n"  || printf "  MISS bangladesh.db\n"
	@[ -f "$(HOME)/omtt/data/bdpolicy.db" ]              && printf "  OK   bdpolicy.db\n"    || printf "  MISS bdpolicy.db\n"
	@[ -f "$(HOME)/omtt/data/baci.db" ]                  && printf "  OK   baci.db\n"        || printf "  MISS baci.db\n"
	@[ -f "$(HOME)/dulalratna/me.db" ]                   && printf "  OK   me.db\n"          || printf "  MISS me.db\n"
	@echo ""
	@echo "=== Backup Redundancy ==="
	@ONEDRIVE="$(HOME)/Library/CloudStorage/OneDrive-UniversityofTennessee/hossen_storage"; \
	GDRIVE="$(HOME)/Library/CloudStorage/GoogleDrive-dulal1986@gmail.com/My Drive/dev_backups"; \
	[ -f "$$ONEDRIVE/db_backups/trade.db" ] && printf "  OK   trade.db in OneDrive\n" || printf "  MISS trade.db in OneDrive\n"; \
	[ -f "$$GDRIVE/db_backups/trade.db" ]   && printf "  OK   trade.db in GDrive\n"   || printf "  MISS trade.db in GDrive (make backup)\n"
	@echo ""
	@echo "=== Claude Memory ==="
	@MEM_DIR="$(HOME)/.claude/projects/-Users-$$(whoami)/memory"; \
	[ -d "$$MEM_DIR" ] && printf "  OK   %s files\n" "$$(ls $$MEM_DIR/*.md 2>/dev/null | wc -l | tr -d ' ')" || printf "  MISS (run make install)\n"
