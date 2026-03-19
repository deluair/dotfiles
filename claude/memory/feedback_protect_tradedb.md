---
name: protect-vps-trade-db
description: VPS trade.db (19GB) is immutable -- never modify, delete, or replace without explicit user permission
type: feedback
---

VPS trade.db must NEVER be modified, deleted, moved, or replaced without explicit user permission.

**Why:** The file was corrupted twice (truncated during transfers). Restored from Google Drive backup on 2026-03-19. User set `chmod 444` + `chattr +i` (immutable) to prevent any process from touching it. Even root cannot modify it without first running `sudo chattr -i`.

**How to apply:**
- Never run any command that writes to, deletes, or replaces trade.db on VPS
- If a deploy script tries to overwrite trade.db, flag it and stop
- If trade.db needs updating, explicitly ask user first, then `sudo chattr -i` before touching, and re-lock after
- The app opens it read-only (`readonly: true` in better-sqlite3), which is correct
- WAL/SHM files next to trade.db should be cleaned during deploys (they caused corruption before)
