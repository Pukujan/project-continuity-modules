# TASK-PCM-0042 — Staff model retirement

<!-- continuity:task {"acceptance": ["docs/ASTRA_GROK_STAFF.md deleted and catalog de-registered with index regenerated and validate VALID", "module-doc example neutralized (fictional ABC-0001, no real writer name or task ID)", "CURRENT records the retirement with the ownership pointer to inference-recommendation-engine", "historical task/checkpoint/issue prose untouched (append-only)", "local gates green (unittest discovery with only the six known macOS-environmental failures, ruff, mypy, compileall, validate, index sync) and the six required hosted contexts pass on the exact merge candidate"], "depends_on": [], "goal": "Retire the one-time Astra/Grok staff-model document so no cold-start session adopts it as live guidance; orchestration recommendations belong to inference-recommendation-engine", "id": "PCM-0042", "issue_url": "https://github.com/Pukujan/project-continuity-modules/issues/129", "next_action": "Open the PR (Refs #129), verify the six required contexts and merge, post the leaf receipt, then mark this projection completed in the closeout increment and close #129.", "owner": "owner/Astra planning", "priority": "P2", "protocol_version": "0.1.0-draft", "schema": "project-continuity.task.v1", "status": "active", "why": "The document claims to be current operating guidance for a fresh session while describing a retired Windows-only inbox model with private paths; it already caused owner corrections this month and will confuse future sessions"} -->

- Status: active
- Owner: owner/Astra planning
- Priority: P2
- Depends on: none

## Human outcome

A cold-start session reading `continuity docs find "staff model"` no longer receives a stale orchestration contract; PCM's live execution model is owner-authorized subagents under `docs/AGENT_LIFECYCLE.md`, and agent-orchestration recommendations live with `Pukujan/inference-recommendation-engine` per the owner.

## Scope and boundaries

Delete `docs/ASTRA_GROK_STAFF.md`; de-register its catalog record; neutralize the shipped module-doc example that named `PCM-0042`/`Astra`; append the retirement note to CURRENT. **Non-goals:** no rewrite of historical task/checkpoint/issue prose (append-only); no changes to `docs/AGENT_LIFECYCLE.md`; no IRE repository edits; no HANDOFF refresh (tracked separately).

## Evidence and sources

Hypothesis test recorded in [#129](https://github.com/Pukujan/project-continuity-modules/issues/129) (2026-09-25): zero mechanical dependencies (`grep` over `tests/ src/ AGENTS.md templates/ .github/` → no hits); live references only in catalog + generated index; `cli.py:1234` requires file+record removal together; demonstrated confusion risk (two owner corrections this session); private Windows paths violate the records policy. Provenance preserved by merged Git history (the file's own commits) and the linked issues.

## Checkpoint log

No checkpoints yet.

## Handoff

Read PROJECT → CURRENT → this task → #129. After the PR merges with required checks, post the leaf receipt on #129, close it, and record completion in a closeout increment.
