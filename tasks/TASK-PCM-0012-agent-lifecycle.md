# TASK-PCM-0012 — Close completed delegated agents and bound concurrency

<!-- continuity:task {"acceptance":["delegated-agent lifecycle is normative in the PCM specification and operating guidance","completed, interrupted, failed, cancelled, and timed-out workers all require parent capture followed by explicit close","generated minimal and software guidance carries the cleanup rule","deterministic policy tests prevent the close-after-result rule from disappearing","issue #24 and the final evidence are recorded without modifying unrelated repositories","full lint, type, compilation, test, package, and continuity validation pass"],"depends_on":["PCM-0010"],"goal":"Prevent finished delegated agents from remaining open and consuming concurrency slots after their work is complete.","id":"PCM-0012","next_action":"Run the full automated release gate, push, and allow protected CI to merge.","owner":"Codex current PCM policy implementation session; GitHub issue #24","priority":"P1","protocol_version":"0.1.0-draft","schema":"project-continuity.task.v1","status":"active","why":"Open completed agents remain visible and can count toward the concurrency limit. PCM needs an explicit capture, checkpoint, and close lifecycle for every delegated worker."} -->

- Status: active
- Owner: Codex current PCM policy implementation session; GitHub issue #24
- Priority: P1
- Depends on: PCM-0010
- GitHub issue: #24
- Suggested branch: `task/PCM-0012-agent-lifecycle`

## Goal

Prevent finished delegated agents from remaining open and consuming concurrency
slots after their work is complete.

## Allowed files

- `AGENTS.md`
- `README.md`
- `SPEC.md`
- `docs/AGENT_LIFECYCLE.md`
- `docs/HANDOFF_PROTOCOL.md`
- `templates/**`
- `tests/test_agent_lifecycle_policy.py`
- this task and `checkpoints/CURRENT.md`

Do not modify Hades v2, Eval Lab, harness-on-steroids,
inference-recommendation-engine, or any unrelated target repository.

## Acceptance criteria

- [x] delegated-agent lifecycle is normative in the PCM specification and operating guidance;
- [x] completed, interrupted, failed, cancelled, and timed-out workers all require parent capture followed by explicit close;
- [x] generated minimal and software guidance carries the cleanup rule;
- [x] deterministic policy tests prevent the close-after-result rule from disappearing;
- [x] issue #24 and the final evidence are recorded without modifying unrelated repositories;
- [ ] full lint, type, compilation, test, package, and continuity validation pass.

## Checkpoint log

### 2026-09-23 06:00 UTC — Codex PCM-0012 policy implementation

Completed:

- Added the canonical delegated-agent lifecycle policy.
- Added normative references in the specification, operating contract, handoff protocol, README, and generated profiles.
- Added deterministic policy tests for capture-then-close guidance and lifecycle coverage.
- Closed the completed blind-test worker from this PCM session after capturing its result.

Evidence:

- Official ChatGPT guidance states that completed subagents remain available until explicitly closed and documents the close operation.
- GitHub issue #24 records the durable policy and acceptance criteria.

Decisions:

- Agent threads are temporary execution infrastructure; the parent task/checkpoint is canonical.
- No unrelated target repository, including Hades v2, is modified.

Changed:

- `AGENTS.md`
- `README.md`
- `SPEC.md`
- `docs/AGENT_LIFECYCLE.md`
- `docs/HANDOFF_PROTOCOL.md`
- `templates/v1/minimal/HANDOFF.md`
- `templates/v1/software/AGENTS.md`
- `tests/test_agent_lifecycle_policy.py`
- this task

Blocked/uncertain:

- Hosted CI and automatic merge remain to be verified.

Next:

- Run the full automated release gate, push, and allow protected CI to merge.
