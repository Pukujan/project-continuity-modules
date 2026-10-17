"""Read-only, fail-closed GitHub issue/decision revision preflight.

This is optimistic concurrency control for plans, NOT a semantic truth grader,
workflow authority, or owner approval system. The task records the issue and
optional decision comment it planned against. We compare those against live
GitHub before consequential work. Any update requires human/agent reconciliation.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen

SCHEMA = "pcm.decision-precondition.v1"
REPO_RE = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")
TASK_RE = re.compile(r"^[A-Z][A-Z0-9]*-[0-9]{4}$")
TIME_RE = re.compile(r"^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ$")
DIGEST_RE = re.compile(r"^[a-f0-9]{64}$")
DECISION_RE = re.compile(r"<!--\s*pcm:decision\s+([^\n>]*?)\s*-->")

# Code 0 is reserved for CURRENT. No network/API uncertainty can return it.
EXIT_OK = 0
EXIT_REVIEW = 2
EXIT_UNAVAILABLE = 3


def validate_expectation(record: Any) -> list[str]:
    if not isinstance(record, dict):
        return ["Precondition must be a JSON object"]
    required = ("schema", "repository", "issue_number", "task_id",
                "expected_issue_state", "expected_issue_updated_at")
    errors = [f"Missing {key}" for key in required if key not in record]
    if errors:
        return errors
    allowed = set(required) | {
        "decision_comment_id", "decision_id", "decision_body_sha256"
    }
    if set(record) - allowed:
        errors.append("Unexpected keys: " + ", ".join(sorted(set(record) - allowed)))
    if record["schema"] != SCHEMA:
        errors.append("Unknown precondition schema")
    if not isinstance(record["repository"], str) or not REPO_RE.fullmatch(record["repository"]):
        errors.append("repository must be owner/name")
    if type(record["issue_number"]) is not int or record["issue_number"] < 1:
        errors.append("issue_number must be positive integer")
    if not isinstance(record["task_id"], str) or not TASK_RE.fullmatch(record["task_id"]):
        errors.append("task_id must have form PCM-0001")
    if record["expected_issue_state"] not in ("open", "closed"):
        errors.append("expected_issue_state must be open or closed")
    if (not isinstance(record["expected_issue_updated_at"], str)
            or not TIME_RE.fullmatch(record["expected_issue_updated_at"])):
        errors.append("expected_issue_updated_at must be GitHub UTC ISO timestamp")
    extra = ("decision_comment_id", "decision_id", "decision_body_sha256")
    has_any = any(key in record for key in extra)
    if has_any and not all(key in record for key in extra):
        errors.append("decision comment id, decision id and body SHA256 are all required together")
    if all(key in record for key in extra):
        if type(record["decision_comment_id"]) is not int or record["decision_comment_id"] < 1:
            errors.append("decision_comment_id must be positive integer")
        if (not isinstance(record["decision_id"], str)
                or not re.fullmatch(r"[a-zA-Z0-9._-]{2,128}", record["decision_id"])):
            errors.append("decision_id is invalid")
        if (not isinstance(record["decision_body_sha256"], str)
                or not DIGEST_RE.fullmatch(record["decision_body_sha256"])):
            errors.append("decision_body_sha256 must be lowercase 64-character SHA256")
    return errors


def _result(state: str, reason: str, record: dict[str, Any],
            issue: dict[str, Any] | None = None) -> dict[str, Any]:
    return {
        "schema": "pcm.decision-preflight-result.v1",
        "status": state,
        "reason": reason,
        "repository": record.get("repository"),
        "issue_number": record.get("issue_number"),
        "task_id": record.get("task_id"),
        "expected_revision": record.get("expected_issue_updated_at"),
        "observed_revision": issue.get("updated_at") if isinstance(issue, dict) else None,
        "meaning": "Checks live revision agreement, not semantic truth or authorization",
    }


def evaluate(record: dict[str, Any], issue: Any,
             comment: Any = None) -> dict[str, Any]:
    """Pure comparison; source authenticity is established by caller's live fetch."""
    errors = validate_expectation(record)
    if errors:
        return _result("UNKNOWN", "; ".join(errors), record)
    if not isinstance(issue, dict):
        return _result("UNKNOWN", "Live issue response is not an object", record)
    repo = record["repository"]
    number = record["issue_number"]
    expected_url = f"https://api.github.com/repos/{repo}/issues/{number}"
    if (issue.get("url") != expected_url or issue.get("number") != number
            or "pull_request" in issue):
        return _result("UNKNOWN", "Issue identity mismatch or PR supplied", record, issue)
    if issue.get("state") not in ("open", "closed") or not isinstance(issue.get("updated_at"), str):
        return _result("UNKNOWN", "Live issue has incomplete state/revision", record, issue)
    if issue["state"] != record["expected_issue_state"]:
        return _result("STALE", "Live issue lifecycle differs from the planned state", record, issue)
    # Review any new issue/comment/label/description revision; do not infer
    # unrelated changes are safe. The human can refresh after inspection.
    if issue["updated_at"] != record["expected_issue_updated_at"]:
        return _result(
            "REVIEW_REQUIRED", "Owning issue changed since this plan; reconcile before action", record, issue
        )
    if "decision_comment_id" in record:
        if not isinstance(comment, dict):
            return _result("UNKNOWN", "Live decision comment could not be checked", record, issue)
        expected_comment_url = (
            f"https://api.github.com/repos/{repo}/issues/comments/"
            f"{record['decision_comment_id']}"
        )
        if (comment.get("url") != expected_comment_url
                or comment.get("issue_url") != expected_url
                or type(comment.get("id")) is not int
                or comment["id"] != record["decision_comment_id"]):
            return _result("UNKNOWN", "Decision comment identity mismatch", record, issue)
        body = comment.get("body")
        if not isinstance(body, str):
            return _result("UNKNOWN", "Missing decision comment body", record, issue)
        digest = hashlib.sha256(body.encode("utf-8")).hexdigest()
        if digest != record["decision_body_sha256"]:
            return _result("REVIEW_REQUIRED", "Decision comment body differs from recorded digest", record, issue)
        markers = DECISION_RE.findall(body)
        if record["decision_id"] not in markers:
            return _result("REVIEW_REQUIRED", "Expected decision marker missing or replaced", record, issue)
    return _result("CURRENT", "Live issue and referenced decision revision match the recorded plan", record, issue)


