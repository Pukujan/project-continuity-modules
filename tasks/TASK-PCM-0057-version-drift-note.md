# TASK-PCM-0057 — Version Drift Note

<!-- continuity:task {"acceptance":["version_drift_note returns a NOTE naming both versions on mismatch, None on match / non-Python checkout / malformed version file; publish_checkpoint prints it on every publish (observability only, never refuses).","Red-first tests/test_version_note.py (4 cases) fails before and passes after; checkpoint hygiene/retry/stale-base suites + full discover stay at the known baseline (259 tests, six known macOS-environmental names); ruff 0.6.9 clean on changed files.","Package version raised 0.5.0 -> 0.6.0 (docs/VERSIONING.md MINOR rule: backward-compatible safety capability; PCM-0055 changed wire behavior under the old label); docs/ARCHITECTURE.md current-version line and README dated note updated; version-pin test updated; merge receipt on #162 closes acceptance 2 end-to-end."],"depends_on":[],"goal":"Deliver owner decision B on #162: publish_checkpoint prints a version-drift NOTE comparing installed CLI vs checkout version (observability only, no refusal), and bump the package to 0.6.0 so the two 0.5.0 wire behaviors are distinguishable.","id":"PCM-0057","issue_url":"https://github.com/Pukujan/project-continuity-modules/issues/177","next_action":"Commit product, checkpoint with --receipt-issue 162, open PR, arm auto-merge after final push, post merge receipt on #162.","owner":"owner/Astra planning","priority":"P2","protocol_version":"0.1.0-draft","schema":"project-continuity.task.v1","status":"active","why":"#162 incident: a stale 0.4.0 install composed the sanitizer-bypassing checkpoint; owner chose option B (5842002582). 0.5.0 now denotes two receipt-posting behaviors (PCM-0055 changed wire format), so continuity --version must distinguish them."} -->

- Status: active
- Owner: owner/Astra planning
- Priority: P2
- Depends on: none

## Goal

Deliver owner decision B on #162: publish_checkpoint prints a version-drift NOTE comparing installed CLI vs checkout version (observability only, no refusal), and bump the package to 0.6.0 so the two 0.5.0 wire behaviors are distinguishable.

## Why

#162 incident: a stale 0.4.0 install composed the sanitizer-bypassing checkpoint; owner chose option B (5842002582). 0.5.0 now denotes two receipt-posting behaviors (PCM-0055 changed wire format), so continuity --version must distinguish them.

## Allowed files

- `src/continuity/cli.py` (`version_drift_note` + one print in `publish_checkpoint`), `src/continuity/__init__.py`, `tests/test_version_note.py` (new), `tests/test_issue_log_format.py` (pin), `docs/VERSIONING.md`, `docs/ARCHITECTURE.md`, `README.md` (dated note), this task file, `checkpoints/CURRENT.md`, `.continuity/documents.json`, `docs/CONTINUITY_INDEX.md` (generated).

## Human outcome

A stale installed CLI can no longer silently compose a checkpoint the way `d854175` did (#162): the publish path itself prints which build is running versus what the checkout declares, so drift is visible at the moment it matters, and `continuity --version` distinguishes the pre-PCM-0055 0.5.0 from 0.6.0.

## Scope and boundaries

- In scope: pure version-drift NOTE function + one call site in `publish_checkpoint`; 0.6.0 version bump with VERSIONING entry and doc claims; red-first tests.
- Out of scope: any refusal gate (owner chose B over A on #162); `--allow-version-drift` flag; recovery-path changes; #169 receipt-audit scope (PCM-0054's next increment).
- Dependencies/uncertainty: depends on #162 decision 5842002582 (recorded); NOTE is cosmetic for users who ignore stdout — accepted tradeoff of option B.

## Acceptance criteria

- [x] `version_drift_note`: NOTE naming both versions on mismatch; None on match, non-Python checkout, or malformed version file; printed by `publish_checkpoint` on every publish (never refuses).
- [x] Red-first `tests/test_version_note.py` 4 cases: 1 error pre-fix (import fails) -> all OK post-fix; hygiene/retry/stale-base/json-encoding suites 53 OK; full discover 263 tests (259 + 4 new) = six known broken names (test_worktrees 3F+1E, test_cli 2F), zero regressions; ruff@0.6.9: pre-existing ISC003 only.
- [x] Version 0.5.0 -> 0.6.0: `docs/VERSIONING.md` entry (MINOR: backward-compatible safety capability; PCM-0055 changed receipt wire behavior under the old label), ARCHITECTURE current-line, README dated note (pinned evidence table left intact — rewriting cells against a stale pin would be false evidence), pin test updated.
- [ ] PR merged under six contexts + auto-merge; merge receipt on #162 delivers acceptance 2 end-to-end.

## Evidence and sources

Link repository state at a revision and cite external factual claims directly. Record commands and results for claims that need verification.

## Reproduction details (only when needed)

Base `ff84e91` (#176). RED: `PYTHONPATH=src python3.12 -m unittest tests.test_version_note` -> ImportError (function absent). GREEN: 4 OK; combined 53 OK; discover 263 = six known names. Non-Python adopter checkouts degrade to silence by design (no version file to compare).

## Related records

- Leaf #177 (PCM-0057 implementation; needed because `require_issue_identity` refuses receipts on issues that do not name the task id); parent: #162 (decision 5842002582); depends: #162 decision 5842002582.
- Primary writer: owner/Astra (omp session); branch task/PCM-0057-version-note from `origin/main` `ff84e91`; as-of 2026-09-26T01:55Z.
- Push receipt: continuity checkpoint request pcm-0057-drift-20260926 (--receipt-issue 162 through the working tool path).

## Checkpoint log

No checkpoints yet.

## Handoff

Read PROJECT → CURRENT → this task → minimum relevant spec. Checkpoint before stopping.
