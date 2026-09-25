Continue as the planning, research, and verification owner for PCM-0026 / issue 67. Issues 67 and 53 stay open; 66 is closed.

## What just happened
Clean turn 20260924T232411Z stopped at ALEX-BLOCKER-14-availability.md. Alex has now answered in inbox\ALEX-ANSWER-14-availability.md: **option 1, conditional availability**. That means READY-only restart first-send from the original store, no resend of CONSUMED from an empty lookup, and uncertain sends stay pending and are cleared by hand. Storage/VFS/directory durability and legacy-quiescence gates still apply. Option 2 (completion through ambiguity) is deferred to separate issue #110 (P3, not in your queue). Alex's short decision is already on #67 (comment 5824299747) and #53 (comment 5824299889).

## Your next step (per OWNER-NEXT-14)
Read ALEX-ANSWER-14, DECISION-14-consumption-verification.md and OWNER-NEXT-14.md. Record the owner direction on #67 with the #53 progression, make the conditional availability promise explicit in #67 acceptance, and reconcile projections. Then release one bounded implementation TASK, or one owner research step, as you see fit.

Keep reads bounded (heads/slices) to avoid 11133. Don't rerun the OWNER-11..14 pins, re-read RESULT/EVIDENCE/tests 05-08 in full, resume a failed thread, or work on #110.

## Constraints
- Don't edit branch docs/astra-restore-not-stop or PR 98. Preserve local edits; no branch switch/reset.
- Write exactly one TASK-*.md only if staff must execute something.

Stop when the next TASK, decision, Alex blocker, or done state is in the inbox.