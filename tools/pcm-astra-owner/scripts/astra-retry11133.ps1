# astra-retry11133.ps1 - dot-sourced by launch-astra.ps1 and resume-astra.ps1 (Windows PowerShell 5.1 compatible).
#
# Auto-retry for InferHub model_param_invalid / code 11133 on route cb/gpt-6-astra.
# v2 2026-09-24 (approved by Alex): FRESH-SESSION retry. Evidence from today: resuming the same thread
# replays the exact rejected history and fails again (3/3 at 220157Z, 3/3 at 223109Z); every successful
# recovery was a fresh launch. So on 11133 the launcher now writes a short bounded handoff prompt and starts
# a NEW session through launch-astra.ps1 (same route, same flags) in a pre-allocated receipt folder.
#
# Rules:
#   - Retry only when exit code != 0 AND the final error/turn.failed event says code 11133 or
#     model_param_invalid. Any other failure is never retried (Astra stops as before).
#   - At most 2 retries per original launch. The retry number travels to the child launcher
#     (-Retry11133Attempt), so the child's own chain continues the same budget; a third 11133 stops.
#   - Retry 1 gets the standard bounded handoff; retry 2 gets a minimal handoff (different wording,
#     in case the handoff text itself is what the upstream rejects).
#   - Every decision is appended to RETRY.md in the evaluated receipt (vocabulary unchanged:
#     "decision: RETRY n of 2 - ..." / "decision: NO RETRY - ..."), plus "mode: fresh-session".
#   - Every 11133 failure and every retry outcome is logged to IRE's Operational Issue Ledger.
#     Ledger problems only write a warning (RETRY.md + ledger.log); they never block or stop the retry.
#   - API keys come from the caller's process environment only; nothing here reads or prints them.
# Test hooks (env): ASTRA_LEDGER_DB (ledger path), ASTRA_LEDGER_DISABLE=1, ASTRA_LEDGER_DRYRUN=1,
#   ASTRA_RETRY_LAUNCH_DRYRUN=1 (write launch-command.txt instead of starting a session),
#   ASTRA_HANDOFF_DIR (where handoff prompts are written).

$script:Astra11133DefaultMaxRetries = 2
$script:AstraWorkspace = 'D:\claude\_workspace\pcm-astra-owner'
$script:AstraInboxDir = Join-Path $script:AstraWorkspace 'inbox'
$script:AstraLaunchScript = Join-Path $script:AstraWorkspace 'launch-astra.ps1'
$script:AstraHandoffDir = if ($env:ASTRA_HANDOFF_DIR) { $env:ASTRA_HANDOFF_DIR } else { $script:AstraWorkspace }
$script:AstraIreRoot = 'D:\claude\inference-recommendation-engine'
$script:AstraLedgerDb = if ($env:ASTRA_LEDGER_DB) { $env:ASTRA_LEDGER_DB } else { Join-Path $script:AstraIreRoot '.ire\issue-ledger\ledger.sqlite3' }
$script:AstraCodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
$script:AstraLedgerCommon = @(
    '--provider', 'inferhub', '--route', 'cb/gpt-6-astra', '--model', 'cb/gpt-6-astra',
    '--operation', 'codex-exec', '--workload-class', 'long_horizon', '--stream-mode', 'sse', '--harness', 'codex-exec',
    '--actor-id', 'service:astra-retry11133', '--actor-kind', 'service', '--classification', 'provider',
    '--error-code', '11133', '--failure-phase', 'request'
)

