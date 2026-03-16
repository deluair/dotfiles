---
name: Always optimize for time
description: User priority is speed and efficiency in all operations. Avoid slow approaches, always pick the fastest path.
type: feedback
---

Always optimize for time in all operations.

**Why:** User is action-oriented with short messages and expects fast iteration. Slow GEE getInfo() calls, sequential processing, and unnecessary downloads waste time.

**How to apply:**
- Prefer local compute over cloud APIs when data is available locally
- Prefer streaming/lazy approaches (stackstac, COG range requests) over full downloads
- Prefer parallel execution over sequential
- Use coarse resolution (300m) for quick checks, native (30m) only for final outputs
- Kill stuck processes quickly, don't wait
- Batch network calls (ee.Dictionary vs individual getInfo)
- Choose the fastest data source (Planetary Computer > GEE queue)
- Don't reprocess what already exists (check before running)
