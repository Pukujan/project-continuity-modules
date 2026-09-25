# Alex decision required - PCM-0026 availability

Published [owner verification decision](https://github.com/Pukujan/project-continuity-modules/issues/67#issuecomment-5824115405) and [parent progression](https://github.com/Pukujan/project-continuity-modules/issues/53#issuecomment-5824116659). Owner verification complete, no staff assignment; existing acceptance unchanged. OWNER-13 section 6 requires this tradeoff when release assumptions cannot be established. This is a design/acceptance choice, not permission for another tool call.

Question: Should #67 explicitly accept conditional READY-only restart availability, including permanently unresolved CONSUMED receipts, or must it finish automatically through the ambiguous consume/send window?

1. Conditional availability: authorize a clearly narrower contract. Restart first-send only from eligible original-store READY; never resend CONSUMED from empty lookup. Some receipts may remain pending forever. Actual storage/VFS/directory durability and legacy-quiescence deployment gates must still be established. No waiver or manual-completion-as-automation claim; no automatic device transfer/restore recovery.
2. Completion through ambiguity: require that stronger intended outcome and authorize owner research into receiver-enforced idempotent effects or a changed publication protocol. May require material scope/architecture changes; another client-side shared database alone is insufficient. No feasibility or API support promised yet.

Neither option is adopted. The owner recommends making the availability promise explicit before product work; model evidence cannot choose this tradeoff for Alex. On answer, append direction/correction on #67 and linked #53 progression, reconcile acceptance/projections, then choose one bounded implementation task or owner research step. No new TASK file now.