function Get-AstraUtcNow { return [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ') }

function Get-AstraEventsFailureInfo {
    # Reads a codex --json events file. Returns thread id (first thread.started), the final terminal
    # event type (error / turn.failed / turn.completed), whether that final failure is code 11133,
    # and (for 11133) the InferHub requestId and request shape.
    param([Parameter(Mandatory = $true)][string]$EventsPath)
    $info = [pscustomobject]@{
        EventsPath     = $EventsPath
        ThreadId       = $null
        FinalEventType = $null
        Is11133        = $false
        Reason         = ''
        RequestId      = ''
        Shape          = ''
        FailedAtUtc    = ''
    }
    if (-not (Test-Path -LiteralPath $EventsPath)) { $info.Reason = 'events file missing'; return $info }
    try { $info.FailedAtUtc = (Get-Item -LiteralPath $EventsPath).LastWriteTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ') } catch {}
    $finalLine = $null
    $typeRegex = '^\s*\{\s*"type"\s*:\s*"(thread\.started|error|turn\.failed|turn\.completed)"'
    $wanted = @('thread.started', 'error', 'turn.failed', 'turn.completed')
    foreach ($line in [System.IO.File]::ReadLines($EventsPath)) {
        if (-not ($line.Contains('"thread.started"') -or $line.Contains('"error"') -or $line.Contains('"turn.failed"') -or $line.Contains('"turn.completed"'))) { continue }
        $t = $null
        $m = [regex]::Match($line, $typeRegex)
        if ($m.Success) {
            $t = $m.Groups[1].Value
        } else {
            try { $po = $line | ConvertFrom-Json; if ($wanted -contains [string]$po.type) { $t = [string]$po.type } } catch {}
        }
        if (-not $t) { continue }
        if ($t -eq 'thread.started') {
            if ($null -eq $info.ThreadId) {
                try { $o = $line | ConvertFrom-Json; if ($o.thread_id) { $info.ThreadId = [string]$o.thread_id } } catch {}
            }
            continue
        }
        $finalLine = $line
        $info.FinalEventType = $t
    }
    if ($null -eq $finalLine) { $info.Reason = 'no terminal event (error/turn.failed/turn.completed) in events file'; return $info }
    if ($info.FinalEventType -eq 'turn.completed') { $info.Reason = 'final event is turn.completed'; return $info }
    $msg = $null
    try {
        $o = $finalLine | ConvertFrom-Json
        if ($info.FinalEventType -eq 'turn.failed') { $msg = [string]$o.error.message } else { $msg = [string]$o.message }
    } catch { $msg = $finalLine }
    if ([string]::IsNullOrEmpty($msg)) { $msg = $finalLine }
    if ($msg -match '"code"\s*:\s*11133\b' -or $msg -match 'model_param_invalid') {
        $info.Is11133 = $true
        $info.Reason = "final $($info.FinalEventType) carries code 11133 / model_param_invalid"
        $rm = [regex]::Match($msg, '"requestId"\s*:\s*"([0-9A-Za-z\-]+)"'); if ($rm.Success) { $info.RequestId = $rm.Groups[1].Value }
        $sm = [regex]::Match($msg, '"inferhubShape"\s*:\s*"(msgs=\d+ tools=\d+)'); if ($sm.Success) { $info.Shape = $sm.Groups[1].Value }
    } else {
        $short = $msg; if ($short.Length -gt 200) { $short = $short.Substring(0, 200) + '...' }
        $info.Reason = "final $($info.FinalEventType) is not 11133: $short"
    }
    return $info
}

function Get-Astra11133RetryDecision {
    # Pure decision: retry only on non-zero exit + final 11133 + known thread + budget left.
    param($Info, $ExitCode, [int]$RetriesUsed, [int]$MaxRetries = 2)
    if ($null -ne $ExitCode -and "$ExitCode" -eq '0') { return [pscustomobject]@{ Retry = $false; Reason = 'exit code 0' } }
    if (-not $Info.Is11133) { return [pscustomobject]@{ Retry = $false; Reason = "not code 11133 ($($Info.Reason))" } }
    if (-not $Info.ThreadId) { return [pscustomobject]@{ Retry = $false; Reason = 'code 11133 but no thread.started thread_id in events' } }
    if ($RetriesUsed -ge $MaxRetries) { return [pscustomobject]@{ Retry = $false; Reason = "code 11133 but retry budget exhausted ($RetriesUsed of $MaxRetries used)" } }
    return [pscustomobject]@{ Retry = $true; Reason = "code 11133; retry $($RetriesUsed + 1) of $MaxRetries" }
}

function Write-AstraRetryNote {
    param([string]$ReceiptDir, [string[]]$Lines)
    try { Add-Content -LiteralPath (Join-Path $ReceiptDir 'RETRY.md') -Value (($Lines + '') -join [Environment]::NewLine) -Encoding UTF8 } catch {}
}

function New-AstraRetryReceiptDir {
    param([Parameter(Mandatory = $true)][string]$ReceiptRoot)
    for ($i = 0; $i -lt 30; $i++) {
        $stamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ')
        $dir = Join-Path $ReceiptRoot $stamp
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            return [pscustomobject]@{ Stamp = $stamp; Dir = $dir }
        }
        Start-Sleep -Seconds 1
    }
    throw 'Could not allocate a unique retry receipt directory.'
}

function Get-AstraReceiptKind {
    # 'resume' / 'fresh-retry' / 'fresh' from attempt.txt (launch-astra.ps1 writes none for normal launches).
    param([string]$ReceiptDir)
    $p = Join-Path $ReceiptDir 'attempt.txt'
    if (-not (Test-Path -LiteralPath $p)) { return 'fresh' }
    $a = ''
    foreach ($l in [System.IO.File]::ReadAllLines($p)) { if ($l -match '^action=(.*)$') { $a = $Matches[1].Trim() } }
    if ($a -like '*fresh-retry*') { return 'fresh-retry' }
    if ($a -like '*resume*') { return 'resume' }
    return 'fresh'
}

function Get-AstraLatestNumbered {
    param([string]$Dir, [string]$Prefix)
    $best = $null
    if (-not (Test-Path -LiteralPath $Dir)) { return $null }
    $rx = '^' + [regex]::Escape($Prefix) + '-(\d+)'
    foreach ($f in Get-ChildItem -LiteralPath $Dir -File -Filter "$Prefix-*") {
        $m = [regex]::Match($f.Name, $rx)
        if (-not $m.Success) { continue }
        $n = [int]$m.Groups[1].Value
        if ($null -eq $best -or $n -gt $best.Num -or ($n -eq $best.Num -and $f.LastWriteTimeUtc -gt $best.Time)) {
            $best = [pscustomobject]@{ Num = $n; Name = $f.Name; Time = $f.LastWriteTimeUtc }
        }
    }
    return $best
}

function Get-AstraInboxState {
    param([string]$InboxDir = $script:AstraInboxDir, [string]$SinceReceiptLeaf = '', [string]$UntilUtc = '')
    $decision = Get-AstraLatestNumbered $InboxDir 'DECISION'
    $ownerNext = Get-AstraLatestNumbered $InboxDir 'OWNER-NEXT'
    $task = Get-AstraLatestNumbered $InboxDir 'TASK'
    $pairing = 'no TASK files in inbox'
    if ($task) {
        $result = $null
        foreach ($f in Get-ChildItem -LiteralPath $InboxDir -File -Filter ('RESULT-{0:D2}-*' -f $task.Num)) { $result = $f.Name }
        if ($result) { $pairing = "latest staff task $($task.Name) already has $result (consumed; no unconsumed staff TASK)" }
        else { $pairing = "latest staff task $($task.Name) has NO RESULT yet (staff may be executing it; do not rewrite it)" }
    }
    $changed = @()
    if ($SinceReceiptLeaf) {
        try {
            $since = [DateTime]::ParseExact($SinceReceiptLeaf, 'yyyyMMddTHHmmssZ', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]'AssumeUniversal,AdjustToUniversal')
            $until = [DateTime]::MaxValue
            if ($UntilUtc) { $until = [DateTime]::Parse($UntilUtc, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]'AssumeUniversal,AdjustToUniversal').AddSeconds(60) }
            $changed = @(Get-ChildItem -LiteralPath $InboxDir -File | Where-Object { $_.LastWriteTimeUtc -ge $since -and $_.LastWriteTimeUtc -le $until } | Sort-Object LastWriteTimeUtc | Select-Object -Last 12 | ForEach-Object { $_.Name })
        } catch {}
    }
    return [pscustomobject]@{
        Decision  = $(if ($decision) { $decision.Name } else { '' })
        OwnerNext = $(if ($ownerNext) { $ownerNext.Name } else { '' })
        Pairing   = $pairing
        Changed   = $changed
    }
}

