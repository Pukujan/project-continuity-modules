# TASK-PCM-0063 — T2 Staleness Guidance Decision

<!-- continuity:task {"acceptance": ["Owner records the A/B/C decision on #189.", "If A: T2-v2 holdout design pre-registered in docs/plans before any guidance edit; rule text in the guidance families generator + all copies, pinned by the policy test; re-measured arms reported honestly with inconclusive counts; six contexts + receipt on #189.", "(proposed) Pass bar unchanged at >=4/5 arms; baseline controls must still fail."], "depends_on": [], "goal": "Decide the read-time staleness-reconciliation rule the T2 holdout proved missing: what an agent must do when a stale projection and the live issue disagree (Refs #189).", "id": "PCM-0063", "issue_url": "https://github.com/Pukujan/project-continuity-modules/issues/189", "next_action": "Owner picks option A (rule + pre-registered T2-v2 holdout), B (rule text only), or C (documented acceptance of the gap) on #189.", "owner": "owner/Astra planning", "priority": "P2", "protocol_version": "0.1.0-draft", "schema": "project-continuity.task.v1", "status": "active", "why": "PCM-0046 hidden arms: T2 measured 0/5 — every fresh agent asserted the stale next action as current though the live issue state was attached; three stated the contradiction in their own words and still recommended it. Guidance today is write-time only."} -->

- Status: active
- Owner: owner/Astra planning
- Priority: P2
- Depends on: none

## Goal

Decide the read-time staleness-reconciliation rule the T2 holdout proved missing: what an agent must do when a stale projection and the live issue disagree (Refs #189).

## Why

PCM-0046 hidden arms: T2 measured 0/5 — every fresh agent asserted the stale next action as current though the live issue state was attached; three stated the contradiction in their own words and still recommended it. Guidance today is write-time only.

## Allowed files

After the owner answer on #189: src/continuity/cli.py (guidance generator), all checked-in guidance copies (AGENTS.md, HANDOFF.md, templates/v1/**, .github/**), docs/ISSUE_LOG_FORMAT.md if wording crosses tiers, tests/test_github_progression_policy.py (REQUIRED-pin), docs/plans/ for the T2-v2 pre-registration; this increment changes only this task file. Out: validate/CLI behavior, schemas.

## Human outcome

A fresh agent handed a stale status document and the live issue it references states the contradiction and follows the live fact, instead of recommending an action the issue history already invalidated (T2 measured 0/5 before this task).

## Scope and boundaries

- In scope: the A/B/C decision record on #189; if A, the pre-registered T2-v2 design and guidance-text slice.
- Out of scope: any code change to validate/preflight; reopening #139; adopting a database or crawler for staleness.
- Dependencies/uncertainty: depends on #139 evidence (CLOSED, accepted history); owner gate on #189.

## Acceptance criteria

- [ ] Owner records the A/B/C decision on #189.
- [ ] If A: T2-v2 holdout design pre-registered in docs/plans before any guidance edit; rule text in the guidance families generator + all copies, pinned by the policy test; re-measured arms reported honestly with inconclusive counts; six contexts + receipt on #189.
- [ ] (proposed) Pass bar unchanged at >=4/5 arms; baseline controls must still fail.

## Evidence and sources

T2 tallies + per-arm answers in accepted history at docs/plans/PCM-0046-arms-results/ (merge 969be11); counter-signal (3 arms saw the contradiction, none acted) recorded on #139 comment 5845193587.

## Related records

- Required leaf owning issue, parent ancestry and dependencies (or explicitly none): leaf #189 (PCM-0063); parent: none (evidence child of closed #139; research answer appended to #137 at 5845214460).
- Primary writer / branch / source issue revision / as-of status: owner/Astra (omp session); branch task/PCM-0063-projections (projection increment only, no code); source: live issue bodies; as-of 2026-09-26T11:35Z.
- Related PR/CI evidence and push receipt (request ID / SHA): none yet (decision gate); arms evidence rides PCM-0046 (PRs #188/#192/#193).

## Checkpoint log

No checkpoints yet.

## Handoff

Read PROJECT → CURRENT → this task → minimum relevant spec. Checkpoint before stopping.
