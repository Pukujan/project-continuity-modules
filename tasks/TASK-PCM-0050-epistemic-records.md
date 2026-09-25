# TASK-PCM-0050 — Epistemic bitemporal records decision

<!-- continuity:task {"acceptance": ["Owner selects O1/O2/O3/O4 (or combination) for claim provenance, bitemporal supersession, actor identity, classification, and adopter ticket placement, recorded on #144.", "The five open questions in docs/research/PCM-0050-epistemic-bitemporal-records.md receive a recorded answer or explicit deferral.", "Follow-up implementation issues filed per selection; this task closes as the decision record."], "depends_on": [], "goal": "Decide PCM's epistemic/bitemporal record model from researched options; no normative change in this slice.", "id": "PCM-0050", "issue_url": "https://github.com/Pukujan/project-continuity-modules/issues/144", "next_action": "Owner reads the research note and answers the five open questions on #144; implementation slices fan out only after that.", "owner": "owner/Astra planning", "priority": "P2", "protocol_version": "0.1.0-draft", "schema": "project-continuity.task.v1", "status": "active", "why": "Prose records are consumed as ground truth; without per-claim provenance, valid/transaction time and supersession links, fresh sessions re-litigate settled disagreements."} -->

- Status: active (research delivered; awaiting owner decision)
- Owner: owner/Astra planning
- Priority: P2
- Depends on: none; related #142/#143 (intake gaps that motivated this research), #67 (actor identity precedent), #137 (evidence-vs-claim holdouts)

## Checkpoint log

### 2026-09-25 — research delivered

Completed: external research (Snodgrass bitemporal model; event-sourcing supersession; W3C PROV/PROV-AQ; MITRE provenance-based belief — all cited in note); in-repo audit of claim/provenance/supersession/identity/classification/pile-up handling; four options O1-O4 with a recommended O2+O4 stance; five open questions for the owner.

Evidence: docs/research/PCM-0050-epistemic-bitemporal-records.md at this commit; issue #144 body.

Decisions: trust derives from epistemic status + evidence + independence class, never filer identity alone; GitHub ID recorded for auditability, not ranking.

Blocked/uncertain: owner decision pending; no SPEC/AGENTS/template edits authorized.

Next: owner answers the five open questions on #144.

### 2026-09-25 20:02:14 UTC — owner/Astra

<!-- continuity:checkpoint {"agent":"owner/Astra","blocked":["Local validate prints one device-local error for foreign worktree /private/tmp/pcm-pinned (pre-existing, preserved per policy, invisible to hosted CI). Workers T46Scorer2/T47Hygiene2 running; zero-delta task branches pushed so a dead session is visible as no-work rather than missing refs."],"changed":["docs/research/PCM-0050-epistemic-bitemporal-records.md, docs/plans/PCM-0046-arm-plan.md (new), .continuity/documents.json, docs/CONTINUITY_INDEX.md, checkpoints/CURRENT.md, tasks/TASK-PCM-0050-epistemic-records.md"],"completed":["Advisory remediation: PCM-0015 S9 prior-art delta addendum; MITRE/USENIX citations corrected to Chapman et al 2010 and Friedman et al 2020; research note + arm plan + three decision projections registered in the document catalog and index rendered; 20-arm plan committed to docs/plans/PCM-0046-arm-plan.md; CURRENT active_task repointed to PCM-0050; #143 ID correction comment posted (5838709963)."],"decisions":["O2 reframed as promoting PCM-0015 S9 plus five deltas (valid-time fields, independence class, O4 adopter channel, classification/aging, discovery fallback); discovery defect recorded: task-filtered docs find structurally misses prior art for new tasks until links exist."],"evidence":["docs find 'epistemic provenance bitemporal scoped assertions claims' --task PCM-0050 now matches pcm-0050-research (score 28) and prior art pcm-0015-research (16)/pcm-0015-plan (6); previously NO_MATCHES. Product commit at branch head; this checkpoint commits the task projection and pushes task/PCM-0050-epistemic-records."],"next_action":"Open PR for task/PCM-0050-epistemic-records, verify required CI and auto-merge, then post merge receipt on #144; owner answers the five open questions there.","protocol_version":"0.1.0-draft","schema":"project-continuity.checkpoint.v1","task_id":"PCM-0050","timestamp":"2026-09-25T20:02:14Z"} -->
<!-- continuity:checkpoint-operation {"payload_sha256":"47c4ec7fb0b9158f49424c8540fedfac9ad740eff53ca3983dc430c385b7a617","request_id":"pcm-0050-advisory-20260925","schema":"project-continuity.checkpoint-operation.v1","task_id":"PCM-0050"} -->

Completed:
- Advisory remediation: PCM-0015 S9 prior-art delta addendum; MITRE/USENIX citations corrected to Chapman et al 2010 and Friedman et al 2020; research note + arm plan + three decision projections registered in the document catalog and index rendered; 20-arm plan committed to docs/plans/PCM-0046-arm-plan.md; CURRENT active_task repointed to PCM-0050; #143 ID correction comment posted (5838709963).

Evidence:
- docs find 'epistemic provenance bitemporal scoped assertions claims' --task PCM-0050 now matches pcm-0050-research (score 28) and prior art pcm-0015-research (16)/pcm-0015-plan (6); previously NO_MATCHES. Product commit at branch head; this checkpoint commits the task projection and pushes task/PCM-0050-epistemic-records.

Decisions:
- O2 reframed as promoting PCM-0015 S9 plus five deltas (valid-time fields, independence class, O4 adopter channel, classification/aging, discovery fallback); discovery defect recorded: task-filtered docs find structurally misses prior art for new tasks until links exist.

Changed:
- docs/research/PCM-0050-epistemic-bitemporal-records.md, docs/plans/PCM-0046-arm-plan.md (new), .continuity/documents.json, docs/CONTINUITY_INDEX.md, checkpoints/CURRENT.md, tasks/TASK-PCM-0050-epistemic-records.md

Blocked/uncertain:
- Local validate prints one device-local error for foreign worktree /private/tmp/pcm-pinned (pre-existing, preserved per policy, invisible to hosted CI). Workers T46Scorer2/T47Hygiene2 running; zero-delta task branches pushed so a dead session is visible as no-work rather than missing refs.

Next:
- Open PR for task/PCM-0050-epistemic-records, verify required CI and auto-merge, then post merge receipt on #144; owner answers the five open questions there.

## Handoff

Read PROJECT -> CURRENT -> this task -> #144 -> docs/research/PCM-0050-epistemic-bitemporal-records.md. Decision slice only.
