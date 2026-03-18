.PHONY: install brew sync push pull doctor backup restore clone-all setup-all sites vps-pull gpg-import lock unlock all deps

# ── Setup ──

# Full setup: deps + install
all: deps install
	@echo ""
	@echo "Setup complete. Next: make clone-all && make doctor"

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

# Sit down: use 'sit' alias instead (bash bin/sit.sh)
pull:
	@bash bin/sit.sh

# Stand up: use 'standup' alias instead (bash bin/standup.sh)
push:
	@bash bin/standup.sh

# Sync Claude memory to dotfiles
sync:
	bash sync-memory.sh

# GDrive redundancy sync (OneDrive -> GDrive)
backup:
	bash backup-data.sh

# DEPRECATED: data now symlinked to OneDrive via install.sh
restore:
	bash install.sh

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
	@bash bin/doctor.sh
