# TASK-90 - staff-runner smoke test (synthetic, read-only)

Synthetic test TASK for the staff runner. It is not a PCM work item. Read-only: make no edits anywhere except writing the RESULT file in this inbox.

1. Report the canonical PCM checkout's current branch and last commit (full SHA, author date, subject), using read-only git commands: `git -C D:\claude\projects\project-continuity-modules rev-parse --abbrev-ref HEAD` and `git -C D:\claude\projects\project-continuity-modules log -1 --format="%H %aI %s"`.
2. Report `git -C D:\claude\projects\project-continuity-modules status --porcelain` output (list the paths exactly).
3. List the open pull requests of Pukujan/project-continuity-modules with `gh pr list --repo Pukujan/project-continuity-modules --state open --json number,title,headRefName` (number, title, head branch for each).
4. Write RESULT-90-staff-runner-smoke.md in this inbox using the standard RESULT layout, then stop.

No PR, issue, or comment actions. No commit, fetch, or branch switch.
