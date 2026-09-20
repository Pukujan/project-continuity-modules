# Current Handoff

This repository is ready for a fresh session without prior chat history.

## Active work

- Task: `PCM-0004 — Adopt continuity v1 in Eval-lab`
- GitHub issue: #7
- Suggested task branch: `task/PCM-0004-adopt-eval-lab`
- Canonical task file: `tasks/TASK-PCM-0004-adopt-eval-lab.md`
- Target repository: `Pukujan/Eval-lab`
- Target integration branch: `main`

## Read exactly this first

1. `PROJECT.md`
2. `AGENTS.md`
3. `checkpoints/CURRENT.md`
4. `tasks/TASK-PCM-0004-adopt-eval-lab.md`
5. `SPEC.md`
6. Eval-lab `AGENTS.md` read order from target `main`

Then implement only the bounded adoption task. Do not reconstruct project state from prior conversations.

## Blocker

Eval-lab PR #20 is mergeable and the continuity overlay validates locally, but configured CI remains red after one retry; both retry jobs exposed zero steps. Do not merge until CI succeeds.

## Exact next action

Restore or observe successful Eval-lab CI for PR #20 at head `3e483cc6ba8d4a1eb1734aa49b89cc1d3bef6981`; only then merge PR #20 and finish PCM-0004.

## Authority

PCM task state is canonical in this repository. Eval-lab's existing repository contracts remain authoritative for its scientific/domain semantics and legacy task history.
