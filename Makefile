.PHONY: install brew sync push pull doctor backup restore clone-all setup-all sites vps-pull gpg-import lock unlock all deps

# ── Setup ──

# Full setup: deps + install
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
		[ -f "$$ONEDRIVE/gpg_backup/$$GPG_KEY_NAME.asc" ] && KEY="$$ONEDRIVE/gpg_backup/$$GPG_KEY_NAME.asc"; \
		[ -z "$$KEY" ] && [ -n "$$GDRIVE" ] && [ -f "$$GDRIVE/../sensitive/gpg_backup/$$GPG_KEY_NAME.asc" ] && KEY="$$GDRIVE/../sensitive/gpg_backup/$$GPG_KEY_NAME.asc"; \
		if [ -n "$$KEY" ]; then gpg --import "$$KEY"; else echo "Key not found in cloud storage"; fi'

# Clone all project repos
clone-all:
	@bash -c 'source paths.sh; \
	for repo in $$REPOS; do \
		if [ ! -d "$(HOME)/$$repo" ]; then \
			echo "Cloning $$repo..."; \
			git clone "https://github.com/$$GITHUB_USER/$$repo.git" "$(HOME)/$$repo"; \
		else \
			echo "$$repo already exists"; \
		fi \
	done'

# Set up all project dependencies, secrets, and verify builds
setup-all:
	bash setup-projects.sh

# ── Sit down / Stand up ──

# Sit down: pull dotfiles + all repos + deploy configs + restore data
pull:
	@echo "=== Pulling everything ==="
	@git pull --ff-only 2>/dev/null || git pull
	@bash install.sh
	@echo ""
	@bash -c 'source paths.sh; \
	echo "Pulling project repos..."; \
	for repo in $$REPOS; do \
		if [ -d "$(HOME)/$$repo/.git" ]; then \
			printf "  %-20s" "$$repo"; \
			cd "$(HOME)/$$repo" && git pull --ff-only 2>/dev/null && printf "OK\n" || printf "CONFLICT (resolve manually)\n"; \
		fi \
	done'
	@echo ""
	@bash restore-data.sh
	@echo ""
	@make -s doctor

# Stand up: sync memory + push dotfiles + push all project repos
push: sync
	@echo "=== Pushing everything ==="
	@echo ""
	@echo "dotfiles:"
	@git add -A && git diff --cached --quiet || git commit -m "sync memory"
	@git push 2>/dev/null && echo "  OK" || echo "  already up to date"
	@echo ""
	@bash -c 'source paths.sh; \
	echo "Project repos:"; \
	for repo in $$REPOS; do \
		if [ -d "$(HOME)/$$repo/.git" ]; then \
			AHEAD=$$(cd "$(HOME)/$$repo" && git rev-list --count @{u}..HEAD 2>/dev/null || echo "?"); \
			if [ "$$AHEAD" = "0" ] || [ "$$AHEAD" = "?" ]; then \
				printf "  %-20s up to date\n" "$$repo"; \
			else \
				printf "  %-20s pushing $$AHEAD commit(s)... " "$$repo"; \
				cd "$(HOME)/$$repo" && git push 2>/dev/null && printf "OK\n" || printf "FAILED\n"; \
			fi \
		fi \
	done'

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

# Encrypt config.sh with age (passphrase-based)
lock:
	@if ! command -v age >/dev/null 2>&1; then echo "age not installed. Install: brew install age (macOS) or winget install FiloSottile.age (Windows)"; exit 1; fi
	@if [ ! -f config.sh ]; then echo "No config.sh to encrypt"; exit 1; fi
	@age -p config.sh > config.sh.age && echo "config.sh.age written (encrypted)"

# Decrypt config.sh.age with age
unlock:
	@if ! command -v age >/dev/null 2>&1; then echo "age not installed. Install: brew install age (macOS) or winget install FiloSottile.age (Windows)"; exit 1; fi
	@if [ ! -f config.sh.age ]; then echo "No config.sh.age to decrypt"; exit 1; fi
	@age -d config.sh.age > config.sh && echo "config.sh decrypted"

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
	command -v age >/dev/null    && printf "  OK   age\n"        || printf "  WARN age (optional, install for config encryption)\n"; \
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
	gpg --list-keys "$$GPG_EMAIL" >/dev/null 2>&1 && printf "  OK   GPG key imported\n" || printf "  MISS GPG key (run: make gpg-import)\n"; \
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
	echo "=== Claude Code ==="; \
	MEM_DIR="$$HOME/.claude/projects/$$(encode_claude_path "$$HOME")/memory"; \
	if [ -d "$$MEM_DIR" ]; then printf "  OK   memory: %s files\n" "$$(ls $$MEM_DIR/*.md 2>/dev/null | wc -l | tr -d " ")"; else printf "  MISS memory (run make install)\n"; fi; \
	if [ -d "$$HOME/.claude/commands" ]; then printf "  OK   commands: %s\n" "$$(ls $$HOME/.claude/commands/*.md 2>/dev/null | wc -l | tr -d " ")"; else printf "  MISS commands (run make install)\n"; fi; \
	echo ""; \
	echo "=== Disk Space ==="; \
	if [ "$$OS" = "macos" ]; then \
		FREE=$$(df -h / | tail -1 | awk "{print \$$4}"); \
		printf "  INFO %s free on /\n" "$$FREE"; \
	elif [ "$$OS" = "windows" ]; then \
		FREE=$$(df -h /c 2>/dev/null | tail -1 | awk "{print \$$4}" || echo "?"); \
		printf "  INFO %s free on C:\n" "$$FREE"; \
	fi'
