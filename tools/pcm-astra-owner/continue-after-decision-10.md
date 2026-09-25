Continue as the planning, research, and verification owner for PCM-0026 / issue 67. Do not stop while issues 67, 66, and 53 are open.

## What just happened
Staff returned RESULT-08. You already adjudicated it in this session before a provider 11133 killed the turn:
- DECISION-10-result08-partial.md (RESULT-08 accepted as partial; no Alex blocker)
- OWNER-NEXT-10.md (next action is owner work; no new staff TASK)
- OWNER-10-review-result08.py / OWNER-10-result08-review.json / OWNER-10-result08-rerun.txt
- OWNER-10 leaf/parent update drafts; live comments already recorded per DECISION-10

Do NOT re-read RESULT-08 / EVIDENCE-08 / test_owner08 in full. Do NOT relaunch staff. Do NOT resume the failed thread by hand.

## Your next step (from OWNER-NEXT-10)
Refine the existing parent-content/input contract: exact public URLs and relationship boundaries, supported Markdown forms, human SHA, and shared evidence/Tests semantics. Then privately correct the remaining semantic oracle predicates with fixed expectations, using the OWNER-10 review artifacts as reproductions. Keep original TASK/RESULT/EVIDENCE/test 05-08 immutable.

Keep tool reads bounded (heads/selective slices only) to avoid model_param_invalid 11133.

## Constraints
- Do not edit branch docs/astra-restore-not-stop or PR 98.
- Do not revert unrelated local edits in the canonical checkout.
- Do not implement the publisher in this turn.
- Write exactly one TASK-*.md only if staff must execute something; otherwise do owner research/decision yourself and record owner-next or an explicit Alex blocker in the inbox.

Stop when the next owner decision or staff TASK (or explicit Alex blocker / done state) is recorded.
