PCM-0026 owner (#67/#53 open; #66 closed). Prior auto-retry chain on InferHub 11133 is exhausted (origin receipt 20260925T002506Z, retries 1+2 used). Start a new thread; do not resume any failed thread id.

Goal for this turn only: finish OWNER-NEXT-15 — one fail-closed deployment admission profile for the OWNER-13 original-store READY path (durability / provenance / legacy-writer quiescence / deny-when-unknown), plus the narrowest implementation boundary. Write DECISION-16 (or equivalent) and OWNER-NEXT-16 if needed into the inbox, then stop.

Already present: DECISION-15-conditional-availability.md, OWNER-NEXT-15.md, partial OWNER-16-research.py (finish or supersede; do not restart from scratch). No unconsumed staff TASK (TASK-08 already has RESULT-08). Do not release a staff TASK unless staff must run something concrete.

Hard limits to avoid another 11133: read only heads/short slices; never dump full TASK/RESULT/EVIDENCE/tests 05-08; do not rerun OWNER-11..14 pins; skip #110. Do not edit docs/astra-restore-not-stop, PR 98, publisher code, or push/merge. Preserve local checkout edits; no branch switch/reset.

Stop when the admission decision is in the inbox (and at most one bounded TASK if truly required).
