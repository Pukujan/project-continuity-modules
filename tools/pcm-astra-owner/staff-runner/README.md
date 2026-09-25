# staff-runner - cheap-model execution of Astra's staff TASK files

Astra (`cb/gpt-6-astra`) stays the owner: it plans, researches, verifies, accepts, and writes
`inbox\TASK-NN-*.md`. The staff runner only executes one released TASK file. It does this with a cheap
InferHub model driven by `codex exec` (non-interactive, JSONL event stream), so the Grok Bot
assistant does not spend its own (expensive) inference on it. It follows IRE's `run_codex_harness.ps1`
pattern (codex exec + `--json` + `danger-full-access` sandbox + `approval_policy=never`) and uses the
InferHub provider config that `launch-astra.ps1` and the PCM-0027 blind-test harness already use.

Chosen route and evidence: see `model-choice.md` (default `cb/deepseek-v4.1-flash`, bid-capped below $0.10/1M).

## Usage

```powershell
cd D:\claude\_workspace\pcm-astra-owner\staff-runner
# free: builds the prompt, runs the live price/balance preflight, writes a receipt, prints the codex command
powershell -NoProfile -ExecutionPolicy Bypass -File .\run-staff-task.ps1 -TaskFile ..\inbox\TASK-09-example.md -DryRun
# real run (foreground; no wall-clock timeout)
powershell -NoProfile -ExecutionPolicy Bypass -File .\run-staff-task.ps1 -TaskFile ..\inbox\TASK-09-example.md
# background, detached, no timeout (what the watchdog/staff should use)
$cmd = 'powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "D:\claude\_workspace\pcm-astra-owner\staff-runner\run-staff-task.ps1" -TaskFile "D:\claude\_workspace\pcm-astra-owner\inbox\TASK-09-example.md"'
Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $cmd; CurrentDirectory = 'D:\claude\_workspace\pcm-astra-owner\staff-runner' }
```

Parameters:

