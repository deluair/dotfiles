---
name: new_machine_bootstrap
description: Step-by-step workflow to bootstrap a new machine with dotfiles, projects, and Claude
type: reference
---

## New Machine Bootstrap Workflow

**Prerequisites**: Git, Python 3.11+, uv, Node.js, GPG

**Steps**:

1. **Clone and install dotfiles**
   ```
   git clone https://github.com/deluair/dotfiles.git ~/dotfiles
   cd ~/dotfiles && make install
   ```

2. **Setup projects** (repeat per project)
   ```
   cd ~/omtt && make setup
   cd ~/bddata && make setup
   cd ~/trade-explorer && make setup
   cd ~/dulalratna && make setup
   cd ~/pmgai && make setup
   cd ~/econai && make setup
   ```

3. **After each Claude session**, push dotfiles changes:
   ```
   cd ~/dotfiles && make push
   ```

**Why:** Enables machineless portability. Clone + make setup = running on any machine.

**How to apply:** When setting up a new machine or helping recover from a fresh install, follow this sequence. Dotfiles go first (shell config, GPG, git), then individual projects.
