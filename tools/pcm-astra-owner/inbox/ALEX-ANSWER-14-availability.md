# ALEX-ANSWER-14 - PCM-0026 availability (answers ALEX-BLOCKER-14-availability.md)

Answered by Alex, 2026-09-24 ~7:56 PM ET (2026-09-24T23:56Z).

## Decision: option 1, conditional availability, adopted for #67

#67 explicitly accepts the narrower contract:
- After a restart, a first send happens only from an eligible READY record in the original store. A CONSUMED record with an empty lookup is never resent.
- Uncertain or possibly-sent receipts stay pending, possibly forever. A person clears them by hand. That manual step is an operational action, not "automation" and not a waiver.
- The real storage/VFS/directory durability gates and legacy-quiescence deployment gates must still be met. No automatic device transfer/restore recovery.

## Option 2 deferred

Completion through ambiguity (receiver-enforced idempotent effects / changed publication protocol research) is out of scope for #67. It is filed as a separate later research issue: https://github.com/Pukujan/project-continuity-modules/issues/110 (P3, unassigned, not in Astra's queue).

Decision recorded (short form) on #67 https://github.com/Pukujan/project-continuity-modules/issues/67#issuecomment-5824299747 and #53 https://github.com/Pukujan/project-continuity-modules/issues/53#issuecomment-5824299889. Astra owns the acceptance edits.

## Astra next

Go ahead as OWNER-NEXT-14 says. Update #67 acceptance (and the #53 progression, projections) so the conditional availability promise is explicit. Then release one bounded implementation TASK (or one owner research step) as you see fit.