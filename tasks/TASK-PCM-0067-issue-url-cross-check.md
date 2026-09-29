# TASK-PCM-0067 — Issue URL Origin Cross-Check for All Tasks

<!-- continuity:task {"acceptance": ["Red-first test: a fixture repository with an origin remote, one active task and one completed task whose issue_url points at a validly-shaped issue in a foreign repository; validate exits non-zero naming the file and the mismatch (1 failing test before, passing after).", "The origin cross-check runs for every task file whose issue_url is present when trackers.github is on and origin resolves to a GitHub repository, keeping the existing error text style; a missing or null issue_url stays legal on every task file, and the requirement that an issue_url exist remains scoped to the CURRENT-active task exactly as today.", "Existing fixtures or tests that rely on active-only checking are updated in the same change; the full PCM suite, ruff, mypy, compileall, continuity validate and the docs index check stay green."], "depends_on": [], "goal": "Make continuity validate cross-check every task file's issue_url against the checkout's origin repository, not only the CURRENT-active task, so a wrong-repo tracker link on a completed or pending projection can never print VALID (Refs #209).", "id": "PCM-0067", "issue_url": "https://github.com/Pukujan/project-continuity-modules/issues/209", "next_action": "No product work remains. Remove the managed worktree with `continuity worktree remove PCM-0067` now that this task reads completed on origin/main.", "owner": "omp worker (delegated)", "priority": "P1", "protocol_version": "0.1.0-draft", "schema": "project-continuity.task.v1", "status": "completed", "why": "A well-formed issue_url pointing at another repository on a non-active task file passes every deterministic gate today (observed VALID, exit 0), so a cold-start agent silently follows a tracker link that does not own the task — the exact authority break the link exists to prevent."} -->

