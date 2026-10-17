# Decision preflight — check the live issue before resuming a plan

**Status:** opt-in proposal, not merged, not yet a mandatory PCM/ACS contract.  
**Owner:** PCM continuity, with ACS using the result as one task-admission check.  
**Related:** [#241](https://github.com/Pukujan/project-continuity-modules/issues/241), [#189](https://github.com/Pukujan/project-continuity-modules/issues/189), [#217](https://github.com/Pukujan/project-continuity-modules/issues/217).

## Purpose

The PCM-0046/T2 [measured holdout](plans/PCM-0046-arms-results/REPORT.md) found that agents recognized the owning live issue was closed but still recommended the stale projection's next action. Existing [SPEC §8](../SPEC.md#8-authority) already says live issue state and authorized supersession outrank old projections. This check supplies **read-time optimistic concurrency control**. It does not make old decisions true or create new task authority.

## Explicit task precondition

Keep an expectation JSON beside a bounded task. Illustrative (the values below are **not real current revision evidence**):

~~~json
{
  "schema": "pcm.decision-precondition.v1",
  "repository": "Pukujan/project-continuity-modules",
  "issue_number": 144,
  "task_id": "PCM-0070",
  "expected_issue_state": "open",
  "expected_issue_updated_at": "2026-10-08T10:10:10Z",
  "decision_comment_id": 1234567890,
  "decision_id": "example-reviewed-decision",
  "decision_body_sha256": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}
~~~

Capture the expected issue revision from the actual GitHub issue only *after* reviewing the issue's current scope and relevant decisions. Do not copy a timestamp from stale CURRENT prose. If a specific accepted decision comment anchors the plan, record its actual GitHub comment ID, the exact pcm:decision marker ID, and SHA-256 of the full comment body. The three decision-comment fields are all-or-nothing. A plain issue-only expectation is supported but offers less evidence.

## Read-only command

~~~bash
python -m continuity.decision_preflight --expect task-precondition.json
~~~

The module makes uncached live GitHub API GETs, using GH_TOKEN or GITHUB_TOKEN when available. No token is necessary for public data within unauthenticated rate limits. No work is pushed or checkpointed.

| State | Exit | What it says | Behavior |
| --- | --- | --- | --- |
| CURRENT | 0 | Issue revision and optional decision comment match expected values | Other safety, role and semantic gates must still pass |
| STALE | 2 | Live issue state differs (for example, now closed) | Stop affected action; reconcile |
| REVIEW_REQUIRED | 2 | Issue updated or decision body/marker changed | Re-read and explicitly review; never auto-refresh without review |
| UNKNOWN | 3 | API/network/token error, invalid record, or source identity mismatch | No evidence of freshness; fail closed |

No production green is emitted from an offline fixture; tests exercise the pure comparison function. The result carries expected and observed issue revisions, with an explicit warning that it does not certify semantic validity or authorization.

## Limits

- GitHub issue update time is deliberately conservative: unrelated comments or label changes can trigger REVIEW_REQUIRED. The correct response is a scoped review, not blind replacement of the expected timestamp.
- A matching issue revision is not a universal dependency graph check. Parent or sibling issues and normative source revisions may also matter and must be checked via SPEC §8.
- Decision-body digest detects changes to the anchored comment; it does not prove that the author had authority or that the accepted decision was correct.
- A time-of-check/time-of-use race remains: rerun the check immediately before consequential action, not once per seven-hour session.
- This does not replace ACS's boss leases/claim queue, PCM's source of authority, OIO's identity checks, actual tests, or human acceptance.
- This module leaves existing checkpoint formats and historical digests untouched; the separately recorded [#217](https://github.com/Pukujan/project-continuity-modules/issues/217) epistemic fields remain an independent issue.

## Reconciliation workflow

1. Read the changed live issue and latest authenticated owner direction, as well as directly affected parent and dependency issues.
2. Determine whether the change affects the task's problem, acceptance, required source revision, or immediate action. Keep the check blocked until that review is recorded.
3. If it does, supersede the previous premise and re-plan dependent outputs. If it does not, record the inspected issue revision and retain the plan.
4. Update the task's explicit expectation from the newly reviewed state, not from an automatically generated summary. The original issue/checkpoint and evidence lineage remain intact.
5. Re-run immediately before consequential work. Other independent safe work may continue.

## Verification

Run: python -m unittest discover -s tests -p 'test_decision_preflight.py' -v.

CI verifies the tests, lint and package builds. The ACS adapter is an opt-in consumer until the certified PCM version includes this module; no train pins change in this slice.
