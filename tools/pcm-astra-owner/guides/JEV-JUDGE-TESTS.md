# JEV Judge Tests for PCM / Astra

Standing test-design guide for Astra (PCM owner): how to use TypeSafe **Jev** as a typed semantic/metamorphic/holdout judge without treating it as a chat model or as objective gold.

---

## Sources / Provenance

**Researched:** 2026-09-24 ET (America/New_York), by Grok Bot executor for Alex (PCM / Astra).

**Primary Eval Lab docs (read in full; claims below cite path + section):**

| Doc | Path (box mirror; prefer PC under `D:\claude\eval-lab\docs\` or `D:\claude\projects\eval-lab\docs\` when present) |
|---|---|
| Jev Research and Usage Audit | `docs/JEV_RESEARCH_AND_USAGE_AUDIT.md` |
| Jev Eval Lab Integration Contract | `docs/JEV_EVAL_LAB_INTEGRATION_CONTRACT.md` |
| TASK-0010 OpenRouter Jev Integration | `docs/TASK-0010-OPENROUTER-JEV.md` |
| Independent Jev Benchmark Audit (skim) | `docs/INDEPENDENT_JEV_BENCHMARK_AUDIT.md` |

Also consulted for PCM wiring (not JEV semantics): `D:\claude\_workspace\pcm-astra-owner\staff-goal.md`, `staff-runner\run-staff-task.ps1` (existence confirmed).

**OpenRouter key check (2026-09-24 ~8:31 PM ET):** Loaded `OPENROUTER_API_KEY` from `C:\Users\pujan\OneDrive\Desktop\configs\.env` into process env only (never printed). Free `GET https://openrouter.ai/api/v1/key` succeeded. Snapshot: `is_free_tier=false`, `limit=5` (USD), `limit_remaining≈2.68`, `usage≈2.32`, weekly usage ≈2.00. Label redacted.

**Verified live (same session):**

- Decisions endpoint path from contract: `POST https://openrouter.ai/api/alpha/decisions` ([JEV_EVAL_LAB_INTEGRATION_CONTRACT.md § Authorized access](#); [JEV_RESEARCH_AND_USAGE_AUDIT.md § OpenRouter route used by this repository](#)).
- Planning-time price from TASK-0010: `$0.042/M` input, output free ([TASK-0010-OPENROUTER-JEV.md](#)).
- Tiny Decisions smoke (trivial `choice` over {blue,green,red}): **HTTP 200**. Surfaced model `typesafe/jev-1.13-20260917`; answer `blue`; `confidence=1`; probabilities `{blue:1, green:0, red:0}`; usage `input_tokens=352`, `output_tokens=38`, **cost≈$0.000015**. No secrets logged.
- `GET /api/v1/models` (460 models): **`typesafe/jev-1.13` not listed** (Decisions-only SKU likely omitted from chat catalog).

**NOT verified / do not invent:**

- InferHub hosting of JEV (prefer if available; not confirmed in this pass).
- Live PCM `run-holdout.ps1` (planned; document contract only — do not invent script behavior).
- TypeSafe calibration claims against PCM holdout gold ([JEV_RESEARCH_AND_USAGE_AUDIT.md § Evidence limits](#); [INDEPENDENT_JEV_BENCHMARK_AUDIT.md](#)).
- Full enumeration of every optional OpenRouter Decisions response field beyond the Eval Lab contract (adapter must preserve `answers.<id>.probabilities` and `confidence` when present).

**Integrity:** Do not invent JEV behavior beyond these docs. App owns control flow. Never promote JEV output to objective gold ([JEV_EVAL_LAB_INTEGRATION_CONTRACT.md § Response contract](#)).

---

## 1. What JEV is

**Jev (TypeSafe / System One) is a typed decision service, not a chat model.** The caller supplies a `state` (string, JSON object, or array of text) and a closed set of typed `questions`. Jev returns typed answers plus probability information where the question type supports it. The application remains responsible for control flow, deterministic checks, side effects, thresholds, and escalation.

Citations:

- [JEV_RESEARCH_AND_USAGE_AUDIT.md § Executive findings](#) — “not a smaller chat model… typed decision service… state and a closed set of questions… typed answers plus probability information.”
- [JEV_RESEARCH_AND_USAGE_AUDIT.md § State and questions](#) — state shapes; questions in one request are independent and share state.
- [JEV_EVAL_LAB_INTEGRATION_CONTRACT.md § Request contract](#) — wire shape `model` + `state` + `questions` map.

**Authorized OpenRouter route (Eval Lab / PCM judges):** Decisions API, **not** Chat Completions:

```text
POST https://openrouter.ai/api/alpha/decisions
model: typesafe/jev-1.13          # pinned arm
model: ~typesafe/jev-latest       # rolling canary — keep separate
```

Citations: [JEV_EVAL_LAB_INTEGRATION_CONTRACT.md § Authorized access](#); [JEV_RESEARCH_AND_USAGE_AUDIT.md § OpenRouter route used by this repository](#); [TASK-0010-OPENROUTER-JEV.md](#) (pinned vs rolling; 32K context; planning price).

**Pattern (strongest integrations + Eval Lab):**

1. Compact structured observation → `state`
2. One narrow `choice` / `noul` / `score` question per judgment
3. Explicit mutually exclusive options
4. Validate answer, option membership, probability map
5. Ordinary code executes / retries / escalates

Citation: [JEV_RESEARCH_AND_USAGE_AUDIT.md § Executive findings](#) (numbered pattern); § Question design.

Jev returns a completed structured decision, not a text stream. Do not send `stream=true` or parse partial text ([JEV_EVAL_LAB_INTEGRATION_CONTRACT.md § Concurrency and streaming](#); [JEV_RESEARCH_AND_USAGE_AUDIT.md § OpenRouter route…](#)).

---

## 2. Decision + confidence scoring

### Primitives

| Primitive | Use | Native answer fields |
|---|---|---|
| `choice` | One option from a known **unordered** set | `choice`, full `probabilities`, `confidence` |
| `score` | One **ordered** rubric level | `score`, `legend`, full `probabilities`, `confidence` |
| `noul` | Clean yes/no statement | `noul` = probability of yes (**no separate confidence**) |

Citation: [JEV_RESEARCH_AND_USAGE_AUDIT.md § State and questions](#) table.

For PCM forced labels (pass/fail, A/B/TIE, metamorphic hold/break), prefer **`choice`** with descriptive `criteria` for every option — not `noul` when you need a named label and a legal probability map ([same §](#); [JEV_EVAL_LAB_INTEGRATION_CONTRACT.md § Request contract](#) example).

### Confidence ≠ correctness

TypeSafe `confidence` is a **statistic derived from the answer’s probability distribution**. It is **not** a proof, an objective label, or a guarantee that an individual prediction is correct. Retain the native distribution; measure calibration against held-out objective gold. For `noul`, the returned number is P(yes) only.

Citation: [JEV_RESEARCH_AND_USAGE_AUDIT.md § Confidence is not correctness](#).

### Adapter must

- Require a legal typed choice (reject out-of-set / malformed as parse/execution failure — no fabricated label)
- Preserve `answers.<question_id>.probabilities` and native `confidence` when present
- Preserve resolved model + usage/cost metadata when present
- **Never promote Jev output to objective gold**

Citation: [JEV_EVAL_LAB_INTEGRATION_CONTRACT.md § Response contract](#).

---

## 3. When to use JEV vs deterministic

| Check type | Gate | Tool |
|---|---|---|
| Mechanically checkable (exit codes, file diffs, schema, hashes, unit/property oracles, exact string/AST equality) | **Hard gate** — fail closed without JEV | Deterministic harness / pytest / property tests |
| Meaning, rubric judgment, metamorphic relation, semantic holdout | Soft/semantic gate **after** hard gates | JEV `choice` (or `score` if ordered levels are defined) |
| Arithmetic, counting, schema invention, free-text explanations | **Do not ask JEV** | Code |

Citations:

- [JEV_RESEARCH_AND_USAGE_AUDIT.md § Executive findings](#) — “A judge prompt should not ask Jev to write an explanation, count, perform arithmetic, or invent a schema… gold label remains the benchmark verifier… Jev’s answer is always a prediction.”
- [JEV_RESEARCH_AND_USAGE_AUDIT.md § Evidence limits](#) — “Jev cannot replace deterministic verifiers, executable tests, or answer keys.”
- IRE-style recommendations for PCM: hidden rubric; judge model family ≠ builder; abstain/uncertain = not pass; track judge agreement per route (apply as process rules below).

**Rule for Astra:** Deterministic checks are the hard gate wherever mechanically checkable. JEV is for **meaning** only, and never upgrades a failed hard gate.

---

## 4. How Astra writes a JEV-judged holdout

### Layout (harness-only)

```text
D:\claude\_workspace\pcm-astra-owner\holdout\TASK-NN\
  (artifacts the builder must never see)
  judge\          # rubrics, criteria, thresholds, calibration fixtures
  ...
```

- Holdouts live under `holdout\TASK-NN\` — **never** in the product repo and **never** in `inbox\TASK`.
- Staff (cheap InferHub builder via `staff-runner\run-staff-task.ps1`) reading holdout content = **reject / contamination**.
- Astra writes specs, success criteria, visible tests, TASK files, **and** hidden holdouts; Astra accepts. Staff builds until visible tests pass.

### Hidden rubric under `holdout\TASK-NN\judge\`

Recommended files (names illustrative; harness owns exact convention):

- `rubric.md` or `questions.json` — JEV `instructions` + `criteria` for each closed option
- `thresholds.json` — e.g. `{ "pass_choice": "pass", "min_confidence": 0.7, "min_agreement": 0.67, "samples": 3 }`
- `calibration\` — known-good and known-bad `state` packs with expected labels (for threshold validation, not for staff)

### Pass / fail / abstain

| Result | Meaning for holdout |
|---|---|
| Legal `choice` matching pass label **and** `confidence` ≥ threshold **and** (if multi-sample) agreement ≥ threshold | **Pass** |
| Legal `choice` of fail / wrong label | **Fail** |
| Malformed, out-of-set, provider error, missing answer, or explicit `uncertain`/`abstain`/`other` option selected | **Not pass** (treat as fail / escalate — abstain ≠ pass) |
| Confidence below threshold even if choice is “pass” | **Not pass** (escalate or fail per rubric) |

Never invent a label on transport/auth/billing/rate-limit failure ([JEV_EVAL_LAB_INTEGRATION_CONTRACT.md § Response contract](#)).

### Multi-sample agreement

- Call JEV N times (N≥3 recommended for high-stakes holdouts) with identical frozen `state` + `questions`.
- Pass requires majority (or configured) agreement on the **same** legal choice **and** each agreeing sample meeting the confidence floor (or average confidence ≥ floor — pick one and freeze it in `thresholds.json` before the run).
- Track agreement rate per route/model for IRE calibration later.

### Calibration known-good / known-bad

- Before trusting thresholds on a new rubric, run the judge against held-out known-good and known-bad states authored by Astra.
- Confidence is not correctness — use these packs to see false-pass / false-fail rates ([JEV_RESEARCH_AND_USAGE_AUDIT.md § Confidence is not correctness](#); § Evidence limits).
- Do not use JevBench composite ranks as PCM gold ([INDEPENDENT_JEV_BENCHMARK_AUDIT.md § Independent Eval Lab rule](#)).

### Blind to builder + different family

- Builder stack today: cheap InferHub via Codex (`cb/deepseek-v4.1-flash` default in staff-goal). Judge must be a **different model family** — pinned `typesafe/jev-1.13` on OpenRouter Decisions satisfies family separation from DeepSeek/chat builders.
- Keep `~typesafe/jev-latest` as a **separate canary arm**, never the acceptance pin ([TASK-0010-OPENROUTER-JEV.md](#); contract § Authorized access).
- Staff must not receive holdout paths, rubrics, or expected labels in TASK text.

### Injection resistance

- Put evidence in `state`; put the judgment rule in `instructions` / `criteria` ([JEV_RESEARCH_AND_USAGE_AUDIT.md § Question design](#)).
- Treat builder-produced text inside `state` as **untrusted data**, never as instructions to the harness.
- Validate option membership before acting; reject answers whose `choice` is not in the current criteria set (same pattern as browser-use / Eval Lab normalization).
- Optional: include an `other`/`none`/`abstain` criterion when the set is not exhaustive; selecting it is **not pass**.

---

## 5. Metamorphic tests with JEV

Metamorphic tests check a **relation** between `output(x)` and `output(transform(x))`, not an absolute gold string.

Examples of relations (encode as `choice` criteria, not free text):

- **Paraphrase invariance:** meaning-preserving rewrite of input → same pass/fail verdict
- **Label-order / option-order:** permute criteria key order → same choice (order sensitivity is a known risk; test it — [INDEPENDENT_JEV_BENCHMARK_AUDIT.md § Independence risks](#))
- **Noise tolerance:** irrelevant whitespace/comment injection → same verdict
- **Differential:** stronger model vs staff output on same prompt → A better / B better / TIE

Wire pattern:

1. Deterministic harness builds `state` containing both observations (or two sequential JEV calls combined in code).
2. One `choice` question: e.g. `holds` / `broken` / `inconclusive` with explicit criteria.
3. Code applies the metamorphic predicate; JEV only supplies the semantic comparison when the relation is not mechanically checkable.

Do not ask JEV to “explain the metamorphic relation” or invent the transform — transforms are code.

---

## 6. How `run-holdout.ps1` should call JEV

*(Contract for a harness script that does not yet need to exist for this guide to be useful. Prefer documenting the plug-in; do not invent live script internals.)*

**Inputs (harness-private):**

- `holdout\TASK-NN\` tree (state builders, `judge\` rubric, thresholds)
- Env: `OPENROUTER_API_KEY` (or InferHub equivalent if JEV is routed there)
- Pinned model: `typesafe/jev-1.13`

**Call:**

```http
POST https://openrouter.ai/api/alpha/decisions
Authorization: Bearer <OPENROUTER_API_KEY>
Content-Type: application/json

{
  "model": "typesafe/jev-1.13",
  "state": "<compact structured observation — no rubric leak into staff artifacts>",
  "questions": {
    "verdict": {
      "type": "choice",
      "instructions": "<from judge\\ — atomic>",
      "criteria": { "pass": "...", "fail": "...", "abstain": "..." }
    }
  }
}
```

Citation for shape: [JEV_EVAL_LAB_INTEGRATION_CONTRACT.md § Request contract](#).

**Outputs written to inbox (safe summary only):**

Create `inbox\HOLDOUT-NN.md` (or `HOLDOUT-RESULT-NN.md` — pick one convention and freeze it) containing at least:

- TASK id, timestamp (ET), harness execution id
- Model requested + surfaced model (if returned)
- Decision (`choice`), `confidence`, truncated probability map
- Multi-sample agreement fraction
- Pass/fail/abstain per thresholds
- Usage/cost if returned; route id (`openrouter:decisions` or `inferhub:jev`)
- **No** holdout fixture text, **no** hidden rubric, **no** known-good/bad packs, **no** expected labels

Staff may read `HOLDOUT-NN.md` as a scoreboard. Staff reading `holdout\` = process failure.

**Failure handling:** HTTP/auth/billing/rate-limit → record execution state, no fabricated verdict (contract § Response contract).

---

## 7. Cost rules

- Prefer **cheap** pinned JEV; record route + price every run.
- TASK-0010 planning observation: OpenRouter `typesafe/jev-1.13` ≈ **$0.042/M input, output free** ([TASK-0010-OPENROUTER-JEV.md](#)). Re-check price before large batches; do not assume forever.
- Prefer **InferHub** if/when JEV is available there at equal or lower effective cost and equal wire semantics; otherwise OpenRouter Decisions.
- Keep rolling `~typesafe/jev-latest` off the acceptance path (canary only).
- Batch carefully: Eval Lab currently sends one record per request; multi-question same-state is allowed by TypeSafe, multi-record batching is a separate experiment ([JEV_RESEARCH_AND_USAGE_AUDIT.md § Still intentionally separate](#)).
- Never print or commit API keys.

---

## 8. Worked PCM-style example (filled)

**Scenario:** Staff delivered a summary function. Visible unit tests pass. Astra’s hidden holdout checks that a paraphrased input summary is judged semantically equivalent (metamorphic invariance), which is not a string-equal check.

**`holdout\TASK-42\judge\thresholds.json`:**

```json
{
  "pass_choice": "holds",
  "min_confidence": 0.65,
  "samples": 3,
  "min_agreement": 0.67
}
```

**`holdout\TASK-42\judge\questions.json` (conceptual):**

```json
{
  "verdict": {
    "type": "choice",
    "instructions": "Decide whether the metamorphic relation holds for these two summaries of the same source.",
    "criteria": {
      "holds": "Both summaries preserve the same material facts; differences are wording only.",
      "broken": "At least one material fact was added, dropped, or contradicted.",
      "abstain": "Evidence is insufficient to decide."
    }
  }
}
```

**Harness-built `state` (never shown to staff):**

```text
Source facts: Alice paid $40 for lunch on Tuesday; Bob did not attend.
Summary A: Alice spent forty dollars on lunch Tuesday; Bob was absent.
Summary B: Alice paid $40 for lunch on Tuesday; Bob did not attend.
Relation under test: paraphrase_invariance
```

**JEV call:** pinned `typesafe/jev-1.13` → Decisions API; 3 samples.

**Example acceptance:** choices `[holds, holds, holds]`, confidences `[0.81, 0.77, 0.79]` → agreement 1.0 ≥ 0.67, min confidence ≥ 0.65 → **holdout pass**.

**`inbox\HOLDOUT-42.md` (staff-visible):**

```markdown
# HOLDOUT-42
execution_id: holdout-20260924T...
model_requested: typesafe/jev-1.13
route: openrouter:api/alpha/decisions
decision: holds
confidence_min: 0.77
agreement: 3/3
threshold_pass: true
result: PASS
cost_usd: <from usage if present>
# (no source facts, no summaries, no rubric text)
```

---

## 9. TASK template snippet (Astra fills every time)

Paste into the owner-side holdout checklist when releasing a JEV-judged TASK (keep this block **out** of staff TASK files):

```markdown
## JEV holdout checklist (Astra / harness only)
- [ ] Visible red tests + property tests written first; deterministic hard gates listed
- [ ] Holdout path: holdout\TASK-___\  (not in repo, not in inbox\TASK)
- [ ] judge\ rubric: instructions + criteria for every option (incl. abstain/other if needed)
- [ ] thresholds.json: pass_choice / min_confidence / samples / min_agreement frozen BEFORE run
- [ ] calibration: ≥1 known-good + ≥1 known-bad state packs
- [ ] Builder family ≠ judge family (judge = typesafe/jev-1.13 Decisions; not chat completions)
- [ ] Rolling ~typesafe/jev-latest not used for acceptance
- [ ] Metamorphic relation named (if any) and transform implemented in code
- [ ] run-holdout writes inbox\HOLDOUT-___.md with decision/confidence/cost only (no leak)
- [ ] Abstain / uncertain / parse_error / provider_error => NOT PASS
- [ ] Never promote JEV label to objective gold
```

Staff-facing TASK still only references visible tests and product paths.

---

## 10. Open questions

1. **InferHub JEV:** Is typed JEV (Decisions-equivalent) available on InferHub? If yes, prefer it for cost/routing when wire-compatible.
2. **Models catalog gap:** `typesafe/jev-1.13` was **not** in `GET /api/v1/models` (2026-09-24). Confirm whether that is expected for Decisions-only SKUs; do not use Chat Completions as a fallback ([contract § Authorized access — forbidden: Chat Completions for Jev](#)).
3. **`run-holdout.ps1`:** Not present in workspace at research time — implement against §6 without leaking holdout into staff-runner.
4. **Confidence threshold defaults:** Docs require local calibration; PCM still needs an initial conservative default + measurement plan (start high-abstain / fail-closed).
5. **Multi-question vs multi-request:** When to batch independent criteria in one Decisions request vs N calls (cost vs isolation) — Eval Lab left batching as future work.
6. **Option-order invariance:** Schedule explicit permutation tests on PCM rubrics ([INDEPENDENT_JEV_BENCHMARK_AUDIT.md](#)).
7. **Live smoke / pricing drift:** Re-verify Decisions availability and $/M before large holdout campaigns; TASK-0010 price is a planning snapshot.
8. **IRE ledger linkage:** After each holdout campaign, attach `HOLDOUT-NN.md` receipt refs to evaluation-class ledger reports (reports are never self-verified).

---

## Quick citation index

| Claim | Source |
|---|---|
| Typed decision service, not chat | `JEV_RESEARCH_AND_USAGE_AUDIT.md` § Executive findings |
| Primitives choice/score/noul | same § State and questions |
| Confidence ≠ correctness; noul has no separate confidence | same § Confidence is not correctness |
| POST `/api/alpha/decisions`; pinned `typesafe/jev-1.13`; canary `~typesafe/jev-latest` | `JEV_EVAL_LAB_INTEGRATION_CONTRACT.md` § Authorized access; `TASK-0010-OPENROUTER-JEV.md` |
| Never promote to gold; preserve probs/confidence | contract § Response contract |
| No streaming | contract § Concurrency and streaming |
| Price snapshot $0.042/M in, out free | `TASK-0010-OPENROUTER-JEV.md` |
| Independent gold ≠ JevBench composite | `INDEPENDENT_JEV_BENCHMARK_AUDIT.md` § Independent Eval Lab rule |
