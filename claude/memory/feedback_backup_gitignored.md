---
name: Proactively backup new gitignored data
description: Any time large gitignored data is created or downloaded, immediately add it to backup/restore scripts and run backup. Do not wait to be asked. Never use du/cat/cp on OneDrive files just to check size.
type: feedback
---

When creating or downloading large data that is gitignored (DBs, GeoTIFFs, CSVs, model weights, etc.), proactively:
1. Add entries to `~/dotfiles/backup-data.sh` and `~/dotfiles/restore-data.sh`
2. Update the OneDrive backup map in MEMORY.md
3. Run the backup

**Why:** The machineless setup means every gitignored file must be recoverable from cloud. If data is created but not backed up, switching machines loses it. User had to remind me about bd_gis data (5.4GB local_data + 49MB outputs) that was never backed up.

**How to apply:** After any session that creates/modifies gitignored data files, check if they are in the backup scripts. If not, add them and run backup before session end.

## OneDrive Files On-Demand rule

NEVER use `du`, `cat`, `cp`, `head`, `wc`, or any content-reading command on OneDrive/GDrive cloud files just to check existence or size. These trigger Files On-Demand to download the full file (e.g. 18GB trade.db).

Safe operations on cloud files: `[ -f ]`, `[ -d ]`, `[ -e ]`, `stat`, `ls` (metadata only).
Dangerous operations: `du`, `cat`, `cp`, `rsync`, `head`, `tail`, `wc` (read content, trigger download).

Only read cloud file content when you intend to actually copy/use the file.
