# Handoff Protocol

## Goal

A fresh session should resume from repository state without needing the previous conversation.

## Canonical hierarchy

```text
PROJECT
  ↓
CURRENT
  ↓
TASK
  ↓
CHECKPOINTS
```

Issues/Beads/PRs mirror coordination. Context packs are generated views.

## Start-session procedure

1. read `PROJECT.md`;
2. read `checkpoints/CURRENT.md`;
3. open the active task;
4. read only the minimum relevant spec/design file;
5. confirm branch/scope before edits.

## Checkpoint format

Append, do not rewrite history:

```
### YYYY-MM-DD HH:MM UTC — <agent/session>

Completed:
- ...

Evidence:
- command/artifact -> observed result

Decisions:
- ...

Changed:
- ...

Blocked/uncertain:
- none | ...

Next:
- one atomic action
```

## Stop-session requirements

Before stopping:
- commit meaningful work or document dirty state;
- push the task branch when a remote is available and pushing is authorized;
- record tests/commands/results;
- record uncertainty rather than guessing;
- set one exact next action;
- update CURRENT only when repository-level state changed;
- link task ID to issue/PR/Beads item when used.

## Degraded continuity

Execution safety and existing authorization outrank checkpoint bookkeeping. A temporary failure to read or write `PROJECT`, `CURRENT`, `TASK`, or `HANDOFF` state is a degraded continuity condition, not an independent reason to stop safe work.

Use an already-authorized alternate checkout or host when needed. Record the same task ID, repository identity, branch/ref, source commit, evidence, and next action in a recovery receipt with `continuity checkpoint --recovery-root <alternate-root>`. Do not repair storage merely to force a write, ask again for permission that already exists, treat a physical path as project identity, or create competing continuity state. Reconcile the receipt after the canonical checkout is writable with `continuity recovery reconcile`.

One authoritative task/repository lineage may have multiple execution worktrees. The worktree is a view; the pushed task branch is the preferred durable shared handoff when Git remote use is available and authorized.

## Context packs

A context pack may concatenate/transform canonical state for convenience, but must identify:
- repository;
- ref/branch;
- commit;
- protocol version;
- task ID;
- generation time;
- source file list.

Never update a context pack instead of canonical state.
