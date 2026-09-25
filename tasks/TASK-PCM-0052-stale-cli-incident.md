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

## Handoff

Read PROJECT -> CURRENT -> this task -> #162 (incident facts + decision options) -> #123 addendum. Correction slice only; no CLI edits until the owner answers acceptance 2.
