# TASK-PCM-0004 — Adopt continuity v1 in Eval-lab

<!-- continuity:task {"acceptance":["Eval-lab adoption targets authoritative main rather than the stale configured default branch","existing Eval-lab PROJECT/AGENTS/CURRENT/domain task/checkpoint semantics are preserved","target .continuity/config.json declares protocol/version/software profile/EVAL prefix and canonical PROJECT/CURRENT paths","target uses a separate .continuity/tasks machine namespace so legacy task history is not silently rewritten","PROJECT.md and checkpoints/CURRENT.md carry valid continuity metadata markers","CURRENT explicitly documents the legacy-task compatibility boundary and does not falsely claim a machine active task","target schemas/v1 exactly match the protocol repository v1 schemas","target continuity overlay validates with the PCM v1 validator","no Eval-lab scientific/runtime code or active TASK-0005 implementation/PR is changed or merged by this task","target adoption PR and PCM PR are merged only after mergeability and all available CI/status gates pass","exact evidence, decisions, blockers, changed paths, and one next action are checkpointed before stop"],"depends_on":["PCM-0003"],"goal":"Adopt Project Continuity Protocol v1 in Pukujan/Eval-lab without rewriting its mature legacy task/checkpoint history or disturbing active scientific work.","id":"PCM-0004","next_action":"Restore or observe successful Eval-lab CI for PR #20 at head 3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981; only then merge PR #20 and finish PCM-0004.","owner":"ChatGPT/Sol current implementation session; GitHub assignee Pukujan","priority":"P0","protocol_version":"0.1.0-draft","schema":"project-continuity.task.v1","status":"active","why":"Eval-lab already has strong human continuity state, so the adoption risk is preserving that mature history while adding deterministic v1 machine validation without a lossy rewrite."} -->

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

- [x] Eval-lab adoption targets authoritative `main` rather than the stale configured default branch;
- [x] existing Eval-lab PROJECT/AGENTS/CURRENT/domain task/checkpoint semantics are preserved;
- [x] target `.continuity/config.json` declares protocol/version/software profile/EVAL prefix and canonical PROJECT/CURRENT paths;
- [x] target uses a separate `.continuity/tasks` machine namespace so legacy task history is not silently rewritten;
- [x] `PROJECT.md` and `checkpoints/CURRENT.md` carry valid continuity metadata markers;
- [x] CURRENT explicitly documents the legacy-task compatibility boundary and does not falsely claim a machine active task;
- [x] target `schemas/v1` exactly match the protocol repository v1 schemas;
- [x] target continuity overlay validates with the PCM v1 validator;
- [x] no Eval-lab scientific/runtime code or active TASK-0005 implementation/PR is changed or merged by this task;
- [ ] target adoption PR and PCM PR are merged only after mergeability and all available CI/status gates pass;
- [x] exact evidence, decisions, blockers, changed paths, and one next action are checkpointed before stop.

## Evidence expectations

Record the main-vs-default branch comparison, target branch/ref/commit, exact schema hashes, validator result, changed-file diff, target PR gate state, and confirmation that TASK-0005/PR #19 was untouched.

## Checkpoint log

No checkpoints yet.

### 2026-09-20 18:44:00 UTC — ChatGPT/Sol Eval-lab adoption gate

