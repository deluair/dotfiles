---
name: new_machine_bootstrap
description: Step-by-step workflow to bootstrap a new machine with dotfiles, projects, and Claude
type: reference
---

## New Machine Bootstrap Workflow

**One command from zero:**
```bash
curl -fsSL https://raw.githubusercontent.com/deluair/dotfiles/main/bootstrap.sh | bash
```

Then sign into OneDrive + GDrive, reopen terminal, and run:
```bash
sit
```

`sit` will: pull dotfiles, install configs, clone all repos, symlink data from OneDrive, run doctor.

**Daily workflow:**
```bash
sit        # start of session
standup    # end of session
```

**Machine auto-detection:** `paths.sh` detects macmini, macair, galaxy, dell from hardware. Storage-tight machines (256GB Macs) automatically skip large data files.

**Why:** Enables true machineless portability. Bootstrap + sign into cloud = running on any machine.

**How to apply:** When setting up a new machine or helping recover from a fresh install, the bootstrap script handles everything. No manual steps beyond signing into cloud storage.
