---
name: feedback_large_file_transfers
description: Always plan before transferring large files. Never use naive scp for files >1GB. Use rsync with keepalive and resume.
type: feedback
---

Always think before transferring large files (>1GB). Never jump straight to scp or naive transfer.

**Why:** 18GB trade.db transfer failed twice (SSH dropped mid-transfer), wasting time and corrupting the VPS copy. The user had to wait through multiple failed attempts.

**How to apply:**
- For files >1GB, always use `rsync -avzP --inplace --partial -e "ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=5"`
- Consider whether the transfer is even necessary (can we avoid it? split the DB? run ingest remotely?)
- Warn the user about expected transfer time before starting
- For 18GB+ files, suggest alternatives: split DB, remote ingest, or incremental sync
- Never kill a running transfer to retry with a different method without the user's approval
