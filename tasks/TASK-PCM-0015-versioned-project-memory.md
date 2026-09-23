# TASK-PCM-0015 — Plan versioned, verifiable project memory

<!-- continuity:task {"acceptance":["A durable implementation plan separates minimal core from optional adapters and defines explicit slice boundaries, non-goals, stop/split rules, and acceptance gates","The plan answers how PCM package and protocol versions relate, how Python and Node consumers would install/update, and what the current repository actually manages","The plan defines idempotency and a human-readable plus machine-readable state pattern with one authoritative source and generated/validated views","The plan defines document inventory/discovery, linked claims and evidence, freshness/supersession, and task ownership without assuming a graph database is required","The plan makes ordinary checkpoint cost proportional and specifies which operations happen on every checkpoint versus major handoff/release","The plan includes deterministic tests and a fresh-session blind end-to-end experiment proving an old document is found and not duplicated","The plan labels facts, user requirements, recommendations, inferences, and unresolved decisions; links evidence; and preserves Git as canonical","No implementation beyond this planning task is started"],"depends_on":[],"goal":"Produce a reviewable, evidence-based, sliced plan for testing and incrementally extending PCM with safe versioned adoption, idempotent documentation updates, durable document discovery, and fresh-session handoffs.","id":"PCM-0015","next_action":"GPT-6 Astra planning agent reads docs/research/PCM-0015-epistemic-context.md and the current PCM package/protocol/CLI state, then writes the bounded implementation plan in docs/plans/PCM-0015-implementation-plan.md.","owner":"GPT-6 Astra planning subagent (plan artifact); GPT-6 Luna parent session (scope and evidence review)","priority":"P1","protocol_version":"0.1.0-draft","schema":"project-continuity.task.v1","status":"active","why":"Fresh sessions reduce accumulated chat context but have repeatedly failed to discover earlier durable documents, causing duplicate work and incomplete context. PCM needs a small, verifiable, versioned memory and handoff workflow whose actual benefit and overhead are measured before it becomes policy."} -->

- Status: active; planning only
- Owner: GPT-6 Astra planning subagent for the plan artifact; GPT-6 Luna parent for task scope and evidence
- Priority: P1
- Depends on: none
- GitHub issue: [#28](https://github.com/Pukujan/project-continuity-modules/issues/28)
- Suggested branch: `task/PCM-0015-versioned-project-memory`

## Goal

Plan a small, testable evolution of PCM that helps every new session find existing work, resumes from Git-backed checkpoints, supports versioned updates across project runtimes, and avoids turning ordinary checkpoints into a heavyweight ceremony.

## Planning scope

The plan must inspect the current PCM implementation and distinguish existing behavior from new proposals. It must address:

- separate CLI/package and continuity-protocol versions;
- Python package distribution and possible Node/non-Python consumer support, including what PCM can and cannot enforce without runtime hooks;
- audit, upgrade, migration, compatibility, and local-change preservation;
- idempotent checkpoint, handoff, document inventory, and upgrade operations;
- a concise human view paired with machine-readable canonical state, with a defined generation/validation relationship;
- indexed document discovery, relationships, supersession, evidence-linked claims, stale/unknown state, and single-owner task claims;
- W3C PROV/PROV-O provenance and whether graph serialization should be native, generated, or deferred;
- task-specific context-pack generation and fresh-session takeover;
- checkpoint overhead, optional versus mandatory operations, and when to rotate sessions;
- slices, explicit non-goals, stop/split criteria, deterministic CI, and a blind fresh-session evaluation.

Do not implement the proposed feature set in this planning task. The result is one bounded plan artifact under `docs/plans/PCM-0015-implementation-plan.md` plus evidence in this task. Do not modify other repositories.

## Scope controls

- Keep the existing PCM package usable from Python 3.11+ unless evidence justifies a separately scoped compatibility change.
- Do not make a graph database, hosted service, vector store, or a JavaScript runtime a mandatory dependency without a measured need.
- Preserve Git as canonical project and task history.
- Separate file/schema validation from semantic truth claims; tests must be able to prove concrete behaviors.
- Separate core protocol requirements from Python CLI conveniences and optional adapters.
- Every proposed slice must fit one bounded task with named outputs and acceptance checks. If a slice crosses an unrelated runtime or infrastructure boundary, split it.
- Do not make every checkpoint run every expensive test. CI remains the full merge gate; the plan must state a proportional local checkpoint gate.
- Treat prior assistant designs in the epistemic context as proposals, not adopted requirements.

## Acceptance criteria

- [ ] Current package, protocol, templates, CLI, schemas, version policy, and CI are inspected with file/line evidence.
- [ ] The plan states a recommended adoption/distribution strategy for Python users and a separately justified approach for Node or other runtimes; unsupported conclusions remain open questions.
- [ ] The plan states concretely what PCM can enforce in-repository, what CI can enforce, and what requires a runtime/agent-host adapter.
- [ ] Human-readable and machine-readable records have one declared source of truth and a reproducible generation or consistency check.
- [ ] Idempotency is specified as repeat-run invariants for relevant commands and migrations.
- [ ] A document lookup acceptance scenario starts from a fresh session with no old conversation, finds a document created by an earlier session and related neighbors, and prevents creating a duplicate.
- [ ] Claim statuses and provenance distinguish user requirements, direct observations, external sources, model proposals, inferences, and stale/contradictory facts.
- [ ] Each slice has scope, files/components, required tests, exit criteria, migration story, and a clear defer/stop condition.
- [ ] Checkpoint flow remains concise for routine work and reserves expanded handoff/context-pack generation for meaningful checkpoints or task rotation.
- [ ] No implementation is started as part of PCM-0015.

## Evidence record

- Repository starting point: `388df1f057832d99b7c72d8022be5d1dae9a9946` (`origin/main`); working tree was clean.
- GitHub issue: #28.
- Verbatim dialogue and source classifications: `docs/research/PCM-0015-epistemic-context.md`.
- W3C PROV-O provenance graph: `docs/research/PCM-0015-provenance.ttl`.
- Official Codex subagent guidance: <https://learn.chatgpt.com/docs/agent-configuration/subagents>.

## Checkpoint log
