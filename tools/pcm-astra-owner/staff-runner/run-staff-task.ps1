<#
.SYNOPSIS
  Execute ONE Astra staff TASK file with a cheap InferHub model through `codex exec` (staff-runner).

.DESCRIPTION
  Astra owns planning and writes inbox\TASK-NN-*.md. This runner only executes. It builds a prompt from the
  staff rules and the TASK, runs codex exec non-interactively (JSONL stream, danger-full-access sandbox, no
  wall-clock timeout) on a bid-capped cheap InferHub route, saves a receipt, verifies that the model wrote
  inbox\RESULT-NN*.md, and records live cost. If no valid RESULT exists it writes
  inbox\STAFF-RUNNER-FAILED-NN.md. It never fabricates a RESULT.
  See README.md (usage, success conditions) and model-choice.md (route evidence).

  Exit codes: 0 RESULT written | 1 no valid RESULT (FAILED note written) | 2 preflight refused |
              3 TASK already has a RESULT | 4 another runner active on this TASK | 5 bad arguments
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$TaskFile,
    [string]$Model = 'cb/deepseek-v4.1-flash',
    [double]$MaxInputPrice = 0.099,
    [double]$MaxOutputPrice = 0.099,
    [switch]$NoRepoWrite,
    [switch]$DryRun,
    [switch]$Force,
    [string]$RepoPath = 'D:\claude\projects\project-continuity-modules',
    [string]$ReceiptRoot = ''
)

$script:RepoWrite = -not $NoRepoWrite
$ErrorActionPreference = 'Stop'
$inv = [Globalization.CultureInfo]::InvariantCulture
$utf8 = New-Object System.Text.UTF8Encoding($false)
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ReceiptRoot) { $ReceiptRoot = Join-Path $here 'receipts' }
$liveHelper = 'D:\claude\inferhub\inferhub-live.ps1'
$envFile = 'D:\claude\inferhub\.env'
$codexHome = Join-Path $here 'codex-home'
$script:SecretValues = @()

function Write-Text([string]$Path, [string]$Text) { [IO.File]::WriteAllText($Path, $Text, $utf8) }
function Write-Json([string]$Path, $Obj) { Write-Text $Path (($Obj | ConvertTo-Json -Depth 8) + [Environment]::NewLine) }
function Redact([string]$s) {
    if ($null -eq $s) { return $s }
    foreach ($v in $script:SecretValues) { if ($v -and $v.Length -ge 8) { $s = $s.Replace($v, '[REDACTED]') } }
    return $s
}
function Say([string]$m) { Write-Host ("[staff-runner {0}] {1}" -f (Get-Date).ToString('HH:mm:ss'), $m) }
function Fail-Args([string]$m) { Say "ERROR: $m"; exit 5 }

# ---------- arguments / TASK identity ----------
if ($MaxInputPrice -le 0 -or $MaxInputPrice -ge 0.10 -or $MaxOutputPrice -le 0 -or $MaxOutputPrice -ge 0.10) {
    Fail-Args 'Bid caps must be > 0 and < 0.10 USD per 1M tokens (price policy). Refusing.'
}
if (-not (Test-Path -LiteralPath $TaskFile -PathType Leaf)) { Fail-Args "TASK file not found: $TaskFile" }
$taskPath = (Resolve-Path -LiteralPath $TaskFile).Path
$taskName = Split-Path $taskPath -Leaf
if ($taskName -notmatch '^TASK-(\d+)(-[^\\/]*)?\.md$') { Fail-Args "Not a TASK-NN[-slug].md file: $taskName" }
$nn = $Matches[1]
$slug = if ($Matches[2]) { $Matches[2] } else { '' }
$inbox = Split-Path $taskPath -Parent
$resultName = "RESULT-$nn$slug.md"
$resultRegex = "^RESULT-$nn(-.*)?\.md$"
$markerPath = Join-Path $inbox "STAFF-RUNNER-INPROGRESS-$nn.md"
$failedPath = Join-Path $inbox "STAFF-RUNNER-FAILED-$nn.md"
if (-not (Test-Path -LiteralPath $RepoPath)) { Fail-Args "PCM checkout not found: $RepoPath" }

