---
name: Max parallel agents limit
description: Never launch more than 10 parallel agents at once to avoid context window exhaustion
type: feedback
---

Maximum 10 parallel agents per batch. Never launch 20, 30, 40+ agents at once.

**Why:** Large agent batches (40+) cause context window exhaustion. Each agent's return message consumes context, and the conversation dies before work completes.

**How to apply:** When a task needs many agents (e.g., auditing 40+ files), batch them in waves of 10. Wait for a wave to complete, collect results to /tmp, then launch the next wave. For audit-style tasks, group related files into ~10 logical clusters rather than one-per-file.
