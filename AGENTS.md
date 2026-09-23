# Agent Operating Contract

This repository dogfoods the continuity protocol it is building.

## Operating mode gate

Before reading task state, determine whether this repository is the **thing being developed** or only a **helper for another repository**.

- If the user points at PCM to help work on another repository, PCM is helper/tooling only. The other repository is the target and owns PROJECT, CURRENT, TASK, checkpoints, and project-specific operational state.
- Identify the target repository/root explicitly and run `continuity preflight --root <target>` before treating continuity as active.
- Do not create a new continuity repository for the target, do not write the target project's state into this repository, and do not use PCM's own CURRENT/TASK as the target's task state.
- A target is not PCM-integrated merely because it contains similarly named files. Integration is established only when the target passes `continuity validate --root <target>`.
- If a mature target already owns PROJECT/AGENTS/HANDOFF documentation, preserve those semantics and follow `docs/TARGET_ADOPTION.md` rather than replacing them.

Only when the task is to change Project Continuity Modules itself should the PCM read order below be used.

## Read order

Before doing work:

1. `PROJECT.md`
2. `checkpoints/CURRENT.md`
3. the active `tasks/TASK-*.md`
4. the minimum relevant document:
   - normative design: `SPEC.md`
   - handoffs: `docs/HANDOFF_PROTOCOL.md`
   - versioning/migrations: `docs/VERSIONING.md`

Do not scan historical chats for context by default.

## One task, one primary branch/session

Task IDs use `PCM-XXXX`.

Recommended branch format:

```text
task/PCM-0001-bootstrap-v1
```

One primary agent/session owns the writable task state at a time.

## Checkpoint rule

Before stopping after meaningful work, append to the active task:

- completed work;
- evidence/commands/results;
- files changed;
- decisions;
- blockers/uncertainty;
- one exact next action.

Update `checkpoints/CURRENT.md` only when program-wide state or priority changes.

## Evidence rule

Distinguish:
- observed command/test result;
- repository state;
- external artifact;
- agent/model claim;
- inference/assumption.

Never promote an unsupported previous-session statement into project fact.

## Scope rule

If the task expands materially, update/split the task before doing the expanded work.

## Self-hosting rule

Changes to the continuity protocol must be managed using the continuity protocol itself whenever practical. Protocol defects discovered while dogfooding should become explicit tasks/issues rather than silent conventions.