function New-Astra11133HandoffPrompt {
    # Writes the bounded handoff prompt for a fresh-session retry and returns its path.
    param([string]$FailedReceiptDir, [string]$FailedThreadId, [string]$FailedKind, [int]$Attempt, [int]$MaxRetries,
          [string]$OriginReceiptDir, [string]$FailedAtUtc = '', [string]$InboxDir = $script:AstraInboxDir, [string]$OutDir = $script:AstraHandoffDir)
    $failedLeaf = Split-Path $FailedReceiptDir -Leaf
    $originLeaf = Split-Path $OriginReceiptDir -Leaf
    $st = Get-AstraInboxState -InboxDir $InboxDir -SinceReceiptLeaf $failedLeaf -UntilUtc $FailedAtUtc
    $on = $(if ($st.OwnerNext) { "inbox\$($st.OwnerNext)" } else { 'the newest OWNER-NEXT-*.md in the inbox' })
    $dn = $(if ($st.Decision) { "inbox\$($st.Decision)" } else { 'the newest DECISION-*.md in the inbox' })
    $nl = [Environment]::NewLine
    if ($Attempt -le 1) {
        $changedLines = $(if ($st.Changed.Count -gt 0) { ($st.Changed | ForEach-Object { "  - $_" }) -join $nl } else { '  - none' })
        $text = @"
Continue as the planning, research, and verification owner for PCM-0026 (issues 67 and 53). This is an automatic fresh session: InferHub error 11133 (model_param_invalid) ended the previous turn, and the launcher does not replay that thread. Handoff written by astra-retry11133.ps1, retry $Attempt of $MaxRetries.

## What happened
- Failed receipt: $failedLeaf ($FailedKind session, thread $FailedThreadId). Chain origin: $originLeaf.
- Inbox files written or changed during the failed turn (treat as done; do not redo):
$changedLines

## Where you are (inbox: $InboxDir)
- Latest decision: $($st.Decision)
- Latest owner-next: $($st.OwnerNext)
- Staff pairing: $($st.Pairing)

## Next step
Read $on first, then only the head of $dn. Continue from the step they name. Do not redo accepted work, do not re-run completed owner verification, and do not re-read TASK/RESULT/EVIDENCE/test files in full. If the failed turn left a partial artifact, finish or supersede it instead of starting over.

Keep tool reads bounded (heads/selective slices, small max_output_tokens) to avoid another 11133.

## Constraints
- Do not edit branch docs/astra-restore-not-stop or PR 98.
- Do not revert unrelated local edits in the canonical checkout; no branch switch or reset.
- Do not implement the publisher in this turn.
- Do not relaunch staff and do not resume any failed thread by hand.
- Write exactly one TASK-*.md only if staff must execute something; otherwise do owner research/decision yourself and record owner-next or an explicit Alex blocker in the inbox.

Stop when the next owner decision or staff TASK (or explicit Alex blocker / done state) is recorded.
"@
    } else {
        $text = @"
Owner session for PCM-0026, restarted automatically (retry $Attempt of $MaxRetries) after provider error 11133; previous receipt $failedLeaf, thread $FailedThreadId. In $script:AstraWorkspace read $on, then the head of $dn, and continue from that step without redoing accepted work. Staff pairing: $($st.Pairing). Keep reads short. Record the next decision, staff TASK, or blocker in the inbox, then stop.
"@
    }
    if (-not (Test-Path -LiteralPath $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
    $path = Join-Path $OutDir ("continue-after-11133-{0}-r{1}.md" -f $failedLeaf, $Attempt)
    [System.IO.File]::WriteAllText($path, $text.Trim() + $nl)
    return $path
}

# ---------------- IRE Operational Issue Ledger (fail-open) ----------------

function Get-AstraRolloutInfo {
    param([string]$ThreadId)
    $r = [pscustomobject]@{ Path = ''; Sha256 = ''; LastInputTokens = ''; Compacted = 'unknown' }
    if (-not $ThreadId) { return $r }
    try {
        $root = Join-Path $script:AstraCodexHome 'sessions'
        $f = Get-ChildItem -LiteralPath $root -Recurse -File -Filter "rollout-*$ThreadId.jsonl" -ErrorAction SilentlyContinue | Sort-Object LastWriteTimeUtc | Select-Object -Last 1
        if (-not $f) { return $r }
        $r.Path = $f.FullName
        $r.Sha256 = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($f.Length -lt 60MB) {
            $lines = [System.IO.File]::ReadAllLines($f.FullName)
            $r.Compacted = 'no'
            foreach ($l in $lines) { if ($l -match '"type"\s*:\s*"compacted"') { $r.Compacted = 'yes'; break } }
            for ($i = $lines.Length - 1; $i -ge 0; $i--) {
                if ($lines[$i].Contains('"token_usage_record"')) {
                    $m = [regex]::Match($lines[$i], '"usage"\s*:\s*\{\s*"input_tokens"\s*:\s*(\d+)')
                    if ($m.Success) { $r.LastInputTokens = $m.Groups[1].Value; break }
                }
            }
        }
    } catch {}
    return $r
}

function ConvertTo-AstraLedgerText([string]$s, [int]$Max = 900) {
    if ($null -eq $s) { return '' }
    $t = ($s -replace '"', "'" -replace '[\r\n]+', ' ').Trim()
    if ($t.Length -gt $Max) { $t = $t.Substring(0, $Max) }
    return $t
}

function Get-AstraFileRef([string]$Path) {
    try {
        $h = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
        return ('file:' + ($Path -replace '\\', '/') + '#sha256:' + $h)
    } catch { return ('file:' + ($Path -replace '\\', '/')) }
}

function Invoke-AstraLedger {
    # Runs one ledger CLI call from the IRE root. Never throws; returns a short status string.
    param([string]$Script, [string]$Verb, [string[]]$LedgerArgs, [string]$LogDir)
    if ($env:ASTRA_LEDGER_DISABLE -eq '1') { return 'disabled' }
    $logPath = Join-Path $LogDir 'ledger.log'
    try {
        $argv = @('run', '--locked', 'python', '-B', "operational/scripts/$Script", '--db', $script:AstraLedgerDb, $Verb) + $script:AstraLedgerCommon + $LedgerArgs
        $shown = ($argv | ForEach-Object { if ($_ -match '\s') { "'" + $_ + "'" } else { $_ } }) -join ' '
        Add-Content -LiteralPath $logPath -Value "[$(Get-AstraUtcNow)] (cwd $script:AstraIreRoot) uv $shown" -Encoding UTF8
        if ($env:ASTRA_LEDGER_DRYRUN -eq '1') { return 'dry-run' }
        $uv = (Get-Command uv -ErrorAction Stop).Source
        $job = Start-Job -ScriptBlock {
            param($root, $uvExe, $a)
            Set-Location -LiteralPath $root
            $ErrorActionPreference = 'Continue'
            $o = & $uvExe @a 2>&1 | Out-String
            "EXIT=$LASTEXITCODE"
            $o
        } -ArgumentList $script:AstraIreRoot, $uv, $argv
        # Bounded wait for this short local SQLite write only (not an agent); a stuck ledger call must not hold up Astra.
        if (-not (Wait-Job -Job $job -Timeout 180)) {
            Stop-Job -Job $job -ErrorAction SilentlyContinue; Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
            Add-Content -LiteralPath $logPath -Value "  WARNING: ledger call did not finish in 180 s; skipped" -Encoding UTF8
            return 'WARNING timeout'
        }
        $out = (Receive-Job -Job $job -ErrorAction SilentlyContinue | Out-String)
        Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
        Add-Content -LiteralPath $logPath -Value ('  ' + ($out.Trim() -replace '[\r\n]+', ' | ')) -Encoding UTF8
        $ev = [regex]::Match($out, '"event"\s*:\s*"([^"]+)"')
        if ($out -match 'EXIT=0' -and $ev.Success) { return "ok $($ev.Groups[1].Value)" }
        return 'WARNING ledger call failed (see ledger.log)'
    } catch {
        try { Add-Content -LiteralPath $logPath -Value "  WARNING: $($_.Exception.Message)" -Encoding UTF8 } catch {}
        return "WARNING $($_.Exception.Message)"
    }
}

function Write-Astra11133Ledger {
    # Origin failure -> report + rollout evidence. Retry run -> evidence (role receipt) under the origin run.
    param($Info, [string]$ReceiptDir, [string]$OriginReceiptDir, [int]$RetriesUsed, [int]$MaxRetries, $Decision, $ExitCode)
    $status = @()
    try {
        $leaf = Split-Path $ReceiptDir -Leaf
        $originLeaf = Split-Path $OriginReceiptDir -Leaf
        $x = "astra-$originLeaf"
        $kind = Get-AstraReceiptKind $ReceiptDir
        $ro = Get-AstraRolloutInfo $Info.ThreadId
        $eventsRef = Get-AstraFileRef (Join-Path $ReceiptDir 'codex-events.jsonl')
        $obs = $(if ($Info.FailedAtUtc) { $Info.FailedAtUtc } else { Get-AstraUtcNow })
        $next = $(if ($Decision.Retry) { "fresh-session retry $($RetriesUsed + 1) of $MaxRetries via launch-astra.ps1 with bounded handoff" } elseif ($Info.Is11133) { 'retry budget exhausted; watchdog normal recovery (fresh launch with bounded handoff)' } else { 'none (not 11133)' })
        $what = $(if ($Info.Is11133) { "InferHub 11133 model_param_invalid HTTP 400 (requestId $($Info.RequestId); shape $($Info.Shape))" } else { "non-11133 failure: $($Info.Reason)" })
        $facts = "last recorded request input tokens $($ro.LastInputTokens); compaction in thread: $($ro.Compacted)"
        if ($RetriesUsed -eq 0) {
            $recovery = $(if ($Decision.Retry) { 'attempted' } else { 'not_attempted' })
            $sum = ConvertTo-AstraLedgerText "Astra $kind run $leaf (thread $($Info.ThreadId)) failed: $what. $facts. Auto-logged by astra-retry11133.ps1; next: $next. Fresh-session retries are same-actor follow-ups, not independent verification."
            $a = @('--execution-id', $x, '--correlation-id', $x, '--observed-at', $obs, '--outcome', 'failure', '--summary', $sum,
                   '--idempotency-key', "report:${x}:11133", '--receipt-ref', $eventsRef, '--recovery-status', $recovery,
                   '--next-action', 'Do not replay the rejected thread; fresh session with bounded handoff; capture the rejected request body by requestId.')
            if ($Decision.Retry) { $a += @('--recovery-action', 'launcher fresh-session retry via launch-astra.ps1 (astra-retry11133.ps1 v2)', '--recovery-result', 'pending') }
            $status += 'report ' + (Invoke-AstraLedger 'issue_ledger_agent.py' 'report' $a $ReceiptDir)
            if ($ro.Path) {
                $b = @('--execution-id', $x, '--correlation-id', $x, '--outcome', 'failure', '--summary', "Codex rollout for $leaf (thread $($Info.ThreadId)): token_usage_record, turn_context, compaction events, final 11133 error.",
                       '--receipt-ref', "file:$($ro.Path -replace '\\','/')#sha256:$($ro.Sha256)", '--evidence-role', 'trace', '--idempotency-key', "evidence:${x}:rollout")
                $status += 'rollout ' + (Invoke-AstraLedger 'issue_ledger_actions.py' 'attach-evidence' $b $ReceiptDir)
            }
        } else {
            $tail = $(if ($Decision.Retry) { "next: $next" } elseif ($Info.Is11133) { "retry budget exhausted ($RetriesUsed of $MaxRetries); recovery failed" } else { 'chain stops (non-11133)' })
            $sum = ConvertTo-AstraLedgerText "Fresh-session retry $RetriesUsed of $MaxRetries (receipt $leaf, new thread $($Info.ThreadId)) for origin $originLeaf failed: $what. $facts. $tail. Same-actor retry, not an independent verifier."
            $b = @('--execution-id', $x, '--correlation-id', $x, '--outcome', 'failure', '--summary', $sum, '--receipt-ref', $eventsRef,
                   '--evidence-role', 'receipt', '--idempotency-key', "evidence:${x}:retry$RetriesUsed")
            $status += "retry$RetriesUsed " + (Invoke-AstraLedger 'issue_ledger_actions.py' 'attach-evidence' $b $ReceiptDir)
        }
    } catch { $status += "WARNING $($_.Exception.Message)" }
    return ($status -join '; ')
}

function Write-Astra11133LedgerSuccess {
    param([string]$ReceiptDir, [string]$OriginReceiptDir, [int]$RetriesUsed, [int]$MaxRetries)
    try {
        $leaf = Split-Path $ReceiptDir -Leaf
        $x = 'astra-' + (Split-Path $OriginReceiptDir -Leaf)
        $sum = ConvertTo-AstraLedgerText "Fresh-session retry $RetriesUsed of $MaxRetries (receipt $leaf) for origin $x completed with exit 0. Same-actor retry, not an independent verifier."
        $b = @('--execution-id', $x, '--correlation-id', $x, '--outcome', 'success', '--summary', $sum,
               '--receipt-ref', (Get-AstraFileRef (Join-Path $ReceiptDir 'codex-events.jsonl')), '--evidence-role', 'receipt', '--idempotency-key', "evidence:${x}:retry$RetriesUsed-success")
        return (Invoke-AstraLedger 'issue_ledger_actions.py' 'attach-evidence' $b $ReceiptDir)
    } catch { return "WARNING $($_.Exception.Message)" }
}

# ---------------- fresh-session launch ----------------

function Invoke-AstraFreshRetryLaunch {
    # Starts launch-astra.ps1 as a child process in the pre-allocated receipt and waits for it (no timeout).
    # Returns the child's exit code (the child runs its own chain for later attempts).
    param([string]$PromptFile, [string]$ReceiptStamp, [int]$Attempt, [string]$OriginReceiptDir,
          [string]$WorkingDirectory, [string]$ReceiptRoot, [string]$TaskId, [string]$Topology)
    $psExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $argv = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $script:AstraLaunchScript,
              '-PromptFile', $PromptFile, '-WorkingDirectory', $WorkingDirectory, '-ReceiptRoot', $ReceiptRoot,
              '-TaskId', $TaskId, '-Topology', $Topology, '-ReceiptStamp', $ReceiptStamp,
              '-Retry11133Attempt', "$Attempt", '-Retry11133OriginReceipt', $OriginReceiptDir)
    if ($env:ASTRA_RETRY_LAUNCH_DRYRUN -eq '1') {
        [System.IO.File]::WriteAllText((Join-Path (Join-Path $ReceiptRoot $ReceiptStamp) 'launch-command.txt'), "$psExe " + ($argv -join ' ') + [Environment]::NewLine)
        return 1
    }
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $psExe @argv 2>&1 | Out-Null
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    return $code
}

function Invoke-Astra11133RetryChain {
    # Call after a codex exec finished. Returns the final exit code (of this run, or of the fresh retry chain).
    # Backward compatible with the v1 call (no -RetriesUsed/-OriginReceiptDir => first launch of a chain).
    param(
        [string]$CodexExe,
        [string[]]$ProviderConfigArgs,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory,
        [Parameter(Mandatory = $true)][string]$ReceiptRoot,
        [Parameter(Mandatory = $true)][string]$FailedReceiptDir,
        $ExitCode,
        [string]$Model = 'cb/gpt-6-astra',
        [string]$TaskId = 'pcm-astra-owner',
        [string]$Topology = 'main',
        [int]$MaxRetries = 2,
        [int]$RetriesUsed = 0,
        [string]$OriginReceiptDir = ''
    )
    if (-not $OriginReceiptDir) { $OriginReceiptDir = $FailedReceiptDir }
    $originLeaf = Split-Path $OriginReceiptDir -Leaf
    if ($null -ne $ExitCode -and "$ExitCode" -eq '0') {
        if ($RetriesUsed -gt 0) {
            $ls = Write-Astra11133LedgerSuccess -ReceiptDir $FailedReceiptDir -OriginReceiptDir $OriginReceiptDir -RetriesUsed $RetriesUsed -MaxRetries $MaxRetries
            Write-AstraRetryNote $FailedReceiptDir @("## Retry outcome $(Get-AstraUtcNow)", '', '- exit_code: 0', "- outcome: success (fresh-session retry $RetriesUsed of $MaxRetries completed)", "- origin_receipt: $originLeaf", "- ledger: $ls")
        }
        return $ExitCode
    }
    $info = Get-AstraEventsFailureInfo -EventsPath (Join-Path $FailedReceiptDir 'codex-events.jsonl')
    $decision = Get-Astra11133RetryDecision -Info $info -ExitCode $ExitCode -RetriesUsed $RetriesUsed -MaxRetries $MaxRetries
    $note = @(
        "## Retry decision $(Get-AstraUtcNow)"
        ''
        "- exit_code: $ExitCode"
        "- final_event: $($info.FinalEventType)"
        "- thread_id: $($info.ThreadId)"
        "- is_11133: $($info.Is11133)"
        "- mode: fresh-session"
        "- origin_receipt: $originLeaf"
        "- retries_used_before_decision: $RetriesUsed of $MaxRetries"
    )
    if ($info.Is11133) { $note += "- inferhub_request_id: $($info.RequestId)"; $note += "- request_shape: $($info.Shape)" }
    if ($info.Is11133 -or $RetriesUsed -gt 0) {
        $ledger = Write-Astra11133Ledger -Info $info -ReceiptDir $FailedReceiptDir -OriginReceiptDir $OriginReceiptDir -RetriesUsed $RetriesUsed -MaxRetries $MaxRetries -Decision $decision -ExitCode $ExitCode
        $note += "- ledger: $ledger"
    }
    if (-not $decision.Retry) {
        Write-AstraRetryNote $FailedReceiptDir ($note + "- decision: NO RETRY - $($decision.Reason). Launcher exits with code $ExitCode as before.")
        return $ExitCode
    }
    $attempt = $RetriesUsed + 1
    try {
        $receipt = New-AstraRetryReceiptDir -ReceiptRoot $ReceiptRoot
        $kind = Get-AstraReceiptKind $FailedReceiptDir
        $prompt = New-Astra11133HandoffPrompt -FailedReceiptDir $FailedReceiptDir -FailedThreadId $info.ThreadId -FailedKind $kind -Attempt $attempt -MaxRetries $MaxRetries -OriginReceiptDir $OriginReceiptDir -FailedAtUtc $info.FailedAtUtc
    } catch {
        Write-AstraRetryNote $FailedReceiptDir ($note + "- decision: NO RETRY - could not prepare fresh-session retry: $($_.Exception.Message). Launcher exits with code $ExitCode as before.")
        return $ExitCode
    }
    $failedLeaf = Split-Path $FailedReceiptDir -Leaf
    Write-AstraRetryNote $FailedReceiptDir ($note + @(
        "- decision: RETRY $attempt of $MaxRetries - fresh session via launch-astra.ps1 in new receipt $($receipt.Stamp)"
        "- handoff_prompt: $prompt"
        "- previous_thread_not_resumed: $($info.ThreadId)"
    ))
    $attemptLines = @(
        'action=codex-exec-fresh-retry11133'
        'mode=fresh-session'
        "reason=auto-retry after InferHub model_param_invalid code 11133"
        "retry_attempt=$attempt of $MaxRetries"
        "previous_receipt=$failedLeaf"
        "previous_thread=$($info.ThreadId)"
        "origin_receipt=$originLeaf"
        "model=$Model"
        "working_directory=$WorkingDirectory"
        "prompt_file=$prompt"
        "started_utc=$($receipt.Stamp)"
        "parent_launcher_pid=$PID"
    )
    [System.IO.File]::WriteAllText((Join-Path $receipt.Dir 'attempt.txt'), ($attemptLines -join [Environment]::NewLine) + [Environment]::NewLine)
    Write-AstraRetryNote $receipt.Dir @(
        "# Auto-retry $attempt of $MaxRetries after InferHub code 11133"
        ''
        '- mode: fresh-session'
        "- previous_receipt: $failedLeaf"
        "- previous_thread: $($info.ThreadId) (not resumed)"
        "- origin_receipt: $originLeaf (first launch of this chain)"
        "- model: $Model"
        "- started_utc: $($receipt.Stamp)"
        "- handoff_prompt: $prompt"
        "- policy: launcher fresh-session retry on 11133 only, max $MaxRetries per original launch (approved by Alex 2026-09-24)"
    )
    try {
        $code = Invoke-AstraFreshRetryLaunch -PromptFile $prompt -ReceiptStamp $receipt.Stamp -Attempt $attempt -OriginReceiptDir $OriginReceiptDir `
            -WorkingDirectory $WorkingDirectory -ReceiptRoot $ReceiptRoot -TaskId $TaskId -Topology $Topology
        return @($code)[-1]
    } catch {
        Write-AstraRetryNote $receipt.Dir @("fresh-session launch error (no further retry): $($_.Exception.Message)")
        return $ExitCode
    }
}