$existing = @(Get-ChildItem -LiteralPath $inbox -File | Where-Object { $_.Name -match $resultRegex })
if ($existing.Count -gt 0 -and -not $Force) {
    Say ("TASK-$nn already has a RESULT ({0}); it is consumed. Use -Force to run anyway." -f (($existing | ForEach-Object Name) -join ', '))
    exit 3
}
if (Test-Path -LiteralPath $markerPath) {
    $mk = [IO.File]::ReadAllText($markerPath)
    if ($mk -match 'runner_pid=(\d+)') {
        $alive = Get-Process -Id ([int]$Matches[1]) -ErrorAction SilentlyContinue
        if ($alive) { Say "Another staff-runner (PID $($Matches[1])) is active on TASK-$nn (marker $markerPath). Not starting a second one."; exit 4 }
    }
    Say 'Stale in-progress marker found (runner PID gone); continuing.'
}

# ---------- locate codex ----------
$codexExe = 'C:\Users\pujan\AppData\Local\OpenAI\Codex\bin\247581e40ee272fb\codex.exe'
if (-not (Test-Path -LiteralPath $codexExe)) {
    $c = Get-ChildItem 'C:\Users\pujan\AppData\Local\OpenAI\Codex\bin\*\codex.exe' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $c) { Fail-Args 'codex.exe not found under the Codex desktop app bin folder.' }
    $codexExe = $c.FullName
}

# ---------- receipt ----------
$startUtc = [DateTime]::UtcNow
$stamp = $startUtc.ToString('yyyyMMddTHHmmssZ')
$receiptDir = Join-Path $ReceiptRoot "$stamp-TASK-$nn"
New-Item -ItemType Directory -Path $receiptDir -Force | Out-Null
Copy-Item -LiteralPath $taskPath -Destination (Join-Path $receiptDir 'task-copy.md')
Say "TASK-$nn -> receipt $receiptDir"

# ---------- live preflight (GET-only helper; never prints the key) ----------
function Invoke-Live([string[]]$HelperArgs) {
    $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $liveHelper @HelperArgs -Json 2>&1 | Out-String
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($code -ne 0) { throw "inferhub-live $($HelperArgs -join ' ') failed (exit $code): $out" }
    return $out
}
$refuse = @()
$price = $null; $balance = $null
try {
    $priceRaw = Invoke-Live @('prices', $Model)
    Write-Text (Join-Path $receiptDir 'price-snapshot.json') $priceRaw
    $price = $priceRaw | ConvertFrom-Json
} catch { $refuse += "live price lookup failed: $($_.Exception.Message)" }
try {
    $balRaw = Invoke-Live @('balance')
    Write-Text (Join-Path $receiptDir 'balance-before.json') $balRaw
    $balance = $balRaw | ConvertFrom-Json
} catch { $refuse += "live balance lookup failed: $($_.Exception.Message)" }
if ($price) {
    if (-not $price.listed) { $refuse += "route $Model is not listed in live /v1/models" }
    else {
        if ($price.family_state -eq 'major_outage') { $refuse += "route family state is major_outage ($($price.family_avail_now_pct)% now)" }
        if ([double]$price.min_ask_in -ge $MaxInputPrice -or [double]$price.min_ask_out -ge $MaxOutputPrice) {
            $refuse += "no live ask under the bid caps (min ask in/out $($price.min_ask_in)/$($price.min_ask_out) vs caps $MaxInputPrice/$MaxOutputPrice)"
        }
    }
}
$balanceUsdc = $null
if ($balance) {
    $balanceUsdc = [double]::Parse("$($balance.balance_usdc)", $inv)
    if ($balanceUsdc -lt 1.0) { $refuse += "InferHub balance $balanceUsdc USDC is below the 1 USDC floor" }
}
if ($Model -ne 'cb/deepseek-v4.1-flash') {
    Say "NOTE: non-default route $Model. Its IRE eligibility and tool+streaming support must already be recorded in model-choice.md."
}

