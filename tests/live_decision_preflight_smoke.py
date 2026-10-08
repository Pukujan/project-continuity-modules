"""Opt-in read-only live GitHub transport smoke, not an agent/semantic holdout.

Run with GITHUB_TOKEN/ GH_TOKEN and internet access. No GitHub mutations.
The expectation is generated from the just-fetched issue purely to verify the
wire path; this is NOT proof that an agent reviewed a long-running task plan.
"""
from __future__ import annotations

import json
import os
import sys

from continuity.decision_preflight import check_live, live_get

REPOSITORY = "Pukujan/project-continuity-modules"
ISSUE = 53  # long-closed historical PCM issue; don't mutate it for verification.


def main() -> int:
    token = os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    try:
        live = live_get(f"/repos/{REPOSITORY}/issues/{ISSUE}", token)
    except Exception as exc:
        print(f"UNVERIFIED: cannot read live issue ({type(exc).__name__})", file=sys.stderr)
        return 3
    if (live.get("number") != ISSUE or live.get("state") not in ("open", "closed")
            or not isinstance(live.get("updated_at"), str)):
        print("UNVERIFIED: invalid live issue shape", file=sys.stderr)
        return 3
    base = {
        "schema": "pcm.decision-precondition.v1",
        "repository": REPOSITORY,
        "issue_number": ISSUE,
        "task_id": "PCM-0070",
        "expected_issue_state": live["state"],
        "expected_issue_updated_at": live["updated_at"],
    }

    matching = check_live(base, token)
    if matching["status"] == "REVIEW_REQUIRED":
        # A real concurrent issue edit makes an initially observed revision stale.
        # This is not a false-green, but means the smoke did not measure a stable snapshot.
        print(json.dumps({"status": "INCONCLUSIVE", "reason": "live issue changed between reads"}))
        return 4
    if matching["status"] != "CURRENT":
        print(json.dumps({"status": "FAIL", "case": "matching live snapshot", "got": matching}))
        return 1

    wrong_state = dict(base, expected_issue_state=("closed" if live["state"] == "open" else "open"))
    stale = check_live(wrong_state, token)
    old_revision = dict(base, expected_issue_updated_at="2000-01-01T00:00:00Z")
    changed = check_live(old_revision, token)
    missing = dict(base, issue_number=999999999)
    unknown = check_live(missing, token)

    cases = {
        "matching_live_source": matching["status"],
        "wrong_lifecycle": stale["status"],
        "outdated_revision": changed["status"],
        "missing_issue": unknown["status"],
    }
    print(json.dumps({"issue": ISSUE, "repo": REPOSITORY, "statuses": cases}, sort_keys=True))
    expected = {
        "matching_live_source": "CURRENT",
        "wrong_lifecycle": "STALE",
        "outdated_revision": "REVIEW_REQUIRED",
        "missing_issue": "UNKNOWN",
    }
    return 0 if cases == expected else 1


if __name__ == "__main__":
    raise SystemExit(main())