- Status: completed (delivered in PR #216, squash `a3931c1`; leaf issue #209 closed 2026-09-29)
- Owner: omp worker (delegated)
- Priority: P1
- Depends on: none

## Goal

Make continuity validate cross-check every task file's issue_url against the checkout's origin repository, not only the CURRENT-active task, so a wrong-repo tracker link on a completed or pending projection can never print VALID (Refs #209).

## Why

`continuity validate` pattern-checks issue_url on every task file but compares the URL's repository with origin only inside the active-task branch (src/continuity/cli.py, active-task block near lines 1665-1681). Observed on a target overlay checkout: an inactive task file pointing at `https://github.com/evil-org/other-repo/issues/999999` printed VALID, exit 0 — the exact silent authority break the tracker link is supposed to prevent.

## Allowed files

src/continuity/cli.py (validate_repo task-file loop), tests/test_cli.py or a new tests file for the red-first case, and any existing fixtures/tests that encoded the active-only behavior. Out of scope: network verification of issue existence (repo-scope match only), schema-version bumps, TARGET_ADOPTION wording (that is PCM-0068), and the receipt/checkpoint publication paths.

## Human outcome

A cold-start agent reading any task projection follows a tracker link that provably belongs to this repository's remote; a mistyped or copy-pasted wrong-repo issue URL on a completed or pending task fails validation with a named file and mismatch instead of silently passing.

## Scope and boundaries

- In scope: validate_repo cross-check for all task files with issue_url present when trackers.github is true and origin resolves to a GitHub repository; red-first test with a real `git init` + `git remote add origin` fixture (a bare tempdir without origin cannot fire the check, so the test must set one up or it is a fake red).
- Out of scope: docs-index render warning (#210 / PCM-0068); issue-existence network probes; changes to task_new's existing origin check.
- Dependencies/uncertainty: none. Note PCM-0066 remains reserved for #201; this task skips that number deliberately.

## Acceptance criteria

- [x] Red-first test delivered: `tests/test_cli.py::test_issue_url_origin_cross_check_covers_every_task_file` failed before the fix (`'…TASK-APP-0002-done.md: issue_url repository evil-org/other-repo does not match origin example/real-repo' not found in []`) and passes after, on a fixture with a real `git init` + `git remote add origin` plus a matching-URL negative control.
- [x] Cross-check widened to every task file carrying an `issue_url` string when `trackers.github` is on, with the existing message text preserved; the existence requirement stayed scoped to the CURRENT-active task, so the six non-CURRENT `status: active` task files without an `issue_url` still validate.
- [x] No existing fixture asserted the active-only behavior, so none needed updating; the local run at the pushed branch showed only the six recorded macOS-environmental names (zero new) with `validate` VALID and `docs render --check` SYNCHRONIZED. Post-merge gate authority is the hosted CI aggregate `gates` = SUCCESS on PR #216, which is what actually proves suite/lint/build state on `main`, not the worker's local run.

## Evidence and sources

Observed on continuity 0.6.0 against a target overlay checkout, 2026-09-26 ~22:20Z: malformed URL -> INVALID (schema pattern, every file); foreign-repo well-formed URL on an inactive task -> VALID exit 0; the same URL on the active task -> ERROR from the origin cross-check. Full reproduction record: issue #209 body.

## Related records

- Required leaf owning issue, parent ancestry and dependencies (or explicitly none): leaf #209 (PCM-0067); parent: none; dependencies: none.
- Primary writer / branch / source issue revision / as-of status: omp delegated worker, sole writer on task/PCM-0067-issue-url-cross-check; source: live #209 body as of 2026-09-26T22:14Z; projection created 2026-09-29.
- Related PR/CI evidence and push receipt (request ID / SHA): projection checkpoint push `870df40` (request `70292a163ede46d3bc4d2a432464691d`, receipt 5896825798, merge receipt 5896922871 for PR #215 squash `0dfe798`); implementation checkpoint push `2e9ad8e` (request `6d1eaca1b6e748e089f5e7805575be56`) → PR #216 merged as squash `a3931c1b2536c24b9d330d9cf0d019cd3f34c318` with required gate `gates` SUCCESS; #209 CLOSED as completed on that evidence.

## Checkpoint log

Delivery summary: the projection increment (coordinator) and the implementation increment (delegated worker) are both recorded below; nothing in this task remains open.

### 2026-09-29 19:04:34 UTC — omp-owner-session (coordinator)

<!-- continuity:checkpoint {"agent":"omp-owner-session (coordinator)","blocked":[],"changed":["tasks/TASK-PCM-0067-issue-url-cross-check.md, tasks/TASK-PCM-0068-docs-index-adoption-step.md, checkpoints/CURRENT.md"],"completed":["Published the PCM-0067/PCM-0068 task projections from the two fresh defect issue logs (#209 wrong-repo issue_url passes validate on non-active tasks; #210 overlay adopter is VALID but docs find errors), synced checkpoints/CURRENT.md (active_task moved off the owner-gated PCM-0050 to PCM-0067, with the reason and the CI consequence recorded), and recorded writer/branch identity on both leaf issues before the projection landed."],"decisions":["PCM-0066 stays reserved for #201, so this wave allocates 0067/0068. The new task files are deliberately NOT registered in .continuity/documents.json yet: a cataloged checkpoint path makes the checkpoint regenerate docs/CONTINUITY_INDEX.md, and two parallel worker branches would both rewrite that generated view and trigger the stale-base refusal on the second push; catalog registration is deferred to the single-writer closeout. Publication is serialized: PCM-0067 merges first, PCM-0068 rebases onto it with a fresh request ID, never --allow-stale-base."],"evidence":["continuity validate --root . now reports only the pre-existing /private/tmp/pcm-pinned foreign-worktree error (the two missing-'why' schema errors I introduced were fixed in the same increment); PYTHONPATH=src python -m unittest discover -s tests -> 274 tests, 5 failures + 1 error = the six recorded macOS-environmental names (test_worktrees: confined/refuses/distinct + another_drive error; test_cli: preflight_rejects + unavailable_canonical_state), zero new; issue comments 5896436577 (#209) and 5896436590 (#210)."],"next_action":"Create the two managed worktrees from merged main and hand PCM-0067/PCM-0068 to one worker each; workers keep their own task files status active and never edit CURRENT or .continuity.","protocol_version":"0.1.0-draft","schema":"project-continuity.checkpoint.v1","task_id":"PCM-0067","timestamp":"2026-09-29T19:04:34Z"} -->
<!-- continuity:checkpoint-operation {"payload_sha256":"0ea7c7258c26c6f774da2bf6fdf298d2e62db947d3fc8ff78799a7bc1bda406f","request_id":"70292a163ede46d3bc4d2a432464691d","schema":"project-continuity.checkpoint-operation.v1","task_id":"PCM-0067"} -->

Completed:
- Published the PCM-0067/PCM-0068 task projections from the two fresh defect issue logs (#209 wrong-repo issue_url passes validate on non-active tasks; #210 overlay adopter is VALID but docs find errors), synced checkpoints/CURRENT.md (active_task moved off the owner-gated PCM-0050 to PCM-0067, with the reason and the CI consequence recorded), and recorded writer/branch identity on both leaf issues before the projection landed.

Evidence:
- continuity validate --root . now reports only the pre-existing /private/tmp/pcm-pinned foreign-worktree error (the two missing-'why' schema errors I introduced were fixed in the same increment); PYTHONPATH=src python -m unittest discover -s tests -> 274 tests, 5 failures + 1 error = the six recorded macOS-environmental names (test_worktrees: confined/refuses/distinct + another_drive error; test_cli: preflight_rejects + unavailable_canonical_state), zero new; issue comments 5896436577 (#209) and 5896436590 (#210).

Decisions:
- PCM-0066 stays reserved for #201, so this wave allocates 0067/0068. The new task files are deliberately NOT registered in .continuity/documents.json yet: a cataloged checkpoint path makes the checkpoint regenerate docs/CONTINUITY_INDEX.md, and two parallel worker branches would both rewrite that generated view and trigger the stale-base refusal on the second push; catalog registration is deferred to the single-writer closeout. Publication is serialized: PCM-0067 merges first, PCM-0068 rebases onto it with a fresh request ID, never --allow-stale-base.

Changed:
- tasks/TASK-PCM-0067-issue-url-cross-check.md, tasks/TASK-PCM-0068-docs-index-adoption-step.md, checkpoints/CURRENT.md

Blocked/uncertain:
- none

Next:
- Create the two managed worktrees from merged main and hand PCM-0067/PCM-0068 to one worker each; workers keep their own task files status active and never edit CURRENT or .continuity.

### 2026-09-29 19:30:53 UTC — Pcm0067Validator (omp delegated worker)

<!-- continuity:checkpoint {"agent":"Pcm0067Validator (omp delegated worker)","blocked":[],"changed":["src/continuity/cli.py, tests/test_cli.py"],"completed":["Widened validate_repo's issue_url origin cross-check from only the CURRENT-active task to every task file carrying an issue_url string when trackers.github is on; the existence requirement (active task requires issue_url) stays scoped to the CURRENT-active task; error text unchanged."],"decisions":["Kept the validate_github_issue_url try/except per URL so active-task behavior is unchanged, and hoisted origin resolution to once per validate instead of re-running git inside the active-task branch; no schema version bump, no network probes, task_new origin check untouched."],"evidence":["Red-first: tests.test_cli.test_issue_url_origin_cross_check_covers_every_task_file failed before the fix (AssertionError: '...TASK-APP-0002-done.md: issue_url repository evil-org/other-repo does not match origin example/real-repo' not found in []) and passes after; fixture uses real git init + origin remote example/real-repo and includes the negative control (completed task with matching URL validates []). Local gates on Python 3.11/3.12/3.14: only the six recorded macOS-environmental baseline names fail (test_worktrees confined/refuses/distinct + another_drive error; test_cli preflight_rejects + unavailable_canonical_state), zero new; uvx ruff@0.6.9 reports only the two pre-existing ISC003 findings (cli.py:624,683); uvx mypy src clean; compileall clean; continuity validate --root . prints VALID; docs render --check prints SYNCHRONIZED; package build and tests/package_smoke.py all PASS in a .[dev] venv."],"next_action":"Open the PR to main with Refs #209 and no closing keyword, then post the pushed-not-delivered receipt on #209 keyed to this REQUEST_ID and the pushed branch-head SHA.","protocol_version":"0.1.0-draft","schema":"project-continuity.checkpoint.v1","task_id":"PCM-0067","timestamp":"2026-09-29T19:30:53Z"} -->
<!-- continuity:checkpoint-operation {"payload_sha256":"f9d302662b2d4cbd6112e7902e183e614d8f22df31086530c0925ffb7269f827","request_id":"6d1eaca1b6e748e089f5e7805575be56","schema":"project-continuity.checkpoint-operation.v1","task_id":"PCM-0067"} -->

Completed:
- Widened validate_repo's issue_url origin cross-check from only the CURRENT-active task to every task file carrying an issue_url string when trackers.github is on; the existence requirement (active task requires issue_url) stays scoped to the CURRENT-active task; error text unchanged.

Evidence:
- Red-first: tests.test_cli.test_issue_url_origin_cross_check_covers_every_task_file failed before the fix (AssertionError: '...TASK-APP-0002-done.md: issue_url repository evil-org/other-repo does not match origin example/real-repo' not found in []) and passes after; fixture uses real git init + origin remote example/real-repo and includes the negative control (completed task with matching URL validates []). Local gates on Python 3.11/3.12/3.14: only the six recorded macOS-environmental baseline names fail (test_worktrees confined/refuses/distinct + another_drive error; test_cli preflight_rejects + unavailable_canonical_state), zero new; uvx ruff@0.6.9 reports only the two pre-existing ISC003 findings (cli.py:624,683); uvx mypy src clean; compileall clean; continuity validate --root . prints VALID; docs render --check prints SYNCHRONIZED; package build and tests/package_smoke.py all PASS in a .[dev] venv.

Decisions:
- Kept the validate_github_issue_url try/except per URL so active-task behavior is unchanged, and hoisted origin resolution to once per validate instead of re-running git inside the active-task branch; no schema version bump, no network probes, task_new origin check untouched.

Changed:
- src/continuity/cli.py, tests/test_cli.py

Blocked/uncertain:
- none

Next:
- Open the PR to main with Refs #209 and no closing keyword, then post the pushed-not-delivered receipt on #209 keyed to this REQUEST_ID and the pushed branch-head SHA.

## Handoff

Read PROJECT → CURRENT → this task → minimum relevant spec. Checkpoint before stopping.