# ---------- prompt ----------
$taskText = [IO.File]::ReadAllText($taskPath)
$resultPath = Join-Path $inbox $resultName
$repoAccess = if ($script:RepoWrite) { 'writable (full privilege, default); edit it only as far as the TASK explicitly authorizes. Pass -NoRepoWrite to force read-only' } else { 'READ-ONLY (the sandbox blocks writes there); use only read-only git/gh commands against it' }
$prompt = @"
You are PCM execution staff: a Codex worker started by staff-runner to execute exactly one TASK file.
Astra is the owner of project-continuity-modules (PCM). Astra plans, researches, verifies and accepts. You only execute the TASK below and report.

Paths:
- Inbox (your working directory, writable): $inbox
- TASK file: $taskPath
- Canonical PCM checkout: $RepoPath ($repoAccess)
- GitHub repository: Pukujan/project-continuity-modules (gh is authenticated through GH_TOKEN)

Staff rules (mandatory):
1. Execute ONLY this TASK. Never choose, plan or start the next work item, and never do work the TASK does not ask for.
2. Do not edit the PCM repository, its branches, pull requests or issues, and do not commit, push, fetch, pull, stash, switch branches, clone, create worktrees, clean or revert anything, unless the TASK explicitly says to. Read-only git and gh commands are fine. Set GIT_OPTIONAL_LOCKS=0 for git status.
3. Do not launch or resume Astra, Codex, or any other agent or subagent.
4. Write only the deliverables the TASK names, plus the RESULT file, inside the inbox. Do not modify or delete other inbox files.
5. Report real command output. If a command fails or something cannot be verified, say so plainly in the RESULT. Never invent SHAs, numbers, test counts or outputs.
6. Never print, echo or write secrets or tokens (for example INFERHUB_API_KEY, GH_TOKEN, gh auth token).
7. Commands run in Windows PowerShell 5.1. Prefer simple single commands.

When the TASK is done, write the RESULT file with UTF-8 text at:
  $resultPath
Use this layout, the same one prior staff results used:
  # RESULT-$nn - <short title>
  Executor: staff-runner (Codex exec, model $Model) for TASK-$nn. Date: <today> (America/New_York).
  **Outcome: <one bold line: done / partially done / failed, and why>**
  ## Artifacts (list each deliverable path, or "none" if the TASK asked only for this RESULT)
  ## Commands and environment (the exact commands you ran, with their exit codes)
  ## Results (the facts the TASK asked for, taken from real command output; tables are welcome)
  ## Unsupported / INCONCLUSIVE (anything you could not do or verify, or "none")
  ## Canonical checkout unchanged by this staff run (HEAD, branch, and git status --porcelain before and after)
  End with one line stating that staff did not choose the next work item and did not launch or resume Astra.
Write the RESULT even if the TASK failed, and describe the failure honestly. Then stop. Owner review is the next action.

===== BEGIN TASK FILE ($taskName) =====
$taskText
===== END TASK FILE =====
"@
$promptPath = Join-Path $receiptDir 'prompt.md'
Write-Text $promptPath $prompt

