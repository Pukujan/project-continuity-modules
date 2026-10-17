"""A current decision is not necessarily a good one; only revision freshness is tested."""
from __future__ import annotations

import hashlib
import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
from urllib.error import URLError

from continuity.decision_preflight import (
    EXIT_OK,
    EXIT_REVIEW,
    EXIT_UNAVAILABLE,
    check_live,
    evaluate,
    main,
    validate_expectation,
)


def fixture() -> tuple[dict, dict, dict]:
    body = "<!-- pcm:decision decision-2026 -->\nOwner selected a bounded direction.\n"
    record = {
        "schema": "pcm.decision-precondition.v1",
        "repository": "Pukujan/project-continuity-modules",
        "issue_number": 144,
        "task_id": "PCM-0070",
        "expected_issue_state": "open",
        "expected_issue_updated_at": "2026-10-08T10:10:10Z",
        "decision_comment_id": 12345,
        "decision_id": "decision-2026",
        "decision_body_sha256": hashlib.sha256(body.encode("utf-8")).hexdigest(),
    }
    issue = {
        "url": "https://api.github.com/repos/Pukujan/project-continuity-modules/issues/144",
        "number": 144, "state": "open",
        "updated_at": "2026-10-08T10:10:10Z",
    }
    comment = {
        "id": 12345,
        "url": "https://api.github.com/repos/Pukujan/project-continuity-modules/issues/comments/12345",
        "issue_url": "https://api.github.com/repos/Pukujan/project-continuity-modules/issues/144",
        "body": body,
    }
    return record, issue, comment


class DecisionPreflightTests(unittest.TestCase):
    def test_live_matching_revision_is_current(self) -> None:
        record, issue, comment = fixture()
        with patch("continuity.decision_preflight.live_get", side_effect=[issue, comment]) as fetch:
            result = check_live(record)
        self.assertEqual("CURRENT", result["status"])
        self.assertEqual(2, fetch.call_count)

    def test_closed_issue_overrules_open_projection(self) -> None:
        record, issue, comment = fixture()
        issue["state"] = "closed"
        self.assertEqual("STALE", evaluate(record, issue, comment)["status"])

    def test_new_issue_comment_or_other_update_requires_review(self) -> None:
        record, issue, comment = fixture()
        issue["updated_at"] = "2026-10-08T10:10:11Z"
        self.assertEqual("REVIEW_REQUIRED", evaluate(record, issue, comment)["status"])

    def test_edited_decision_body_requires_review(self) -> None:
        record, issue, comment = fixture()
        comment["body"] += "Extra assertion\n"
        self.assertEqual("REVIEW_REQUIRED", evaluate(record, issue, comment)["status"])

    def test_matching_digest_without_decision_marker_is_insufficient(self) -> None:
        record, issue, comment = fixture()
        comment["body"] = "Plain prose with no recorded decision identity"
        record["decision_body_sha256"] = hashlib.sha256(comment["body"].encode("utf-8")).hexdigest()
        self.assertEqual("REVIEW_REQUIRED", evaluate(record, issue, comment)["status"])

    def test_comment_must_belong_to_the_same_issue(self) -> None:
        record, issue, comment = fixture()
        comment["issue_url"] = comment["issue_url"].replace("issues/144", "issues/145")
        self.assertEqual("UNKNOWN", evaluate(record, issue, comment)["status"])

    def test_issue_must_belong_to_exact_repo_and_number(self) -> None:
        record, issue, comment = fixture()
        issue["url"] = issue["url"].replace("issues/144", "issues/145")
        self.assertEqual("UNKNOWN", evaluate(record, issue, comment)["status"])

    def test_non_live_or_failed_live_fetch_is_never_green(self) -> None:
        record, _, _ = fixture()
        with patch("continuity.decision_preflight.live_get", side_effect=URLError("down")):
            result = check_live(record)
        self.assertEqual("UNKNOWN", result["status"])
        self.assertNotIn("down", result["reason"])

    def test_invalid_inputs_are_fail_closed(self) -> None:
        record, issue, comment = fixture()
        record["issue_number"] = True
        self.assertTrue(validate_expectation(record))
        self.assertEqual("UNKNOWN", evaluate(record, issue, comment)["status"])
        record, _, _ = fixture()
        record.pop("decision_body_sha256")
        self.assertTrue(validate_expectation(record))

    def test_issue_only_precondition_is_allowed_but_limited(self) -> None:
        record, issue, _ = fixture()
        for key in ("decision_comment_id", "decision_id", "decision_body_sha256"):
            record.pop(key)
        result = evaluate(record, issue)
        self.assertEqual("CURRENT", result["status"])
        self.assertIn("not semantic truth", result["meaning"])

    def test_full_json_api_read_transitions_at_same_plan_version(self) -> None:
        """Transport parsing + unchanged expectation, with fake remote mutations."""
        record, issue, comment = fixture()
        issue_url = issue["url"]
        comment_url = comment["url"]
        observed = {issue_url: issue, comment_url: comment}
        seen_urls = []

        def fake_urlopen(request, timeout=12):
            self.assertGreater(timeout, 0)
            seen_urls.append(request.full_url)
            return io.BytesIO(json.dumps(observed[request.full_url]).encode("utf-8"))

        with patch("continuity.decision_preflight.urlopen", side_effect=fake_urlopen):
            self.assertEqual("CURRENT", check_live(record)["status"])
            issue["updated_at"] = "2026-10-08T10:10:11Z"
            self.assertEqual("REVIEW_REQUIRED", check_live(record)["status"])
            issue["state"] = "closed"
            self.assertEqual("STALE", check_live(record)["status"])
            issue["state"] = "open"
            issue["updated_at"] = record["expected_issue_updated_at"]
            comment["body"] += "\nOwner rejected the prior assumption."
            self.assertEqual("REVIEW_REQUIRED", check_live(record)["status"])
        self.assertIn(issue_url, seen_urls)
        self.assertIn(comment_url, seen_urls)

    def test_command_status_codes_without_network(self) -> None:
        record, _, _ = fixture()
        with tempfile.TemporaryDirectory() as td:
            expectation = Path(td) / "precondition.json"
            expectation.write_text(json.dumps(record), encoding="utf-8")
            for status, expected_code in [
                ("CURRENT", EXIT_OK),
                ("REVIEW_REQUIRED", EXIT_REVIEW),
                ("STALE", EXIT_REVIEW),
                ("UNKNOWN", EXIT_UNAVAILABLE),
            ]:
                with (
                    patch("continuity.decision_preflight.check_live", return_value={"status": status}),
                    patch("sys.stdout", new_callable=io.StringIO) as output,
                ):
                    self.assertEqual(expected_code, main(["--expect", str(expectation)]))
                self.assertEqual(status, json.loads(output.getvalue())["status"])


if __name__ == "__main__":
    unittest.main()
