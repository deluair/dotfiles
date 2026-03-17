---
name: feedback_smart_time
description: ABSOLUTE PRIORITY. Be extremely smart about time. No unnecessary testing, no polling, no retries. Action first, verify once.
type: feedback
---

Be extremely smart about time. The user values efficiency above all else.

**Why:** The 2026-03-16 session had repeated time waste: running generation 3 times to verify, polling TaskOutput in loops, testing the same thing multiple ways, running tests then running the same code manually, asking questions that could be answered by just doing the work. User explicitly said "its just wasting time", "be smart about time please", "wtf".

**How to apply:**
1. Do the work, verify ONCE. Not twice. Not three times.
2. Never poll TaskOutput in a loop. If a background task is slow, investigate why or move on.
3. Never test the same thing two different ways (pytest AND manual python -c)
4. Never ask "want me to do X?" when the answer is obviously yes. Just do it.
5. Combine commands: rsync + install + generate + restart in ONE ssh call, not four.
6. If something fails, diagnose the root cause. Don't retry the same command.
7. If generating 8 briefs, do it in one script, not one by one.
8. Trust that code works after tests pass. Don't manually verify what tests already cover.
9. Context-switching between local and VPS is expensive. Batch all local work, then batch all VPS work.
10. If the user says "go on", they mean stop explaining and start executing.
