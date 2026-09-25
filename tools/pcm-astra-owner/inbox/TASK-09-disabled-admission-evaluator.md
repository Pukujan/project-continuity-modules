# TASK-09 - internal disabled admission evaluator

Status: the sole assigned staff slice; execution/dispatch is separate from this owner turn. No worker is launched here. Return RESULT-09-disabled-admission.md and stop. TASK-08 is consumed; do not reopen it.

Owner authority: [leaf decision](https://github.com/Pukujan/project-continuity-modules/issues/67#issuecomment-5824990832), [parent progression](https://github.com/Pukujan/project-continuity-modules/issues/53#issuecomment-5824991366), and DECISION-16-deployment-admission.md sections 1-4. Leaf #67 / PCM-0026; parent #53 / PCM-0024, parent of #53 none; prerequisite #66 / PCM-0025 CLOSED / COMPLETED. No known dependent child of #67; #53 aggregate acceptance is affected. #67/#53 remain OPEN. Primary writer remains the planning/research/verification owner on task/PCM-0026-post-push-plan; staff owns only this bounded implementation interval.

## Human outcome and promise

PCM must not turn an unproved deployment into permission to send a receipt. This slice makes the admission requirements reviewable as pure internal code: every production evaluation denies, while synthetic evidence can exercise the full decision contract in tests. A PASS verdict is never a transport capability and does not enforce any current publisher route. This is not completion of #67.

## Starting point and allowed files

Use the existing canonical checkout and task branch. At assignment: HEAD 9f1caf0c26615e9596ab400a295bed3efe08301c; fetched origin/main 8626efad3a96c1bad9797e2003100bc8862623be. The branch is behind main; do not update it by checkout, reset, cherry-pick, merge or rebase. The proposed module is additive and has no integration dependency on either CLI revision. If that proves false, stop and report it instead of editing the CLI.

Only new product files allowed:

- src/continuity/_receipt_admission.py
- tests/test_receipt_admission.py

Private output: RESULT-09-disabled-admission.md and narrowly named EVIDENCE-09-admission-* files in this inbox. No other TASK file. Do not overwrite an existing allowed product file; report a collision. Preserve all existing checkout edits, especially HANDOFF.md, checkpoints/CURRENT.md, the PCM-0026 research note and task. Do not edit docs/astra-restore-not-stop, PR 98, CLI/publisher code, old tests, dependency files, catalog or generated artifacts. No commit, push, issue/PR mutation, merge, new checkout/worktree, worker launch, failed-thread resume or hardware experiment.

Before execution, re-read live #67/#53/#66 and the owner-decision comment, run continuity issue verify PCM-0026, fetch/catalog lookup, and inspect only relevant source heads. Verify ownership and that this remains the latest unconsumed TASK. Do not dump prior TASK/RESULT/EVIDENCE/test files or repeat OWNER-11..14 verification. If source has advanced, record exact revisions and assess only whether the two-file boundary still holds; do not silently take a new implementation scope.

## Contract E1 - one pure production entry

Provide one internal production entry accepting an already collected in-memory deployment observation. It obtains qualification only from a private production provider with an empty approved set. It must not accept an approval record, provider override, approval boolean, environment/configuration flag or test-mode argument from its caller. No public approval/enrollment CLI. There is no production JSON/file reader in this slice.

Return an immutable AdmissionVerdict containing only a decision (DENY or PASS) and a bounded tuple of enumerated reason/gate codes. PASS has no failure reasons; DENY has at least one. No token, callback, sender, mutation handle, READY object or persistent approval flag is returned. No caller values, artifact paths, credentials or exception messages are included in reasons. Production always DENY, including for the exact synthetic observation that passes the private test evaluator.

The private pure evaluator may accept an in-memory qualification record for tests. The fixture provider and hypothetical qualification data live only in the test file; no selector, environment switch, registry hook or CLI can choose them in production. Python privacy is an API boundary, not a claim of protection against code executing arbitrarily in the same interpreter.

## Contract E2 - strict evidence and exact binding

Use a fixed versioned in-memory record schema. Freeze its complete key/field set in the tests before implementing the evaluator. Reject unknown schema versions, unknown fields at every schema layer, missing/empty required values, wrong types, unsupported enum values and malformed evidence references. Ordinary malformed input returns DENY with a sanitized schema/reason code; do not coerce truthy strings, booleans into integers, paths into identities, or version strings into approvals. No broad catch of process-control exceptions.

The qualification record must contain profile ID, policy revision, qualification/review identity, complete deployment tuple, installation/store binding, writer deployment revision, record review/invalidation state and exactly D1/D2/P/Q evidence. The observation must match the selected profile/policy, current qualification/review identity, complete tuple, installation/store and writer binding. Exact equality is required, with no wildcard/default/fuzzy version fallback. All required values remain mandatory even when both sides omit the same value.

The full tuple must explicitly cover: Python/runtime version and binary identity/hash; SQLite version, binary hash, source ID and compile options; selected VFS; adapter revision; Windows build; filesystem and mount topology; volume, device, controller, firmware and cache configuration. Installation ID, original store ID, policy and writer revision are additional exact bindings. Do not replace these dimensions with a single caller-supplied approved flag or an unverified version label. Artifact digests identify evidence bytes; they do not prove an evidence claim.

For the chosen PCM67-WIN32-DELETE-EXTRA-v1 fixture, use the candidate runtime described in DECISION-16 and explicitly verify effective DELETE, EXTRA=3, foreign_keys=1, read_uncommitted=0, no shared cache and no sync-disabling build option. These are supplied observations only; do not open a database to gather them. A successful settings check does not supply D1/D2 qualification.

Each gate's evidence identifies its claim, exact bound subject, issuer/reviewer, source artifact and digest, observation time, limitations, review state and invalidating changes. Current PASS is possible in the private fixture only when every required reference is present and all subjects match. Missing, UNKNOWN, failed, conflicting, stale, revoked, unsupported or unreviewed evidence denies. Define staleness using the current provider's review/revision state and binding, not an implicit wall clock read or a TTL that creates authority. For this empty-provider slice these are synthetic premises, not independently verified storage/custody attestations. Do not invent a trust service or signature/approval protocol.

Gates have distinct meanings and may not substitute for each other:

- D1: runtime, locking, commit/settings and error propagation.
- D2: storage/journal-deletion/fresh-directory/bootstrap durability, including crash/power-loss and lost acknowledgement.
- P: original-store custody with evidence independently retained outside its restore domain.
- Q: legacy-writer quiescence and complete supported-route coverage at the exact writer revision.

## Contract E3 - denial and invalidation

Absent qualification, unapproved tuple or any unmet gate denies. Copy/restore/reimage, missing/destroyed/corrupt/non-original store, uncertain custody, runtime/storage/VFS/adapter drift, a newly possible legacy writer, writer mismatch, changed policy/review binding, revocation or explicit invalidation also denies. Model these as evidence/invalidation states of the internal observation/record; do not add publisher-facing provenance/quiescence booleans.

Denial has no side effects. PASS also has no side effects. Never create/open/repair a store, enroll READY, consume or erase a target, write a checkpoint, call Git, import/call the publisher, access credentials, perform remote lookup/POST, or change any input. No state recovery, rollback repair, exception-based resend, attestation renewal, TTL/takeover or old-operation rebinding. Requalification can be represented only by a separate hypothetical fixture record; it cannot undo an invalidation on the observed store/operation.

## Fixed oracle - write tests first

Use deterministic table-driven unittest tests and independent expected outcomes from E1-E3; do not generate expectations by calling implementation validators. Do not require a full publisher harness or old pins. Cover these partitions:

1. A complete all-PASS hypothetical record/observation yields only a PASS verdict through the private evaluator. The identical observation through the production entry yields DENY. Missing production qualification always denies.
2. Vary each of D1, D2, P and Q independently through absent, UNKNOWN, failed, conflicting, stale, revoked/unreviewed and malformed-reference states while holding the other gates valid. Every row denies. All four valid is necessary; duplicate/unknown gate or missing required reference denies.
3. Change each tuple dimension individually; separately change installation, store, policy, review identity and writer revision. Each mismatch denies. Missing-on-both-sides, empty, wildcard and type-coercion cases deny. Wrong settings and sync-disabling options deny even with other evidence marked PASS.
4. Test the E3 copy/restore/reimage/destroyed/corrupt/legacy/invalidation cases independently. Matching hashes/IDs and otherwise PASS gates cannot rescue them. No deletion/reset/renewal of evidence inside evaluation may turn them into PASS.
5. Malformed top-level and nested records, unknown fields/schema/enums, missing mandatory values and ordinary incorrect types produce bounded DENY results without leaking sentinel sensitive input. Production takes no test/provider override.
6. For representative DENY cases and fixture PASS, verify exactly the verdict-only return shape, immutable result, unchanged input and no filesystem/store/process/transport/credential side effects. Use narrow forbidden-call sentinels around evaluation; a module import may load ordinary Python code, but evaluation has no I/O. Do not treat a mock that bypasses the actual evaluator as evidence.
7. Repeat identical evaluations and permute mapping insertion order to verify deterministic identical verdicts; adding valid evidence to only one of multiple missing gates must remain DENY. This is a relation test, not a new availability claim.

No real qualification is created by these tests. Do not label fixture PASS a deployable profile, enforcement of existing routes, storage durability proof, secret-proof sandboxing or completed receipt automation.

## Execution, checks and result

Write the focused oracle first. Capture a meaningful failing assertion against a minimal deny-only evaluator scaffold (fixture PASS should fail); distinguish import/syntax/setup errors from behavioral red evidence. Then implement only E1-E3. Run the focused unittest file, Ruff on the two files, MyPy on the new module using repository configuration, and compile validation for the two files. These are the checks for this local slice; full integration/package/hosted gates remain owner-controlled before any later delivery. Existing unrelated failures do not authorize repairs.

RESULT-09 must give: source HEAD/origin revision; TASK and source-decision hashes; exact commands and exit codes; red versus green outcomes and unique table-case counts; changed-file inventory and hashes; the concrete frozen schema/API; evidence-to-contract mapping; remaining limitations; confirmation that production denies and no route/CLI was wired; and one next action, owner review. Include any failed or inconclusive case. Do not say done/delivered for #67 or erase contradictory evidence.

Stop at the local two-file candidate and result. No staff checkpoint push or publication is authorized. The owner will independently inspect the new candidate and this result, using only focused verification justified by the new change.
