Continue as the planning, research, and verification owner for PCM-0026 / issue 67. Issues 67 and 53 stay open; 66 is closed.

## What just happened
Clean turn 20260925T000128Z finished DECISION-15 and OWNER-NEXT-15. Alex's option-1 conditional availability is already recorded on #67 and #53. There is no current Alex blocker and no unconsumed staff TASK.

## Your next step (per OWNER-NEXT-15)
Do the owner research/design step in OWNER-NEXT-15.md: define one fail-closed deployment admission profile for the OWNER-13 original-store READY path (storage/VFS/fresh-directory durability, original-store provenance, legacy-writer quiescence, denial when any gate is unknown). Start from DECISION-15-conditional-availability.md. Return a reviewable admission decision and the narrowest implementation boundary. Do not release a staff TASK unless staff must execute something concrete.

Keep reads bounded (heads/slices) to avoid 11133. Don't rerun OWNER-11..14 pins, re-read RESULT/EVIDENCE/tests 05-08 in full, resume a failed thread, or work on #110.

## Constraints
- Don't edit branch docs/astra-restore-not-stop or PR 98. Preserve local edits; no branch switch/reset.
- No publisher edit, live receipt experiment, push/PR/merge, or new checkout/worktree.
- Write exactly one TASK-*.md only if staff must execute something.

Stop when the admission decision (and at most one bounded TASK) is in the inbox.