def live_get(path: str, token: str | None = None, timeout: int = 12) -> dict[str, Any]:
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "pcm-decision-preflight/0.1",
        "Cache-Control": "no-cache",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = Request("https://api.github.com" + path, headers=headers)
    with urlopen(request, timeout=timeout) as response:
        data = json.load(response)
    if not isinstance(data, dict):
        raise ValueError("Unexpected GitHub API response")
    return data


def check_live(record: dict[str, Any], token: str | None = None) -> dict[str, Any]:
    """Never treat a cached or caller-supplied fixture as live authority."""
    errors = validate_expectation(record)
    if errors:
        return _result("UNKNOWN", "; ".join(errors), record)
    repo = record["repository"]
    path = "/repos/" + "/".join(quote(v, safe="") for v in repo.split("/"))
    try:
        issue = live_get(f"{path}/issues/{record['issue_number']}", token)
        # Fetch the comment separately even if issue has already changed.
        # This avoids claiming a decision was checked when only issue metadata was.
        comment = None
        if "decision_comment_id" in record:
            comment = live_get(
                f"{path}/issues/comments/{record['decision_comment_id']}", token
            )
    except (HTTPError, URLError, OSError, ValueError, TimeoutError) as exc:
        # Do not expose auth token, response body, or local file paths.
        return _result("UNKNOWN", f"Live GitHub read failed ({type(exc).__name__}); do not proceed", record)
    return evaluate(record, issue, comment)


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Fail-closed live GitHub decision revision preflight")
    p.add_argument("--expect", type=Path, required=True, help="Versioned task precondition JSON")
    args = p.parse_args(argv)
    try:
        with args.expect.open(encoding="utf-8") as f:
            expected = json.load(f)
    except (OSError, ValueError):
        print(json.dumps({"status": "UNKNOWN", "reason": "Cannot read valid expectation JSON"}))
        return EXIT_UNAVAILABLE
    result = check_live(expected, os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN"))
    print(json.dumps(result, ensure_ascii=False, sort_keys=True))
    if result["status"] == "CURRENT":
        return EXIT_OK
    return EXIT_UNAVAILABLE if result["status"] == "UNKNOWN" else EXIT_REVIEW


if __name__ == "__main__":
    raise SystemExit(main())
