# TASK-PCM-0051 — Sanitizer colon/cross-repo forms

<!-- continuity:task {"acceptance": ["Colon and cross-repo closing forms sanitize to Refs with operator NOTE; --allow-closing-keywords still opts out", "Deterministic tests red-before/green-after in tests/test_checkpoint_hygiene.py; six required hosted contexts green on the exact candidate"], "depends_on": [], "goal": "Widen the checkpoint commit-message sanitizer to colon (Closes: #N) and cross-repo (Fixes org/repo#N) GitHub closing forms.", "id": "PCM-0051", "issue_url": "https://github.com/Pukujan/project-continuity-modules/issues/154", "next_action": "TDD slice on this branch: failing tests first, then widen CLOSING_DIRECTIVE_RE separator/ref patterns.", "owner": "owner/Astra planning", "priority": "P2", "protocol_version": "0.1.0-draft", "schema": "project-continuity.task.v1", "status": "active", "why": "GitHub honors colon and cross-repo closing forms that the shipped [-\\s]+ separator misses, so an effective directive can still land in a checkpoint commit message."} -->

- Status: active
- Owner: owner/Astra planning
- Priority: P2
- Depends on: none; related #140 (CLOSED, shipped sanitizer), #122, #123

## Checkpoint log

### 2026-09-25 — red->green on colon/cross-repo forms

Completed: EFFECTIVE_CLOSING test pattern widened (colon `Closes: #N`, `CLOSES:#N`, cross-repo `Fixes org/repo#N`); CLOSING_DIRECTIVE_RE widened with a colon separator branch and optional org/repo prefix; replacement helper preserves the original separator (hyphen/space) or emits ": " for colon forms. Bare "close 12" deliberately NOT sanitized (not a GitHub closing form).

Evidence: focused tests.test_checkpoint_hygiene 13/13 OK (red capture: 3 failures of 13 at the red commit); ruff clean; mypy clean; full discover: exactly the six known macOS-environmental failures.

Decisions: group 2 requires #N or issues URL; colon rewrite yields "Refs: #N" (non-closing).

Blocked/uncertain: none.

Next: PR under required CI + auto-merge; receipts on #154/#123.

## Handoff

Read #154. Widen CLOSING_DIRECTIVE_RE (src/continuity/cli.py) for colon separators and org/repo#N refs; red-first tests in tests/test_checkpoint_hygiene.py.