# ---------- codex home + provider config (same InferHub provider as launch-astra.ps1 / PCM-0027 harness) ----------
New-Item -ItemType Directory -Path $codexHome -Force | Out-Null
$trustRoots = @($inbox) + $(if ($script:RepoWrite) { @($RepoPath) } else { @() })
$trustToml = ($trustRoots | ForEach-Object { "[projects.'$($_.ToLower())']`ntrust_level = `"trusted`"`n" }) -join "`n"
$capIn = $MaxInputPrice.ToString('0.######', $inv); $capOut = $MaxOutputPrice.ToString('0.######', $inv)
$configToml = @"
# Written by staff-runner\run-staff-task.ps1 for receipt $stamp. Do not put secrets here.
model_provider = "inferhub"
approval_policy = "never"
sandbox_mode = "danger-full-access"

# Full privilege for cheap staff (Alex 2026-09-24): no sandbox prompts.
# windows.sandbox / sandbox_workspace_write are unused under danger-full-access.

[shell_environment_policy]
inherit = "all"
ignore_default_excludes = true
exclude = ["INFERHUB_API_KEY", "INFERHUB_*", "OPENAI_API_KEY"]

[model_providers.inferhub]
name = "InferHub (staff-runner, bid-capped)"
base_url = "https://api.inferhub.dev/v1"
env_key = "INFERHUB_API_KEY"
wire_api = "responses"
stream_idle_timeout_ms = 1800000
stream_max_retries = 5
request_max_retries = 4
http_headers = { "x-max-input-price" = "$capIn", "x-max-output-price" = "$capOut" }

$trustToml
"@
Write-Text (Join-Path $codexHome 'config.toml') $configToml
Write-Text (Join-Path $receiptDir 'codex-config.toml') $configToml

$finalPath = Join-Path $receiptDir 'final-message.md'
$eventsPath = Join-Path $receiptDir 'codex-events.jsonl'
$stderrPath = Join-Path $receiptDir 'codex-stderr.txt'
function Q([string]$s) { '"' + $s + '"' }
$codexArgs = @('exec', '--json', '--skip-git-repo-check', '--dangerously-bypass-approvals-and-sandbox', '--sandbox', 'danger-full-access', '--config', 'approval_policy="never"', '--cd', (Q $inbox), '--model', (Q $Model), '--output-last-message', (Q $finalPath))
if ($script:RepoWrite) { $codexArgs += @('--add-dir', (Q $RepoPath)) }
$codexArgs += '-'
$codexCmdLine = "$(Q $codexExe) $($codexArgs -join ' ')  < prompt.md   (CODEX_HOME=$codexHome)"

function Get-RepoState {
    $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    $env:GIT_OPTIONAL_LOCKS = '0'
    $h = (& git -C $RepoPath rev-parse HEAD 2>&1 | Out-String).Trim()
    $b = (& git -C $RepoPath rev-parse --abbrev-ref HEAD 2>&1 | Out-String).Trim()
    $s = (& git -C $RepoPath status --porcelain 2>&1 | Out-String).TrimEnd()
    $ErrorActionPreference = $prev
    return "HEAD=$h`nbranch=$b`nstatus --porcelain:`n$s`n"
}

$run = [ordered]@{
    runner = 'staff-runner/run-staff-task.ps1'
    task = $taskPath; task_number = $nn; expected_result = $resultPath; inbox = $inbox
    model_route = $Model; provider = 'inferhub (https://api.inferhub.dev/v1, wire_api=responses)'
    bid_cap_input_usd_per_1m = $MaxInputPrice; bid_cap_output_usd_per_1m = $MaxOutputPrice
    live_price_at_start = $(if ($price) { [ordered]@{ min_ask_in = $price.min_ask_in; min_ask_out = $price.min_ask_out; median_ask_in = $price.median_ask_in; median_ask_out = $price.median_ask_out; max_ask_in = $price.max_ask_in; max_ask_out = $price.max_ask_out; official_in = $price.official_in; official_out = $price.official_out; family_state = $price.family_state } } else { $null })
    balance_usdc_before = $balanceUsdc
    sandbox = 'danger-full-access, approval never (no sandbox prompts)'
    writable_roots = $trustRoots; repo_write = [bool]$script:RepoWrite; repo = $RepoPath
    codex_exe = $codexExe; codex_home = $codexHome; codex_command = $codexCmdLine
    wall_clock_timeout = 'none'
    started_utc = $startUtc.ToString('o'); dry_run = [bool]$DryRun
    preflight_refusals = $refuse
}

if ($refuse.Count -gt 0) {
    $run.outcome = 'preflight-refused'
    Write-Json (Join-Path $receiptDir 'run.json') $run
    $msg = "staff-runner preflight REFUSED for TASK-$nn (no Codex run, no fallback route):`n - " + ($refuse -join "`n - ")
    Write-Text (Join-Path $receiptDir 'summary.txt') ($msg + "`n")
    Say $msg
    if (-not $DryRun) {
        Write-Text $failedPath ("# STAFF-RUNNER FAILED - TASK-$nn (preflight refused)`n`nThis is NOT a RESULT. staff-runner did not run the TASK.`n`n$msg`n`nReceipt: $receiptDir`nNext: fix the cause (price/balance/route) and re-run, or escalate to Alex. The runner never falls back to a pricier route.`n")
    }
    exit 2
}

if ($DryRun) {
    $run.outcome = 'dry-run'
    Write-Json (Join-Path $receiptDir 'run.json') $run
    Write-Text (Join-Path $receiptDir 'summary.txt') ("dry run: preflight OK, prompt built, no Codex run, no paid call`ncommand: $codexCmdLine`n")
    Say "DRY RUN OK. Preflight passed (min ask $($price.min_ask_in)/$($price.min_ask_out), balance $balanceUsdc USDC)."
    Say "Would run: $codexCmdLine"
    exit 0
}

# ---------- environment for the Codex child (key only in process env) ----------
$envMap = @{}
foreach ($rawLine in [IO.File]::ReadAllLines($envFile)) {
    if ($rawLine -match '^\s*(INFERHUB_API_KEY)\s*=\s*(.*?)\s*$') {
        $v = $Matches[2]
        if ($v.Length -ge 2 -and (($v[0] -eq '"' -and $v[-1] -eq '"') -or ($v[0] -eq "'" -and $v[-1] -eq "'"))) { $v = $v.Substring(1, $v.Length - 2) }
        $envMap[$Matches[1]] = $v
    }
}
if (-not $envMap['INFERHUB_API_KEY']) { Say 'ERROR: INFERHUB_API_KEY missing from the approved env file.'; exit 2 }
$env:INFERHUB_API_KEY = $envMap['INFERHUB_API_KEY']
$script:SecretValues += $envMap['INFERHUB_API_KEY']
$prevEap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
$ghToken = (& gh auth token 2>$null | Out-String).Trim()
$ErrorActionPreference = $prevEap
if ($ghToken) { $env:GH_TOKEN = $ghToken; $env:GITHUB_TOKEN = $ghToken; $script:SecretValues += $ghToken } else { Say 'WARNING: gh auth token empty; gh commands in the TASK may fail.' }
$env:CODEX_HOME = $codexHome
$env:GIT_OPTIONAL_LOCKS = '0'
$env:PYTHONDONTWRITEBYTECODE = '1'
$env:PYTHONIOENCODING = 'utf-8'
$env:GIT_TERMINAL_PROMPT = '0'
$env:GH_PROMPT_DISABLED = '1'

Write-Text (Join-Path $receiptDir 'repo-before.txt') (Get-RepoState)
$inboxBefore = @{}
Get-ChildItem -LiteralPath $inbox -File | ForEach-Object { $inboxBefore[$_.Name] = "$($_.Length)|$($_.LastWriteTimeUtc.Ticks)" }

Write-Text $markerPath ("# staff-runner in progress - TASK-$nn`n`nrunner_pid=$PID`nmodel=$Model`nreceipt=$receiptDir`nstarted_utc=$($startUtc.ToString('o'))`n`nDo not start a second runner for this TASK while this PID is alive. No timeout is applied.`n")

# ---------- run codex (no wall-clock timeout) ----------
Say "Starting codex exec on $Model (no timeout). Events: $eventsPath"
$p = Start-Process -FilePath $codexExe -ArgumentList $codexArgs -WorkingDirectory $inbox -NoNewWindow -PassThru `
    -RedirectStandardInput $promptPath -RedirectStandardOutput $eventsPath -RedirectStandardError $stderrPath
$null = $p.Handle
Add-Content -LiteralPath $markerPath -Value "codex_pid=$($p.Id)"
$run.codex_pid = $p.Id
Write-Json (Join-Path $receiptDir 'run.json') $run
$p.WaitForExit()
$codexExit = $p.ExitCode
$endUtc = [DateTime]::UtcNow
Say "codex exited with $codexExit after $([int]($endUtc - $startUtc).TotalSeconds)s"

Write-Text (Join-Path $receiptDir 'repo-after.txt') (Get-RepoState)

# ---------- parse events ----------
$threadId = $null; $cmdCount = 0; $turnsCompleted = 0; $inTok = 0; $cachedTok = 0; $outTok = 0; $errors = @()
if (Test-Path -LiteralPath $eventsPath) {
    foreach ($line in [IO.File]::ReadAllLines($eventsPath)) {
        if (-not $line.Trim().StartsWith('{')) { continue }
        try { $ev = $line | ConvertFrom-Json } catch { continue }
        switch ($ev.type) {
            'thread.started' { $threadId = $ev.thread_id }
            'item.completed' { if ($ev.item.type -eq 'command_execution') { $cmdCount++ } }
            'turn.completed' { $turnsCompleted++; if ($ev.usage) { $inTok += [long]$ev.usage.input_tokens; $cachedTok += [long]$ev.usage.cached_input_tokens; $outTok += [long]$ev.usage.output_tokens } }
            'turn.failed' { $errors += "turn.failed: $($ev.error.message)" }
            'error' { $errors += "error: $($ev.message)" }
        }
    }
}

# ---------- verify RESULT ----------
$cands = @(Get-ChildItem -LiteralPath $inbox -File | Where-Object { $_.Name -match $resultRegex -and $_.LastWriteTimeUtc -ge $startUtc.AddSeconds(-2) })
$valid = @($cands | Where-Object { $_.Length -gt 0 -and ([IO.File]::ReadAllText($_.FullName)).Trim().Length -gt 0 })
$ok = ($valid.Count -gt 0)
$inboxChanges = @()
Get-ChildItem -LiteralPath $inbox -File | Where-Object { $_.Name -ne (Split-Path $markerPath -Leaf) } | ForEach-Object {
    $sig = "$($_.Length)|$($_.LastWriteTimeUtc.Ticks)"
    if (-not $inboxBefore.ContainsKey($_.Name)) { $inboxChanges += "added: $($_.Name)" }
    elseif ($inboxBefore[$_.Name] -ne $sig) { $inboxChanges += "modified: $($_.Name)" }
}
foreach ($k in $inboxBefore.Keys) { if (-not (Test-Path -LiteralPath (Join-Path $inbox $k))) { $inboxChanges += "deleted: $k" } }
$repoChanged = ([IO.File]::ReadAllText((Join-Path $receiptDir 'repo-before.txt')) -ne [IO.File]::ReadAllText((Join-Path $receiptDir 'repo-after.txt')))

if (-not $ok) {
    $why = if ($cands.Count -gt 0) { 'RESULT file exists but is empty' } else { 'no RESULT file was written during the run' }
    $finalTail = '(no final message)'
    if (Test-Path -LiteralPath $finalPath) { $ft = [IO.File]::ReadAllText($finalPath); if ($ft.Length -gt 1500) { $ft = $ft.Substring($ft.Length - 1500) }; $finalTail = Redact $ft }
    $errTail = if (Test-Path -LiteralPath $stderrPath) { Redact ((Get-Content -LiteralPath $stderrPath -Tail 15) -join "`n") } else { '' }
    Write-Text $failedPath @"
# STAFF-RUNNER FAILED - TASK-$nn

This is NOT a RESULT. staff-runner ran the TASK with $Model, but $why, so no result is claimed.

- codex exit code: $codexExit
- expected: $resultPath
- receipt: $receiptDir (events, stderr, prompt, price snapshot, cost)
- tool calls observed: $cmdCount; turns completed: $turnsCompleted
- errors: $(if ($errors.Count) { Redact ($errors -join ' | ') } else { 'none reported in events' })
- PCM checkout changed during run: $repoChanged
- inbox changes: $(if ($inboxChanges.Count) { $inboxChanges -join '; ' } else { 'none' })

Final message tail:

$finalTail

stderr tail:

$errTail

Next: staff inspects the receipt and re-runs the runner (or escalates). Do not hand-write a RESULT from this note.
"@
}

