from __future__ import annotations

import json
import unittest

from continuity.cli import (
    ContinuityError,
    ReceiptComment,
    classify_receipt_failure,
    decide_receipt_retry,
    deliver_leaf_then_parent,
    reject_receipt_secrets,
    require_issue_identity,
)

MARKER = "merge:acceptance"
PAYLOAD = "a" * 64
OTHER = "b" * 64


class ReceiptAcceptanceTests(unittest.TestCase):
    def test_push_failure_does_not_post_a_receipt(self) -> None:
        calls: list[str] = []

        def leaf() -> str:
            raise ContinuityError("push failed")

        def parent() -> str:
            calls.append("parent")
            return "parent"

        with self.assertRaises(ContinuityError):
            deliver_leaf_then_parent(leaf, parent)
        self.assertEqual(calls, [])

    def test_lost_response_with_incomplete_lookup_does_not_post(self) -> None:
        with self.assertRaises(ContinuityError):
            decide_receipt_retry([], MARKER, PAYLOAD, lookup_complete=False)

    def test_duplicate_marker_stops(self) -> None:
        comments = [ReceiptComment(MARKER, PAYLOAD), ReceiptComment(MARKER, PAYLOAD)]
        with self.assertRaises(ContinuityError):
            decide_receipt_retry(comments, MARKER, PAYLOAD, lookup_complete=True)

    def test_changed_payload_fails(self) -> None:
        comments = [ReceiptComment(MARKER, OTHER)]
        with self.assertRaises(ContinuityError):
            decide_receipt_retry(comments, MARKER, PAYLOAD, lookup_complete=True)

    def test_wrong_issue_is_rejected(self) -> None:
        payload = json.dumps({"number": 15, "title": "PCM-0026", "body": ""})
        with self.assertRaises(ContinuityError):
            require_issue_identity(payload, issue_number="67", task_id="PCM-0026")

    def test_parent_partial_failure_keeps_the_leaf(self) -> None:
        def leaf() -> str:
            return "leaf"

        def parent() -> str:
            raise ContinuityError("parent permission denied")

        with self.assertRaises(ContinuityError) as caught:
            deliver_leaf_then_parent(leaf, parent)
        self.assertIn("leaf receipt stands", str(caught.exception))

    def test_permission_failure_is_named(self) -> None:
        self.assertEqual(classify_receipt_failure("HTTP 403 Forbidden"), "permission")

    def test_secret_body_is_refused(self) -> None:
        with self.assertRaises(ContinuityError):
            reject_receipt_secrets("ghp_example")


if __name__ == "__main__":
    unittest.main()
