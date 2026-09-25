# TASK-PCM-0053 — Stale Base Guard

<!-- continuity:task {"acceptance": ["publish_checkpoint refuses (exit non-zero, no commit, no push) when a path touched by the branch or this checkpoint also changed upstream on the origin default branch since the fork, naming the files and the --allow-stale-base opt-out", "Non-overlapping upstream advances, up-to-date branches, and --allow-stale-base opt-outs publish normally; unresolvable/offline origin degrades to proceeding (push error only), never a stale-base refusal; recovery receipts skip the guard", "Red-first deterministic tests in tests/test_checkpoint_stale_base.py (5 cases); existing checkpoint/hygiene/retry suites and full discover stay at the known baseline; six required hosted contexts on the candidate"], "depends_on": [], "goal": "Make continuity checkpoint refuse to publish when the increment overlaps upstream changes on a stale local base.", "id": "PCM-0053", "issue_url": "https://github.com/Pukujan/project-continuity-modules/issues/166", "next_action": "Open PR for task/PCM-0053-stale-base-guard, verify six required contexts + auto-merge, post merge receipt on #166.", "owner": "owner/Astra planning", "priority": "P2", "protocol_version": "0.1.0-draft", "schema": "project-continuity.task.v1", "status": "active", "why": "A worker branched from a stale local origin/main while the live default had advanced; the same local-outranks-remote class mis-closed #139 via a stale CLI. The guard closes the silent-revert window before push."} -->

- Status: active
- Owner: owner/Astra planning
- Priority: P2
- Depends on: none

## Goal

Make continuity checkpoint refuse to publish when the increment overlaps upstream changes on a stale local base.

## Why

A worker branched from a stale local origin/main while the live default had advanced; the same local-outranks-remote class mis-closed #139 via a stale CLI. The guard closes the silent-revert window before push.

## Allowed files

- src/continuity/cli.py (publish_checkpoint + _stale_base_overlap + flag), tests/test_checkpoint_stale_base.py (new), tasks/TASK-PCM-0053-stale-base-guard.md, .continuity/documents.json, docs/CONTINUITY_INDEX.md (generated).

## Human outcome

A fresh session that forgot `git fetch origin` learns before its checkpoint commits: the tool names the exact files where its stale base would silently overwrite accepted history, and says rebase (or opt out loudly). The GitHub-authoritative invariant stops depending on writer memory.

## Scope and boundaries

- In scope: overlap-based staleness refusal in the checkpoint publish path; --allow-stale-base opt-out; degraded-mode NOTE for unresolvable origins.
- Out of scope: auto-rebase; GitHub API staleness checks; the #162 version-drift gate; AGENTS/SPEC normative wording (owner decision territory).
- Dependencies/uncertainty: race window narrowed, not closed — hosted CI conflict detection remains the last line (recorded as honest caveat on #166).

## Acceptance criteria

- [x] publish_checkpoint refuses overlapping stale bases, naming files + opt-out (tests: overlap refused, no commit, no push).
- [x] Non-overlap/fresh/opt-out publish; offline origin proceeds past the guard; recovery skips it.
- [ ] PR under six required hosted contexts + auto-merge, merge receipt on #166 (open at checkpoint time).

## Evidence and sources

RED: 2 failures + 1 error before the guard (overlap not refused; TypeError on unknown kwarg). GREEN: tests.test_checkpoint_stale_base 5/5 OK; test_checkpoint_hygiene + test_checkpoint_retries OK; full discover 257 tests = exactly the six known macOS-environmental failures, identical at baseline f4ffd6f. ruff: only the two pre-existing ISC003 findings remain (uvx ruff@0.6.9); new code clean. Issue #166 carries the incident observations (22:1xZ stale base, 22:56Z stranded commit).

## Reproduction details (only when needed)

`PYTHONPATH=src python3.12 -m unittest tests.test_checkpoint_stale_base`; fixtures are local bare-remote clones (no network).

## Related records

- Leaf #166 (PCM-0053); parent: none; depends on none; related #162 (sibling stale-tool incident), #139/#161/#164/#165 (observed instances).
- Primary writer: owner/Astra; branch task/PCM-0053-stale-base-guard; source issue revision: #166 body at filing; as-of 2026-09-25T23:20Z.
- Push receipt: continuity checkpoint request pcm-0053-guard-20260925.

## Checkpoint log

No checkpoints yet.

## Handoff

Read PROJECT → CURRENT → this task → minimum relevant spec. Checkpoint before stopping.