# ---------- live cost (logs can lag; wait briefly, then query) ----------
Start-Sleep -Seconds 45
$costWindow = $null; $costSession = $null
try {
    $cw = Invoke-Live @('usage', '-Since', $startUtc.AddSeconds(-5).ToString('yyyy-MM-ddTHH:mm:ssZ'), '-Until', ([DateTime]::UtcNow).ToString('yyyy-MM-ddTHH:mm:ssZ'), '-Model', $Model)
    Write-Text (Join-Path $receiptDir 'cost-window.json') $cw
    $costWindow = $cw | ConvertFrom-Json
} catch { Write-Text (Join-Path $receiptDir 'cost-window.json') "{`"error`": `"$($_.Exception.Message -replace '"','''')`"}" }
if ($threadId) {
    try {
        $cs = Invoke-Live @('raw', "/v1/me/usage?window=day&tz=America/New_York&session_id=$threadId")
        Write-Text (Join-Path $receiptDir 'cost-session.json') $cs
        $costSession = ($cs | ConvertFrom-Json).session
    } catch { Write-Text (Join-Path $receiptDir 'cost-session.json') "{`"error`": `"$($_.Exception.Message -replace '"','''')`"}" }
}
$balAfter = $null
try { $ba = Invoke-Live @('balance'); Write-Text (Join-Path $receiptDir 'balance-after.json') $ba; $balAfter = ($ba | ConvertFrom-Json).balance_usdc } catch {}

