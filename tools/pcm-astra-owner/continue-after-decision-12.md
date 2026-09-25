Continue as the planning, research, and verification owner for PCM-0026 / issue 67. Do not stop while issues 67 and 53 are open (#66 is CLOSED / COMPLETED).

## What just happened
Clean turn 20260924T225106Z (exit 0) recorded:
- DECISION-12-recovery-availability.md (read-only restart recovery plus manual never-sent receipt completion does NOT meet #67 full availability acceptance; acceptance unchanged; uncertain sends stay read-only)
- OWNER-NEXT-12.md (next action is owner design work; no new staff TASK; no current Alex blocker)
- Live leaf/parent comments already published per DECISION-12

Do NOT re-run the OWNER-11/12 pins or re-read RESULT/EVIDENCE/test 05-08 in full. Do NOT relaunch staff. Do NOT resume any failed 11133 thread (including 20260924T223109Z through 20260924T223125Z).

## Your next step (from OWNER-NEXT-12)
Choose and freeze a restart first-send authority contract for positively established never-sent leaf/parent targets. Name ownership/fencing, durable evidence, old-process/concurrent-device behavior and crash-point outcomes; preserve original pushed SHA/intent and verified leaf linkage. Missing state and empty remote lookup must not authorize a send. If these constraints cannot support a justified contract, return an explicit availability tradeoff for Alex instead of silently narrowing acceptance. This is an owner design decision, not staff execution.

Keep tool reads bounded (heads/selective slices only) to avoid model_param_invalid 11133. Prefer DECISION-12, OWNER-NEXT-12, OWNER-06 sections 3-6, and OWNER-11 verification/audit JSON only for pinned defects.

## Constraints
- Do not edit branch docs/astra-restore-not-stop or PR 98.
- Do not revert unrelated local edits in the canonical checkout.
- Do not implement the publisher in this turn.
- Preserve existing local edits; source drift needs read-only reconciliation, not branch switch/reset.
- Write exactly one TASK-*.md only if staff must execute something; otherwise do owner research/decision yourself and record owner-next or an explicit Alex blocker in the inbox.

Stop when the next owner decision or staff TASK (or explicit Alex blocker / done state) is recorded.
