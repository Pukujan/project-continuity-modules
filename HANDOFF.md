# Current Handoff

This repository is ready for a fresh PCM development session without prior chat history.

## Active work

- Task: `PCM-0009 — Helper/Target Identity Boundary`
- Issue: #15
- PR: #16
- Candidate CLI/package version: `0.2.0`
- Protocol version remains: `0.1.0-draft`
- Release gate: automated CI + fresh-session blind acceptance in `docs/BLIND_TEST.md`

## Read exactly this first

1. `PROJECT.md`
2. `AGENTS.md`
3. `checkpoints/CURRENT.md`
4. `tasks/TASK-PCM-0009-helper-target-boundary.md`
5. `docs/TARGET_ADOPTION.md`
6. `docs/BLIND_TEST.md`
7. `docs/VERSIONING.md`

## Exact next action

Confirm PR #16 CI passes after the fail-closed validator fix. Then perform the blind acceptance test in a genuinely fresh session that has not seen issue #15, PR #16, or the incident discussion. Do not tag/release 0.2.0 before the blind test passes.

## Authority

PCM owns only its protocol/tooling development state. When PCM is used as a helper for another repository, that target repository owns its PROJECT/CURRENT/TASK/checkpoint state. A target is not integrated until `continuity validate --root <target>` succeeds.
