.PHONY: install brew sync push pull doctor backup restore clone-all sites vps-pull gpg-import all deps

# ── Setup ──

# Full setup (macOS): brew + install
all: deps install
	@echo ""
	@echo "Setup complete. Next: make clone-all && make restore && make doctor"

# Install system dependencies (OS-aware)
deps:
	@bash -c 'source paths.sh; \
	if [ "$$OS" = "macos" ]; then \
		brew bundle --file=Brewfile; \
	elif [ "$$OS" = "windows" ]; then \
		echo "Windows: run bootstrap.sh for winget installs, or install manually"; \
	else \
		echo "Linux: install git, node, uv, gpg, gh via your package manager"; \
	fi'

# Symlink configs, deploy Claude memory, import GPG
install:
	bash install.sh

# Import GPG key from cloud storage
gpg-import:
	@bash -c 'source paths.sh; \
		KEY=""; \
		[ -f "$$ONEDRIVE/gpg_backup/deluair_private.asc" ] && KEY="$$ONEDRIVE/gpg_backup/deluair_private.asc"; \
		[ -z "$$KEY" ] && [ -n "$$GDRIVE" ] && [ -f "$$GDRIVE/../sensitive/gpg_backup/deluair_private.asc" ] && KEY="$$GDRIVE/../sensitive/gpg_backup/deluair_private.asc"; \
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

# ── Sit down / Stand up ──

# Sit down: pull dotfiles + all repos + deploy configs + restore data
pull:
	@echo "=== Pulling everything ==="
	@git pull --ff-only 2>/dev/null || git pull
	@bash install.sh
	@echo ""
	@echo "Pulling project repos..."
	@for repo in omtt bddata trade-explorer dulalratna pmgai econai hossen; do \
		if [ -d "$(HOME)/$$repo/.git" ]; then \
			printf "  %-20s" "$$repo"; \
			cd "$(HOME)/$$repo" && git pull --ff-only 2>/dev/null && printf "OK\n" || printf "CONFLICT (resolve manually)\n"; \
		fi \
	done
	@echo ""
	@bash restore-data.sh
	@echo ""
	@make -s doctor

# Stand up: sync memory + commit + push dotfiles
push: sync
	git add -A && git diff --cached --quiet || git commit -m "sync memory" && git push

# Sync Claude memory to dotfiles
sync:
	bash sync-memory.sh

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

# Verify all prerequisites, data, and configs (cross-platform)
doctor:
	@bash -c '\
	source paths.sh; \
	echo "=== Platform: $$OS ==="; \
	echo ""; \
	echo "=== Prerequisites ==="; \
	command -v git >/dev/null    && printf "  OK   git\n"        || printf "  MISS git\n"; \
	command -v node >/dev/null   && printf "  OK   node %s\n" "$$(node -v 2>/dev/null)" || printf "  MISS node\n"; \
	command -v uv >/dev/null     && printf "  OK   uv\n"         || printf "  MISS uv\n"; \
	command -v gpg >/dev/null    && printf "  OK   gpg\n"        || printf "  MISS gpg\n"; \
	command -v gh >/dev/null     && printf "  OK   gh\n"         || printf "  MISS gh\n"; \
	command -v rsync >/dev/null  && printf "  OK   rsync\n"      || printf "  WARN rsync (optional, using cp fallback)\n"; \
	echo ""; \
	echo "=== Cloud Storage ==="; \
	[ -d "$$ONEDRIVE" ] && printf "  OK   OneDrive\n" || printf "  MISS OneDrive (sign in and sync)\n"; \
	if [ -n "$$GDRIVE" ] && [ -d "$$(dirname "$$GDRIVE")" ]; then printf "  OK   GDrive\n"; else printf "  MISS GDrive (sign in and sync)\n"; fi; \
	echo ""; \
	echo "=== Configs ==="; \
	if [ -L "$$SHELL_RC" ]; then printf "  OK   $$SHELL_RC_NAME (symlinked)\n"; \
	elif [ -f "$$SHELL_RC" ] && grep -q "Managed by ~/dotfiles" "$$SHELL_RC" 2>/dev/null; then printf "  OK   $$SHELL_RC_NAME (copied)\n"; \
	else printf "  WARN $$SHELL_RC_NAME (not managed, run make install)\n"; fi; \
	[ -L "$$HOME/.gitconfig" ] || [ -f "$$HOME/.gitconfig" ] && printf "  OK   .gitconfig\n" || printf "  WARN .gitconfig\n"; \
	([ -L "$$HOME/.claude/CLAUDE.md" ] || [ -f "$$HOME/.claude/CLAUDE.md" ]) && printf "  OK   CLAUDE.md\n" || printf "  WARN CLAUDE.md\n"; \
	echo ""; \
	echo "=== GPG ==="; \
	gpg --list-keys deluair@gmail.com >/dev/null 2>&1 && printf "  OK   GPG key imported\n" || printf "  MISS GPG key (run: make gpg-import)\n"; \
	echo ""; \
	echo "=== Data Files ==="; \
	P="$$PROJECTS_DIR"; \
	[ -f "$$P/trade-explorer/data/trade.db" ]     && printf "  OK   trade.db\n"      || printf "  MISS trade.db (make restore)\n"; \
	[ -f "$$P/bddata/backend/data/bangladesh.db" ] && printf "  OK   bangladesh.db\n" || printf "  MISS bangladesh.db\n"; \
	[ -f "$$P/omtt/data/bdpolicy.db" ]             && printf "  OK   bdpolicy.db\n"   || printf "  MISS bdpolicy.db\n"; \
	[ -f "$$P/omtt/data/baci.db" ]                 && printf "  OK   baci.db\n"       || printf "  MISS baci.db\n"; \
	[ -f "$$P/dulalratna/me.db" ]                  && printf "  OK   me.db\n"         || printf "  MISS me.db\n"; \
	echo ""; \
	echo "=== Backup Redundancy ==="; \
	[ -f "$$ONEDRIVE/db_backups/trade.db" ] && printf "  OK   trade.db in OneDrive\n" || printf "  MISS trade.db in OneDrive\n"; \
	if [ -n "$$GDRIVE" ] && [ -f "$$GDRIVE/db_backups/trade.db" ]; then printf "  OK   trade.db in GDrive\n"; else printf "  MISS trade.db in GDrive (make backup)\n"; fi; \
	echo ""; \
	echo "=== Claude Memory ==="; \
	MEM_DIR="$$HOME/.claude/projects/$$(encode_claude_path "$$HOME")/memory"; \
	if [ -d "$$MEM_DIR" ]; then printf "  OK   %s files\n" "$$(ls $$MEM_DIR/*.md 2>/dev/null | wc -l | tr -d " ")"; else printf "  MISS (run make install)\n"; fi; \
	echo ""; \
	echo "=== Disk Space ==="; \
	if [ "$$OS" = "macos" ]; then \
		FREE=$$(df -h / | tail -1 | awk "{print \$$4}"); \
		printf "  INFO %s free on /\n" "$$FREE"; \
	elif [ "$$OS" = "windows" ]; then \
		FREE=$$(df -h /c 2>/dev/null | tail -1 | awk "{print \$$4}" || echo "?"); \
		printf "  INFO %s free on C:\n" "$$FREE"; \
	fi'
