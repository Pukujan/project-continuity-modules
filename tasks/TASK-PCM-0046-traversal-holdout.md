# TASK-PCM-0046 — Traversal holdout

<!-- continuity:task {"acceptance": ["Scorer unit tests green: positive control per T1-T4 and >=3 negative controls each failing exactly its intended check", "Property tests green: purity, determinism, vacuity rules, append-only invariant", "Metamorphic relations green: appended entry does not change prior verdicts; irrelevant text outside graded region is inert; independent-file reorder is inert; presentation permutation agrees", "20 hidden arms (5 fresh sessions x 4 behaviors) run with rubric withheld; per-behavior pass rate >=80% or result reported honestly with inconclusive counts", "Results posted on #139 and appended to #137; local gates clean and six required hosted contexts pass on the exact candidate"], "depends_on": [], "goal": "Run the released P1 reading-side traversal holdout (T1 append-only, T2 authority-over-staleness, T3 keyword-smuggling, T4 index-freshness) with a committed deterministic scorer", "id": "PCM-0046", "issue_url": "https://github.com/Pukujan/project-continuity-modules/issues/139", "next_action": "Build fixtures and scorer red-to-green, then run the 20 hidden arms and report.", "owner": "owner/Astra planning; subagent participants", "priority": "P2", "protocol_version": "0.1.0-draft", "schema": "project-continuity.task.v1", "status": "active", "why": "Every experiment so far tested task-state discovery or record writing; reading-side traversal fidelity is the untested promise PCM sells on"} -->

- Status: active
- Owner: owner/Astra planning; subagent participants
- Priority: P2
- Depends on: none

## Checkpoint log

### 2026-09-25 — scorer, fixtures, rubric delivered (parent integrator)

Completed: RED suite (42 tests: 1 positive + >=3 negative controls per T1-T4, purity/determinism/vacuity/append-only properties, M1-M4 metamorphic relations) committed at 14c65a8 (salvaged uncommitted from T46Scorer2, which died on a provider 429 before its first push); GREEN deterministic scorer + 22 fixtures + rubric.json (pre-registered pass rules: 5 arms/behavior, 4 required, ambiguous->inconclusive, controls stay failing) committed at d0f9de7.

Evidence: unittest tests.test_traversal_scorer -> OK (42); ruff All checks passed; mypy src clean; full discover: only the six known macOS-environmental failures (identical at baseline); docs render --check SYNCHRONIZED; validate INVALID only for the device-local foreign worktree /private/tmp/pcm-pinned (pre-existing; fresh clone unaffected).

Decision: verdicts are pure functions over stored artifacts so rescoring never reruns arms; the purity test's dead no-arg score() call (line evaluated via '* 0 or []') was removed as a harness defect, not a contract change.

Blocked/uncertain: none for this milestone.

Next: parent opens PR under required CI + auto-merge; after merge run the 20 hidden arms per docs/plans/PCM-0046-arm-plan.md and report on #139/#137.

## Handoff

Read PROJECT -> CURRENT -> this task -> #139 (method, pre-registered pass rules) -> docs/plans/PCM-0046-arm-plan.md. Scorer/fixtures/rubric are on this branch (14c65a8, d0f9de7); the 20 arms run only after merge with the rubric withheld from participants.
