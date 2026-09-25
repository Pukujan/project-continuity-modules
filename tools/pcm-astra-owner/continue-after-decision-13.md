Continue as the planning, research, and verification owner for PCM-0026 / issue 67. Do not stop while issues 67 and 53 are open (#66 is CLOSED / COMPLETED).

## What just happened
Clean turn 20260924T230255Z (exit 0) recorded:
- DECISION-13-restart-first-send-authority.md (restart first-send authority frozen: positive durable READY enrollment before checkpoint effects, original-device store identity, atomic READY-to-CONSUMED; missing/uncertain/other-device never authorize POST; #67 acceptance unchanged; no current Alex blocker)
- OWNER-13-restart-first-send-contract.md (frozen contract)
- OWNER-NEXT-13.md (next action is owner verification of that contract; no new staff TASK; no current Alex blocker)
- Live leaf/parent comments already published per DECISION-13

Do NOT re-run the OWNER-11/12/13 pins or re-read RESULT/EVIDENCE/test 05-08 in full. Do NOT relaunch staff. Do NOT resume any failed 11133 thread.

## Your next step (from OWNER-NEXT-13)
Adversarially verify OWNER-13 durable consumption and migration gates in a private isolated SQLite state-machine harness covering concurrent processes, rollback, ambiguous acknowledgement, restart, wrong/missing store, immutable O/I/S and verified parent linkage; label storage/power-loss and cross-device proof limits. Then decide one bounded implementation TASK or an explicit Alex availability tradeoff. This is owner verification work, not a staff release. Do not import/edit the production publisher or create TASK files merely to delegate design ownership.

Keep tool reads bounded (heads/selective slices only) to avoid model_param_invalid 11133. Prefer DECISION-13, OWNER-13 contract, OWNER-13-sources.json, DECISION-12; OWNER-06 sections 3-6 only for unchanged identity/recovery rules; OWNER-11 verification/audit JSON only for pinned defects.

## Constraints
- Do not edit branch docs/astra-restore-not-stop or PR 98.
- Do not revert unrelated local edits in the canonical checkout.
- Do not implement the publisher in this turn.
- Preserve existing local edits; source drift needs read-only reconciliation, not branch switch/reset.
- Write exactly one TASK-*.md only if staff must execute something; otherwise do owner research/decision yourself and record owner-next or an explicit Alex blocker in the inbox.

Stop when the next owner decision or staff TASK (or explicit Alex blocker / done state) is recorded.