| Parameter | Default | Meaning |
|---|---|---|
| `-TaskFile` | (required) | Path to `TASK-NN-*.md`. Its folder is treated as the inbox; the RESULT goes there. |
| `-Model` | `cb/deepseek-v4.1-flash` | InferHub route. Pass another only after the `model-choice.md` checks (IRE list, under $0.10, tools + streaming). |
| `-MaxInputPrice` / `-MaxOutputPrice` | `0.099` | InferHub bid caps (USD per 1M tokens) sent as `x-max-input-price` / `x-max-output-price` on every request. The script refuses values of 0.10 or more. If no provider is under the cap, InferHub returns `402 no_provider_under_bid` and the run fails. It never silently uses a pricier route. |
| `-RepoWrite` | off | Also makes the PCM checkout writable in the sandbox. Use it only when the TASK explicitly authorizes product edits. |
| `-DryRun` | off | No Codex and no paid call. The live GET-only price/balance preflight still runs. |
| `-Force` | off | Run even if a `RESULT-NN*.md` already exists (by default an existing RESULT means the TASK is consumed, so the script exits 3). |
| `-RepoPath` | `D:\claude\projects\project-continuity-modules` | Canonical PCM checkout (read-only unless `-RepoWrite`). |
| `-ReceiptRoot` | `staff-runner\receipts` | Receipts go in `<ReceiptRoot>\<UTC stamp>-TASK-NN\`. |

Exit codes: `0` RESULT written, `1` Codex finished but no valid RESULT (FAILED note written), `2` preflight refused
(price, balance, or route unavailable), `3` TASK already has a RESULT, `4` another runner is active on this TASK, `5` bad arguments.

## What one run does

1. Parses `NN` from the TASK name. Refuses if `RESULT-NN*.md` already exists (unless `-Force`) or if a live
   `STAFF-RUNNER-INPROGRESS-NN.md` marker exists.
2. Live preflight (GET-only, `D:\claude\inferhub\inferhub-live.ps1`): route price snapshot and balance. It refuses if
   the route is unlisted or in `major_outage`, if the cheapest live ask is not under the bid caps, or if the balance is under $1.
3. Builds `prompt.md`: the staff rules, the RESULT format (modelled on RESULT-05..08), and the full TASK text.
4. Runs `codex exec --json` with `CODEX_HOME=staff-runner\codex-home`, the InferHub provider (`wire_api="responses"`, bid-cap headers),
   `--sandbox danger-full-access` and `approval_policy=never` (full privilege, no sandbox approval prompts; Alex 2026-09-24). The working directory is the inbox. `GH_TOKEN` comes from `gh auth token`. There is **no wall-clock timeout**.
   The InferHub key is loaded into the process environment only and is never printed or written.
5. Afterwards it verifies that a `RESULT-NN*.md` created or modified during the run exists and is non-empty. If none exists, it writes
   `inbox\STAFF-RUNNER-FAILED-NN.md` (clearly not a RESULT) and never fabricates a result.
6. Records live cost: `inferhub-live usage -Since <start> -Until <end> -Model <route>`. Other agents using the same route at the same time
   (the PCM-0027 blind test also uses DeepSeek V4.1 Flash) are included in that window, so it is an upper bound. The script also tries
   the per-session lookup `/v1/me/usage?session_id=<codex thread id>` and records the Codex-reported token totals.

Receipt folder contents: `prompt.md`, `task-copy.md`, `run.json` (route, caps, sandbox, paths, times, exit, thread id),
`price-snapshot.json`, `balance-before.json`, `balance-after.json`, `codex-events.jsonl`, `codex-stderr.txt`,
`final-message.md`, `repo-before.txt`, `repo-after.txt`, `cost-window.json`, `cost-session.json`, `summary.txt`.

## Success conditions (written before any test)

The runner counts as working only if a real end-to-end test on a synthetic TASK in `staff-runner\test\inbox\` (never the real inbox) meets all of these:

1. **Preflight:** the receipt holds a live price snapshot for the route, fetched during the run, with `family_state` not `major_outage` and `min_ask_in`/`min_ask_out` under the bid cap. The balance before the run is at least $1.
2. **Price policy enforced:** Codex runs with `x-max-input-price`/`x-max-output-price` below 0.10, on the chosen route only, with no fallback route configured.
3. **Tool calling and streaming observed:** `codex-events.jsonl` contains streamed JSONL events, including at least one `command_execution` item (a tool call the cheap model made) and a `turn.completed` event. Codex exits 0.
4. **RESULT written by the model:** a non-empty `RESULT-90-*.md` appears in the test inbox. Its facts match the ground truth that I collect myself (the PCM branch and last commit SHA, and the open PR numbers from `gh pr list`), and it follows the RESULT layout (title, executor line, outcome, commands, checkout-unchanged section).
5. **No side effects:** the PCM checkout's HEAD, branch, and `git status --porcelain` are identical before and after (the 4 Astra docs are untouched). The real `inbox\` has no new or changed files. No GitHub issue, PR, or comment is created. The Astra processes and the blind-test processes are still running and unaffected.
6. **Secrets:** the InferHub key does not appear in any receipt file.
7. **Cost recorded:** the receipt has a live cost figure from `inferhub-live usage` (and a session figure if InferHub supports it). The test costs under $0.05 and the balance stays above $1.
8. **Failure path:** `-DryRun` makes no paid call and writes no RESULT. A tiny negative TASK (NN=91) that tells the model not to write a RESULT makes the runner write `STAFF-RUNNER-FAILED-91.md`, and no `RESULT-91*`, and exit 1.

Test outcomes are logged in `test\TEST-LOG.md`.

## Rules the runner puts in every prompt (from staff-goal.md / ROLE.md / prior TASKs)

- Execute only the given TASK. Never pick, plan, or start the next work item.
- Do not edit the PCM repo, branches, PRs, or issues, and do not commit, push, fetch, stash, switch branches, clone, or create a worktree, unless the TASK explicitly says so.
- Do not launch or resume Astra, and do not start Codex subagents or other agents.
- Write only the TASK's deliverables plus the RESULT, in the inbox.
- Report real command output. Report failures as failures. Never fabricate.
- Never print or write secrets.
