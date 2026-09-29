# TASK-PCM-0069 — Epistemic Checkpoint Fields

<!-- continuity:task {"acceptance": ["schemas/v1/checkpoint.schema.json gains optional evidence_class (enum observed|inferred), supersedes (string) and as_of (string) while additionalProperties stays false: a marker carrying all three validates, and an unknown enum value such as assumed is rejected (red-first).", "continuity checkpoint can write the three fields through optional flags, and omits them from the emitted marker entirely when not supplied, so a checkpoint recorded without them is byte-identical to what the CLI writes today.", "Historical digests keep verifying: checkpoint_payload_sha256 builds its hash input by presence-gated inclusion ({key: meta[key] for key in keys if key in meta}), never meta.get() with a default and never by adding keys to the tuple unconditionally; a regression test replays a pre-change recorded checkpoint through validate_checkpoint_structure with no error, and a second test proves flipping evidence_class on a recorded entry fails the digest check.", "Backward compatibility holds with no migration and no protocol_version change: existing repositories and recorded checkpoints validate unchanged.", "Full gates green on the exact candidate with zero new failing test names against the six-name macOS baseline."], "depends_on": ["PCM-0050"], "goal": "Implement the lightweight epistemic fields the owner selected on #144 on 2026-09-26 (comment 5842123741) but that no issue ever carried: checkpoint markers gain machine-parseable evidence_class, supersedes and as_of, with backward-compatible digests (Refs #217).", "id": "PCM-0069", "issue_url": "https://github.com/Pukujan/project-continuity-modules/issues/217", "next_action": "Create the managed worktree from merged main and hand the slice to one worker, last of today's three because it edits the same src/continuity/cli.py region PCM-0067 just changed; the schema extension, the CLI flags and the presence-gated digest rule must ship in one commit or the worker's own checkpoint push fails validation.", "owner": "omp worker (delegated)", "priority": "P2", "protocol_version": "0.1.0-draft", "schema": "project-continuity.task.v1", "status": "active", "why": "A recorded owner decision has been unimplemented for three days because it was assigned to a task ID that had already shipped unrelated work, so PCM still cannot express in a machine-checkable way whether a claim was observed or inferred — the distinction its own evidence rule and issue-log-format 1.2.0 keep asking writers to make."} -->

- Status: active
- Owner: omp worker (delegated)
- Priority: P2
- Depends on: PCM-0050 (decision record, #144)

## Goal

Implement the lightweight epistemic fields the owner selected on #144 on 2026-09-26 (comment 5842123741) but that no issue ever carried: checkpoint markers gain machine-parseable `evidence_class`, `supersedes` and `as_of`, with backward-compatible digests (Refs #217).

## Why

Comment 5842123741 says "Implementation: PCM-0058 on its own branch after #176 merges (marker/schema + CLI writing fields)". PCM-0058 turned out to be the issue-log-format 1.2.0 readability rules, merged at `d46e0b7`, which never touched checkpoint markers. Observed at `main` `a3931c1`: `evidence_class`, `supersedes` and `as_of` appear in zero files under `src/`, `schemas/` or `tests/`. The decision's execution was therefore never filed, and PCM cannot record claim provenance on the machine-parseable side of a checkpoint.

## Allowed files

`schemas/v1/checkpoint.schema.json`, `src/continuity/cli.py` (`checkpoint_metadata`, `checkpoint_payload_sha256`, the `checkpoint` subparser, and `validate_checkpoint_structure` if it needs the same presence gate), the test file that covers checkpoint digests, and this task file. Out of scope: any claim-ledger or bitemporal store, the `pcm:claim` fenced block, O4 adopter filing channel (#143), and issue aging or `parked` lists (#144's remaining questions).

## Human outcome

A fresh session can read a checkpoint and tell, from the record rather than from prose tone, whether an entry reports something the writer observed or something it inferred, what earlier request it supersedes, and what date the claim covers — and the digest still proves nobody edited those fields after the fact.

## Scope and boundaries

- In scope: three optional marker fields, the CLI flags that write them, the schema extension, and the digest rule that keeps old records verifying.
- Out of scope: requiring evidence links at validation time, adopter ticket placement, and the parked/aging policy — all still open questions on #144 with no recorded owner answer.
- Dependencies/uncertainty: depends on PCM-0050's recorded selection; attribution is kept honest — 5842123741 is an authorized owner/Astra-session decision, not a human-owner statement. Publication order is last of today's three slices because PCM-0067 (merged) and PCM-0068 (in flight) edit the same `src/continuity/cli.py`.

## Acceptance criteria

- [ ] `schemas/v1/checkpoint.schema.json` gains optional `evidence_class` (enum `observed`|`inferred`), `supersedes` (string) and `as_of` (string) while `additionalProperties: false` stays; an unknown enum value is rejected.
- [ ] `continuity checkpoint` writes them through optional flags and omits them entirely when not supplied, so a checkpoint recorded without them is byte-identical to today's output.
- [ ] Historical digests keep verifying via presence-gated inclusion in `checkpoint_payload_sha256`; regression test replays a pre-change recorded checkpoint, and a second test proves flipping `evidence_class` after recording fails the digest check.
- [ ] No migration, no `protocol_version` change; existing repositories validate unchanged.
- [ ] Full gates green on the exact candidate, zero new failing test names against the six-name macOS baseline.

## Evidence and sources

Observed 2026-09-29 at `main` `a3931c1`: zero `evidence_class` matches in `src`/`schemas`/`tests`; `schemas/v1/checkpoint.schema.json` sets `additionalProperties: false` with a fixed property set; `checkpoint_payload_sha256` (src/continuity/cli.py:1821-1837) hashes `{key: meta[key] for key in (<nine-key tuple>)}` — direct indexing over a literal tuple — and `validate_checkpoint_structure` recomputes that digest for every recorded entry. Both failure modes those lines imply are recorded in #217 acceptance 3. Decision text: #144 comment 5842123741; supersession recorded at #144 comment 5897252283.

## Related records

- Required leaf owning issue, parent ancestry and dependencies (or explicitly none): leaf #217 (PCM-0069); parent: #144 (PCM-0050 decision record); dependencies: #144's recorded selection only.
- Primary writer / branch / source issue revision / as-of status: omp delegated worker, sole writer on `task/PCM-0069-epistemic-checkpoint-fields`; source: live #217 body as filed 2026-09-29; identity recorded on #217 at comment 5897251980.
- Related PR/CI evidence and push receipt (request ID / SHA): none yet. Supersedes the PCM-0058 task-ID reference in #144 comment 5842123741; PCM-0058 stays completed and is not reopened.

## Checkpoint log

No checkpoints yet.

## Handoff

Read PROJECT → CURRENT → this task → #217 → #144 comment 5842123741. Checkpoint before stopping.
