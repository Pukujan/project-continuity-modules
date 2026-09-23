# Current Handoff

This repository is ready for a fresh PCM development session without prior chat history.

## Active work

- Task: `PCM-0010 — Continuity bookkeeping must not become an execution gate`
- Issue: #17
- Suggested branch: `task/PCM-0010-continuity-bookkeeping`
- PCM-0009 predecessor candidate: PR #16; keep its helper/target identity scope separate
- Candidate CLI/package version remains: `0.2.0`
- Protocol version remains: `0.1.0-draft`
- Release gate: deterministic suite + fresh-session blind acceptance in `docs/BLIND_TEST_PCM-0010.md`

## Read exactly this first

1. `PROJECT.md`
2. `AGENTS.md`
3. `checkpoints/CURRENT.md`
4. `tasks/TASK-PCM-0010-continuity-bookkeeping.md`
5. `docs/HANDOFF_PROTOCOL.md`
6. `docs/BLIND_TEST_PCM-0010.md`
7. `docs/VERSIONING.md`

## Exact next action

Review the PCM-0010 diff, commit the branch, and leave it ready for PR review. The deterministic suite, self-validation, and fresh-session blind rerun are complete; PCM-0009 remains a separate predecessor candidate. Do not modify Eval Lab, hades-v2, harness-on-steroids, inference-recommendation-engine, or any unrelated target repository.

## Authority

PCM owns only its protocol/tooling development state. When PCM is used as a helper for another repository, that target repository owns its PROJECT/CURRENT/TASK/checkpoint state. A target is not integrated until `continuity validate --root <target>` succeeds. The authoritative identity is the repository/task lineage and Git history; alternate worktrees/hosts are execution infrastructure. Push meaningful commits when authorized; use and later reconcile a recovery receipt when canonical continuity state is temporarily unavailable.
