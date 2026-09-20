# Current Repository Checkpoint

<!-- continuity:current {"active_task":"PCM-0004","active_task_file":"tasks/TASK-PCM-0004-adopt-eval-lab.md","protocol_version":"0.1.0-draft","schema":"project-continuity.current.v1"} -->

## Program state

Phase: adoption — prove v1 in mature repositories.

Current P0 task: `TASK-PCM-0004-adopt-eval-lab.md` / GitHub issue #7 / branch `task/PCM-0004-adopt-eval-lab`.

## Main objective

Adopt the validated continuity protocol in existing repositories without erasing their domain-specific project, task, or handoff semantics.

## Completed

- PCM-0001 — executable v1 schemas/templates/CLI/validator/bootstrap merged;
- PCM-0002 — fresh minimal end-to-end dogfood merged;
- PCM-0003 — non-destructive continuity v1 adoption merged into `Pukujan/custom-extensions`.

## Active

- PCM-0004 — adopt continuity v1 in `Pukujan/Eval-lab` using an explicit legacy-task compatibility boundary.

## Queued

1. PCM-0005 — GitHub Issue adapter and bidirectional consistency checks.
2. PCM-0006 — optional Beads adapter.
3. PCM-0007 — protocol v1.0 release/migration contract.

## Blockers

- Eval-lab PR #20 is mergeable but CI run `35529923987` is red at head `3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981`. Attempt 1 and the single retry attempt 2 failed before any workflow steps were exposed, matching Eval-lab's documented runner-assignment infrastructure condition. Auto-merge is withheld until CI succeeds.

## Next atomic action

Restore or observe successful Eval-lab CI for PR #20 at head `3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981`; only then merge PR #20 and finish PCM-0004.
