# TASK-PCM-0052 — Stale CLI sanitizer-bypass incident

<!-- continuity:task {"acceptance": ["Incident recorded with provenance (SHAs, comment ids, tool versions) on #162 and in this task; #123 addendum posted; collateral audit names every issue touched by the #161 merge", "Version-drift gate decision recorded on #162: implement refuse-with-opt-out in continuity checkpoint, add an observability field, or an explicit owner decision to keep it a device convention; no CLI/schema change before that decision"], "depends_on": [], "goal": "Record and correct the PCM-0052 incident where a stale installed continuity CLI (0.4.0, pre-sanitizer) composed PR #161's checkpoint commit with a raw close keyword and the merge auto-closed active issue #139.", "id": "PCM-0052", "issue_url": "https://github.com/Pukujan/project-continuity-modules/issues/162", "next_action": "Owner decides acceptance 2 on #162 (gate mechanism vs convention); until then no cli.py edits.", "owner": "owner/Astra planning", "priority": "P2", "protocol_version": "0.1.0-draft", "schema": "project-continuity.task.v1", "status": "active", "title": "Stale CLI sanitizer-bypass incident", "why": "A just-shipped safety property silently did not apply because PATH resolved to an older binary; the same drift can close or reopen issues arbitrarily on any dogfood session."} -->

- Status: active (incident recorded; gate decision pending)
- Owner: owner/Astra planning
- Priority: P2
- Depends on: none; related #123 (same hazard class, different root cause), #139 (collateral, reopened), #160/#161 (merge that fired it)

## Checkpoint log

### 2026-09-25 22:30 UTC — owner/Astra


Completed:
- Incident recorded with provenance; #139 reopened with correction comment; collateral audit of issue closures caused by the #161 merge; #162 filed as leaf; #123 addendum posted; stale CLI reinstalled from checkout and sanitizer verified live in the tool env.

Evidence:
- Commit d854175 subject carries unsanitized "close #139."; PR #161 squash 60f2426 auto-closed #139 at 22:21:16Z; reopened 22:24:42Z; correction 5840516734.
- uv tool list: project-continuity v0.4.0 vs repo __version__ 0.5.0; 0.4.0 cli.py lacks sanitize_closing_keywords. After reinstall from checkout: 0.5.0, sanitizer verified ("close #139." -> "Refs #139.", 1 replacement).
- Collateral audit: only #122/#123 (intended) and #139 (collateral) closed since 22:00Z.

Decisions:
- This increment is the incident record plus correction only. The version-drift gate is deferred to an explicit owner decision (no established general mechanism; adopters lack a repo-visible CLI version; inventing one touches config/schema/CLI).

Changed:
- tasks/TASK-PCM-0052-stale-cli-incident.md (new), checkpoints/CURRENT.md, .continuity/documents.json, docs/CONTINUITY_INDEX.md (auto)

Blocked/uncertain:
- Acceptance 2 needs the owner's gate-mechanism decision on #162; no cli.py or schema edits authorized before it.

Next:
- Owner decides the gate mechanism on #162; a follow-up increment implements refuse-with-opt-out or records the convention.

### 2026-09-25 22:35:48 UTC — owner/Astra

<!-- continuity:checkpoint {"agent":"owner/Astra","blocked":["Owner decision needed on #162 (version-drift gate vs device convention) before any CLI change; PCM-0046 arms still provider-rate-gated (~04:00Z 2026-09-26)."],"changed":["tasks/TASK-PCM-0052-stale-cli-incident.md (new), checkpoints/CURRENT.md, .continuity/documents.json, docs/CONTINUITY_INDEX.md"],"completed":["Acceptance 1 on #162: incident recorded with provenance (d854175 raw close keyword; squash 60f2426 auto-closed #139 22:21:16Z; reopened 22:24:42Z; correction 5840516734; addendum 5840566391 on #123); collateral audit clean (only #122/#123 intended closeouts plus #139 touched since 22:00Z); stale uv-tool 0.4.0 CLI reinstalled from checkout at 0.5.0 with sanitize_closing_keywords verified live in the tool env; CURRENT projection corrected to remove the hazard wording (close-keyword text replaced by explicit-comment procedure) and register PCM-0052."],"decisions":["Gate mechanism (acceptance 2) deferred to owner on #162; no cli.py/schema edits in this increment. Task-file checkpoint markers are authored only by the CLI, never hand-written."],"evidence":["sanitize_closing_keywords('... close #139.') returns '... Refs #139.' (1 replacement) under ~/.local/share/uv/tools/project-continuity/bin/python; this checkpoint's own commit message passed the 0.5.0 sanitizer path; docs render --check SYNCHRONIZED; continuity validate shows only the pre-existing device-local /private/tmp/pcm-pinned error."],"next_action":"Open PR for task/PCM-0052-stale-cli-incident, enable auto-merge, verify six contexts, then post merge receipt on #162 with the exact squash SHA.","protocol_version":"0.1.0-draft","schema":"project-continuity.checkpoint.v1","task_id":"PCM-0052","timestamp":"2026-09-25T22:35:48Z"} -->
<!-- continuity:checkpoint-operation {"payload_sha256":"87e7743d34b898d063fd1ca1188d5b37ee9fb6200f82f9c78e6946a498e5bf20","request_id":"pcm-0052-incident-20260925","schema":"project-continuity.checkpoint-operation.v1","task_id":"PCM-0052"} -->

Completed:
- Acceptance 1 on #162: incident recorded with provenance (d854175 raw close keyword; squash 60f2426 auto-closed #139 22:21:16Z; reopened 22:24:42Z; correction 5840516734; addendum 5840566391 on #123); collateral audit clean (only #122/#123 intended closeouts plus #139 touched since 22:00Z); stale uv-tool 0.4.0 CLI reinstalled from checkout at 0.5.0 with sanitize_closing_keywords verified live in the tool env; CURRENT projection corrected to remove the hazard wording (close-keyword text replaced by explicit-comment procedure) and register PCM-0052.

Evidence:
- sanitize_closing_keywords('... close #139.') returns '... Refs #139.' (1 replacement) under ~/.local/share/uv/tools/project-continuity/bin/python; this checkpoint's own commit message passed the 0.5.0 sanitizer path; docs render --check SYNCHRONIZED; continuity validate shows only the pre-existing device-local /private/tmp/pcm-pinned error.

Decisions:
- Gate mechanism (acceptance 2) deferred to owner on #162; no cli.py/schema edits in this increment. Task-file checkpoint markers are authored only by the CLI, never hand-written.

Changed:
- tasks/TASK-PCM-0052-stale-cli-incident.md (new), checkpoints/CURRENT.md, .continuity/documents.json, docs/CONTINUITY_INDEX.md

Blocked/uncertain:
- Owner decision needed on #162 (version-drift gate vs device convention) before any CLI change; PCM-0046 arms still provider-rate-gated (~04:00Z 2026-09-26).

Next:
- Open PR for task/PCM-0052-stale-cli-incident, enable auto-merge, verify six contexts, then post merge receipt on #162 with the exact squash SHA.

## Handoff

Read PROJECT -> CURRENT -> this task -> #162 (incident facts + decision options) -> #123 addendum. Correction slice only; no CLI edits until the owner answers acceptance 2.
