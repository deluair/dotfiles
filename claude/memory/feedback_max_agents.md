---
name: Max parallel agents limit
description: Never launch more than 15 parallel agents at once to avoid context window exhaustion
type: feedback
---

Maximum 15 parallel agents per batch. Never launch 20, 30, 40+ agents at once.

**Why:** Large agent batches (40+) cause context window exhaustion. Each agent's return message consumes context, and the conversation dies before work completes. Increased from 10 to 15 per user request (2026-03-18).

**How to apply:** When a task needs many agents, batch them in waves of 15. Wait for a wave to complete, collect results to /tmp, then launch the next wave.
