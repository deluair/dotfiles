---
name: clean-wal-shm-files
description: Always clean stale WAL/SHM files from SQLite DBs during deploys and backups
type: feedback
---

Always remove stale WAL/SHM files from SQLite databases during deploys, backups, and transfers.

**Why:** Stale WAL/SHM files caused trade.db corruption on VPS (2026-03-19). A 0-byte WAL with a 32K SHM file made the DB appear malformed. Both VPS copies were corrupted.

**How to apply:**
- Before transferring any .db file: `rm -f *.db-shm *.db-wal`
- After deploying a .db file: clean WAL/SHM at destination
- In backup scripts: never back up WAL/SHM alongside .db files
- If a DB reports "malformed", first check for stale WAL/SHM before assuming data corruption
