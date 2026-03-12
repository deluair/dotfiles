.PHONY: install sync push all

# Full setup on a new machine
install:
	bash install.sh

# Sync memory from local Claude back to dotfiles
sync:
	bash sync-memory.sh

# Sync + commit + push
push: sync
	git add -A && git diff --cached --quiet || git commit -m "sync memory" && git push

# New machine one-liner: make all
all: install