<!-- continuity:checkpoint {"agent":"ChatGPT/Sol Eval-lab adoption gate","blocked":["Eval-lab PR #20 CI is red at exact head 3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981. Pull-request CI run 35529923987 failed on attempt 1 and again on the single retry attempt 2; the failed/cancelled jobs expose zero workflow steps, matching the repository's documented runner-assignment infrastructure failure. User-authorized auto-merge requires CI/CD gates to meet, so PR #20 is intentionally not merged."],"changed":["Pukujan/Eval-lab:.continuity/config.json","Pukujan/Eval-lab:.continuity/tasks/.gitkeep","Pukujan/Eval-lab:schemas/v1/**","Pukujan/Eval-lab:PROJECT.md","Pukujan/Eval-lab:checkpoints/CURRENT.md","tasks/TASK-PCM-0004-adopt-eval-lab.md","checkpoints/CURRENT.md","HANDOFF.md"],"completed":["Created the Eval-lab compatibility adoption branch from authoritative main and added only the bounded continuity overlay.","Validated the target continuity overlay with PCM v1 and verified exact schema identity.","Opened Eval-lab PR #20 and evaluated both push and pull-request CI, including one failed-job retry."],"decisions":["Target Eval-lab main because configured default claude/reliability-walking-skeleton-31b6a2 is 27 commits behind main with no unique commits.","Preserve all nine legacy tasks/checkpoint histories untouched by isolating v1 machine tasks under .continuity/tasks.","Do not auto-merge PR #20 while its configured CI workflow is red, even though the failure is consistent with known runner infrastructure rather than repository tests."],"evidence":["compare main...claude/reliability-walking-skeleton-31b6a2 -> default branch is behind main by 27 commits, ahead by 0.","Target branch task/PCM-0004-continuity-adoption head -> 3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981; diff vs main -> 10 bounded files, additions only.","PYTHONPATH=/mnt/data/pcm-worktree/src python -S -m continuity validate --root /tmp/eval-adopt-validate -> VALID.","Target schema blob SHAs exactly match protocol repository: config 8cff4abc2ddbc26a21ce33a7867a924fd2e13b73; project b0fc0d6dfc34975f1167eb32a69a7eb711473b23; current 3eaa0e4c79595ec9bc5f3cf4058cab0f91d235e8; task a6f61c1f8b110687a103775c56c45dc6359e63f1; checkpoint 5162bbaaf01331c0a28b0c9f964cb3c8ed7b63c8; context-pack 97626e34144e20e8feb35ffc3b5351afa154d24f.","Eval-lab PR #20 -> mergeable=true at exact head 3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981.","Push CI run 35529883224 -> completed/failure; jobs exposed no steps.","PR CI run 35529923987 attempt 1 -> completed/failure; Python 3.11 and 3.12 jobs exposed steps=[].","rerun_failed_workflow_run_jobs(35529923987) -> success=true; attempt 2 -> completed/failure; job 106128727439 failure and 106128727512 cancelled, both steps=[].","Eval-lab TASK-0005 files/PR #19 and all scientific/runtime files are untouched by the adoption diff."],"next_action":"Restore or observe successful Eval-lab CI for PR #20 at head 3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981; only then merge PR #20 and finish PCM-0004.","protocol_version":"0.1.0-draft","schema":"project-continuity.checkpoint.v1","task_id":"PCM-0004","timestamp":"2026-09-20T18:44:00Z"} -->

Completed:
- Created the Eval-lab compatibility adoption branch from authoritative `main` and added only the bounded continuity overlay.
- Validated the target continuity overlay with PCM v1 and verified exact schema identity.
- Opened Eval-lab PR #20 and evaluated both push and pull-request CI, including one failed-job retry.

Evidence:
- `compare main...claude/reliability-walking-skeleton-31b6a2` -> configured default is 27 commits behind `main`, ahead by 0.
- target branch `task/PCM-0004-continuity-adoption` head -> `3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981`; diff vs `main` -> 10 bounded files, additions only.
- `PYTHONPATH=/mnt/data/pcm-worktree/src python -S -m continuity validate --root /tmp/eval-adopt-validate` -> `VALID`.
- all six target schema blob SHAs exactly match the protocol repository.
- Eval-lab PR #20 -> `mergeable=true` at exact head `3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981`.
- push CI run `35529883224` -> completed/failure; jobs exposed no steps.
- PR CI run `35529923987` attempt 1 -> completed/failure; both matrix jobs exposed `steps=[]`.
- `rerun_failed_workflow_run_jobs(35529923987)` -> `success=true`; attempt 2 -> completed/failure; job `106128727439` failed and `106128727512` was cancelled, both with `steps=[]`.
- Eval-lab TASK-0005/PR #19 and scientific/runtime files are untouched.

Decisions:
- Target Eval-lab `main`; do not adopt onto the stale configured default branch.
- Preserve all nine legacy task/checkpoint histories untouched by isolating v1 machine tasks under `.continuity/tasks`.
- Do not auto-merge PR #20 while its configured CI workflow is red, even though the evidence is consistent with the known runner-assignment infrastructure failure.

Changed:
- `Pukujan/Eval-lab:.continuity/config.json`
- `Pukujan/Eval-lab:.continuity/tasks/.gitkeep`
- `Pukujan/Eval-lab:schemas/v1/**`
- `Pukujan/Eval-lab:PROJECT.md`
- `Pukujan/Eval-lab:checkpoints/CURRENT.md`
- `tasks/TASK-PCM-0004-adopt-eval-lab.md`
- `checkpoints/CURRENT.md`
- `HANDOFF.md`

Blocked/uncertain:
- Eval-lab PR #20 CI is red at the exact adoption head. The single retry reproduced the no-step runner failure. Under the user-authorized auto-merge rule, the pipeline does not meet the merge gate.

Next:
- Restore or observe successful Eval-lab CI for PR #20 at head `3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981`; only then merge PR #20 and finish PCM-0004.

## Handoff

Fresh session: read PROJECT -> CURRENT -> this task -> SPEC, then Eval-lab `AGENTS.md` read order from target `main`. Work only PCM-0004.
