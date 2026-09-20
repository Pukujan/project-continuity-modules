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

None known.

## Next atomic action

Create an Eval-lab adoption branch from authoritative `main`, add the compatibility overlay, validate it with PCM v1, and merge only after all available target-repository gates pass.
