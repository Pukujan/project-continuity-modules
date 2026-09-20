# TASK-PCM-0004 — Adopt continuity v1 in Eval-lab

<!-- continuity:task {"acceptance":["Eval-lab adoption targets authoritative main rather than the stale configured default branch","existing Eval-lab PROJECT/AGENTS/CURRENT/domain task/checkpoint semantics are preserved","target .continuity/config.json declares protocol/version/software profile/EVAL prefix and canonical PROJECT/CURRENT paths","target uses a separate .continuity/tasks machine namespace so legacy task history is not silently rewritten","PROJECT.md and checkpoints/CURRENT.md carry valid continuity metadata markers","CURRENT explicitly documents the legacy-task compatibility boundary and does not falsely claim a machine active task","target schemas/v1 exactly match the protocol repository v1 schemas","target continuity overlay validates with the PCM v1 validator","no Eval-lab scientific/runtime code or active TASK-0005 implementation/PR is changed or merged by this task","target adoption PR and PCM PR are merged only after mergeability and all available CI/status gates pass","exact evidence, decisions, blockers, changed paths, and one next action are checkpointed before stop"],"depends_on":["PCM-0003"],"goal":"Adopt Project Continuity Protocol v1 in Pukujan/Eval-lab without rewriting its mature legacy task/checkpoint history or disturbing active scientific work.","id":"PCM-0004","next_action":"Create an Eval-lab adoption branch from main, add the compatibility overlay, validate it with PCM v1, and merge only after all available target-repository gates pass.","owner":"ChatGPT/Sol current implementation session; GitHub assignee Pukujan","priority":"P0","protocol_version":"0.1.0-draft","schema":"project-continuity.task.v1","status":"active","why":"Eval-lab already has strong human continuity state, so the adoption risk is preserving that mature history while adding deterministic v1 machine validation without a lossy rewrite."} -->

- Status: active
- Owner: ChatGPT/Sol current implementation session; GitHub assignee Pukujan
- Priority: P0
- Depends on: PCM-0003
- Suggested branch: `task/PCM-0004-adopt-eval-lab`
- GitHub issue: #7
- Target repository: `Pukujan/Eval-lab`
- Target base: `main`

## Goal

Adopt Project Continuity Protocol v1 in `Pukujan/Eval-lab` without rewriting its mature legacy task/checkpoint history or disturbing active scientific work.

## Target repository findings

- repository setting currently names `claude/reliability-walking-skeleton-31b6a2` as default, but it is 27 commits behind `main` with no unique commits;
- repository contracts and local bootstrap docs explicitly use `main` as the authoritative integration branch;
- `PROJECT.md`, `AGENTS.md`, `checkpoints/CURRENT.md`, and `tasks/TASK-*.md` already implement the same layered human continuity model;
- `main` currently records TASK-0005/PR #19 as active domain work;
- legacy task checkpoint entries are heterogeneous and do not uniformly use v1 legacy section labels, so rewriting all nine task histories merely to satisfy the v1 parser would be destructive/noisy.

## Adoption decision

Use a compatibility overlay:
- canonical PROJECT: `PROJECT.md`;
- canonical CURRENT: `checkpoints/CURRENT.md`;
- v1 machine task namespace: `.continuity/tasks`;
- task prefix: `EVAL`;
- machine `active_task=null` on adoption because existing domain tasks remain under the repository's pre-v1 task contract;
- preserve the human CURRENT body so fresh agents still see the exact active domain task/PR;
- add an explicit note explaining this boundary.

This is an adoption, not a silent migration of historical checkpoints. A later explicit migration/adapter may map legacy tasks if warranted.

## Allowed files

In `project-continuity-modules`:
- `tasks/TASK-PCM-0003-adopt-custom-extensions.md` only for final merge status/checkpoint;
- `tasks/TASK-PCM-0004-adopt-eval-lab.md`;
- `checkpoints/CURRENT.md`;
- `HANDOFF.md`.

In `Pukujan/Eval-lab` on a dedicated adoption branch from `main`:
- `.continuity/config.json`;
- `.continuity/tasks/.gitkeep`;
- `schemas/v1/**`;
- `PROJECT.md` metadata marker only;
- `checkpoints/CURRENT.md` metadata marker plus a concise compatibility note.

Do not modify existing `tasks/TASK-*.md`, `AGENTS.md`, scientific/runtime code, tests, datasets, experiments, provider contracts, active TASK-0005 branch/PR, or repository default-branch settings.

## Acceptance criteria

- [ ] Eval-lab adoption targets authoritative `main` rather than the stale configured default branch;
- [ ] existing Eval-lab PROJECT/AGENTS/CURRENT/domain task/checkpoint semantics are preserved;
- [ ] target `.continuity/config.json` declares protocol/version/software profile/EVAL prefix and canonical PROJECT/CURRENT paths;
- [ ] target uses a separate `.continuity/tasks` machine namespace so legacy task history is not silently rewritten;
- [ ] `PROJECT.md` and `checkpoints/CURRENT.md` carry valid continuity metadata markers;
- [ ] CURRENT explicitly documents the legacy-task compatibility boundary and does not falsely claim a machine active task;
- [ ] target `schemas/v1` exactly match the protocol repository v1 schemas;
- [ ] target continuity overlay validates with the PCM v1 validator;
- [ ] no Eval-lab scientific/runtime code or active TASK-0005 implementation/PR is changed or merged by this task;
- [ ] target adoption PR and PCM PR are merged only after mergeability and all available CI/status gates pass;
- [ ] exact evidence, decisions, blockers, changed paths, and one next action are checkpointed before stop.

## Evidence expectations

Record the main-vs-default branch comparison, target branch/ref/commit, exact schema hashes, validator result, changed-file diff, target PR gate state, and confirmation that TASK-0005/PR #19 was untouched.

## Checkpoint log

No checkpoints yet.

## Handoff

Fresh session: read PROJECT -> CURRENT -> this task -> SPEC, then Eval-lab `AGENTS.md` read order from target `main`. Work only PCM-0004.
