---
name: hardware
description: User's hardware inventory - 4 machines, machineless setup must work across all of them
type: user
---

| Machine | Chip/CPU | RAM | Storage | OS | Role |
|---------|----------|-----|---------|----|------|
| Mac Mini | Apple M4 | 16 GB | 256 GB | macOS | Primary desktop |
| MacBook Air | Apple M4 | 16 GB | 256 GB | macOS | Portable |
| Samsung Galaxy Book Edge | Snapdragon X Elite | 16 GB | 512 GB | Windows | Personal laptop |
| Dell Precision 5560 | Intel (likely i7/i9) | 32 GB | 1 TB | Windows/Linux | Official work laptop (UTK) |

**Constraints:**
- 256 GB on both Macs is tight. trade.db alone is 18GB. Be mindful of disk usage.
- Samsung runs ARM Windows (Snapdragon), some tools may need ARM compatibility checks.
- Dell is the beefiest machine (32GB, 1TB), likely best for heavy data processing.
- Machineless setup must work on macOS and Windows (Git Bash/WSL).