# ---------- secret scan of the receipt ----------
$leak = $false
Get-ChildItem -LiteralPath $receiptDir -File | ForEach-Object {
    $t = [IO.File]::ReadAllText($_.FullName)
    $r = Redact $t
    if ($r -ne $t) { $leak = $true; Write-Text $_.FullName $r }
}

# ---------- summary ----------
$run.ended_utc = $endUtc.ToString('o')
$run.codex_exit_code = $codexExit
$run.thread_id = $threadId
$run.tool_calls = $cmdCount
$run.turns_completed = $turnsCompleted
$run.codex_reported_tokens = [ordered]@{ input = $inTok; cached_input = $cachedTok; output = $outTok }
$run.errors = @($errors | ForEach-Object { Redact $_ })
$run.result_files = @($valid | ForEach-Object { $_.FullName })
$run.result_sha256 = @($valid | ForEach-Object { (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLower() })
$run.failed_note = $(if ($ok) { $null } else { $failedPath })
$run.inbox_changes = $inboxChanges
$run.repo_changed_during_run = $repoChanged
$run.cost_window_usdc_upper_bound = $(if ($costWindow) { $costWindow.spend_usdc } else { $null })
$run.cost_window_requests = $(if ($costWindow) { $costWindow.requests } else { $null })
$run.cost_session = $costSession
$run.balance_usdc_after = $balAfter
$run.secret_found_and_redacted_in_receipt = $leak
$run.outcome = $(if ($ok) { 'result-written' } else { 'failed-no-result' })
Write-Json (Join-Path $receiptDir 'run.json') $run
$summary = @(
    "outcome=$($run.outcome)"
    "task=$taskPath"
    "result=$(($run.result_files) -join ', ')"
    "failed_note=$($run.failed_note)"
    "model=$Model caps_in_out=$capIn/$capOut"
    "codex_exit=$codexExit thread=$threadId tool_calls=$cmdCount turns=$turnsCompleted"
    "tokens_in=$inTok cached=$cachedTok out=$outTok"
    "cost_window_usdc(upper bound, same route, whole account)=$($run.cost_window_usdc_upper_bound) requests=$($run.cost_window_requests)"
    "cost_session=$(if ($costSession) { "$($costSession.spend_usdc) USDC, $($costSession.requests) requests" } else { 'n/a' })"
    "balance_before=$balanceUsdc balance_after=$balAfter"
    "repo_changed_during_run=$repoChanged"
    "inbox_changes=$($inboxChanges -join '; ')"
    "secret_redacted=$leak"
) -join "`n"
Write-Text (Join-Path $receiptDir 'summary.txt') ($summary + "`n")
Remove-Item -LiteralPath $markerPath -Force -ErrorAction SilentlyContinue
Say ($summary -replace "`n", "`n    ")
if ($ok) { exit 0 } else { exit 1 }


