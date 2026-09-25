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

Decisions: verdicts are pure functions over stored artifacts so rescoring never reruns arms; the purity test's dead no-arg score() call (line evaluated via '* 0 or []') was removed as a harness defect, not a contract change.

Blocked/uncertain: none for this milestone.

Next: parent opens PR under required CI + auto-merge; after merge run the 20 hidden arms per docs/plans/PCM-0046-arm-plan.md and report on #139/#137.

### 2026-09-25 20:34:06 UTC — owner/Astra

<!-- continuity:checkpoint {"agent":"owner/Astra","blocked":["20 hidden arms require merged scorer; rubric withheld from participants until then."],"changed":["tests/traversal_scorer.py, tests/test_traversal_scorer.py, tests/fixtures/pcm0046_traversal/** (22 files), tasks/TASK-PCM-0046-traversal-holdout.md"],"completed":["Scorer milestone: RED 42-test suite (positive+negative controls per T1-T4, purity/determinism/vacuity/append-only properties, M1-M4 metamorphic) at 14c65a8; GREEN pure-function scorer, 22 deterministic fixtures, pre-registered rubric.json at d0f9de7; projection filled at e11a569."],"decisions":["Worker T46Scorer2 died on provider 429 before first push; its uncommitted RED file was salvaged and committed by the parent integrator (durability protocol worked as designed). Purity test's dead no-arg score() call removed as harness defect, not contract change."],"evidence":["unittest tests.test_traversal_scorer OK (42); ruff clean; mypy src clean; full discover: six known macOS-environmental failures only (identical at baseline a7d07ca); docs render --check SYNCHRONIZED; validate INVALID only for device-local foreign worktree /private/tmp/pcm-pinned."],"next_action":"Open PR for task/PCM-0046-traversal-holdout, verify six required contexts + auto-merge, then run arms per docs/plans/PCM-0046-arm-plan.md.","protocol_version":"0.1.0-draft","schema":"project-continuity.checkpoint.v1","task_id":"PCM-0046","timestamp":"2026-09-25T20:34:06Z"} -->
<!-- continuity:checkpoint-operation {"payload_sha256":"a66f2e1450224e89f96c6cef7378f44bdd1a8294db6ec678600729a93b747ba7","request_id":"pcm-0046-scorer-20260925","schema":"project-continuity.checkpoint-operation.v1","task_id":"PCM-0046"} -->

Completed:
- Scorer milestone: RED 42-test suite (positive+negative controls per T1-T4, purity/determinism/vacuity/append-only properties, M1-M4 metamorphic) at 14c65a8; GREEN pure-function scorer, 22 deterministic fixtures, pre-registered rubric.json at d0f9de7; projection filled at e11a569.

Evidence:
- unittest tests.test_traversal_scorer OK (42); ruff clean; mypy src clean; full discover: six known macOS-environmental failures only (identical at baseline a7d07ca); docs render --check SYNCHRONIZED; validate INVALID only for device-local foreign worktree /private/tmp/pcm-pinned.

Decisions:
- Worker T46Scorer2 died on provider 429 before first push; its uncommitted RED file was salvaged and committed by the parent integrator (durability protocol worked as designed). Purity test's dead no-arg score() call removed as harness defect, not contract change.

Changed:
- tests/traversal_scorer.py, tests/test_traversal_scorer.py, tests/fixtures/pcm0046_traversal/** (22 files), tasks/TASK-PCM-0046-traversal-holdout.md

Blocked/uncertain:
- 20 hidden arms require merged scorer; rubric withheld from participants until then.

Next:
- Open PR for task/PCM-0046-traversal-holdout, verify six required contexts + auto-merge, then run arms per docs/plans/PCM-0046-arm-plan.md.

### 2026-09-25 20:50:47 UTC — owner/Astra

<!-- continuity:checkpoint {"agent":"owner/Astra","blocked":["External provider rate window; no code or repository work is blocked."],"changed":["tasks/TASK-PCM-0046-traversal-holdout.md (this entry)"],"completed":["Scorer merged to main at 09638d8 (#148, six contexts green, merge receipt 5839360783). 20-arm bundles staged and verified intact (rubric/expected excluded); launcher + pure rescoring harness persisted via #151 with repo-root-relative paths (private absolute path removed pre-merge per reviewer)."],"decisions":["Arms remain the only open acceptance item; #139 stays open until tallies post to #139/#137. Baseline guidance variants defined in docs/plans (rewrite-sections + no-keyword sentence) for the delta arms."],"evidence":["Probe arm T3a1probe at 21:15Z returned provider 429 retry-after ~7.2h (window opens ~04:15Z 2026-09-26); all 20 launches at 20:40Z failed identically pre-execution, so no arm ran and bundles are unmodified (sha256 tree verified against tests/fixtures)."],"next_action":"After ~04:15Z: spawn 20 arms per docs/plans/PCM-0046-arm-launcher.sh, score with docs/plans/PCM-0046-arm-scorer.py, report, closeout PR, close #139, remove worktree.","protocol_version":"0.1.0-draft","schema":"project-continuity.checkpoint.v1","task_id":"PCM-0046","timestamp":"2026-09-25T20:50:47Z"} -->
<!-- continuity:checkpoint-operation {"payload_sha256":"d706a1ca211d5bc7af9b8dba517b3cd76331492d3221371df7f7e8f7d20a6800","request_id":"pcm-0046-armswait-20260925","schema":"project-continuity.checkpoint-operation.v1","task_id":"PCM-0046"} -->

Completed:
- Scorer merged to main at 09638d8 (#148, six contexts green, merge receipt 5839360783). 20-arm bundles staged and verified intact (rubric/expected excluded); launcher + pure rescoring harness persisted via #151 with repo-root-relative paths (private absolute path removed pre-merge per reviewer).

Evidence:
- Probe arm T3a1probe at 21:15Z returned provider 429 retry-after ~7.2h (window opens ~04:15Z 2026-09-26); all 20 launches at 20:40Z failed identically pre-execution, so no arm ran and bundles are unmodified (sha256 tree verified against tests/fixtures).

Decisions:
- Arms remain the only open acceptance item; #139 stays open until tallies post to #139/#137. Baseline guidance variants defined in docs/plans (rewrite-sections + no-keyword sentence) for the delta arms.

Changed:
- tasks/TASK-PCM-0046-traversal-holdout.md (this entry)

Blocked/uncertain:
- External provider rate window; no code or repository work is blocked.

Next:
- After ~04:15Z: spawn 20 arms per docs/plans/PCM-0046-arm-launcher.sh, score with docs/plans/PCM-0046-arm-scorer.py, report, closeout PR, close #139, remove worktree.

## Handoff

Read PROJECT -> CURRENT -> this task -> #139 (method, pre-registered pass rules) -> docs/plans/PCM-0046-arm-plan.md. Scorer/fixtures/rubric are on this branch (14c65a8, d0f9de7); the 20 arms run only after merge with the rubric withheld from participants.
