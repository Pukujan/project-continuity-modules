from __future__ import annotations

import json
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

from continuity.cli import (
    checkpoint_task,
    extract_marker,
    init_repo,
    pack_task,
    preflight_repo,
    task_new,
    validate_repo,
)

FIXTURES = Path(__file__).parent / "fixtures"


class ContinuityTests(unittest.TestCase):
    def copy_fixture(self, name: str) -> Path:
        tmp = Path(tempfile.mkdtemp(prefix="continuity-test-"))
        self.addCleanup(shutil.rmtree, tmp, True)
        shutil.copytree(FIXTURES / name, tmp, dirs_exist_ok=True)
        return tmp

    def test_valid_fixture(self) -> None:
        root = self.copy_fixture("valid-minimal")
        self.assertEqual(validate_repo(root), [])

    def test_broken_fixture_reports_missing_current(self) -> None:
        root = self.copy_fixture("broken-missing-current")
        errors = validate_repo(root)
        self.assertTrue(any("missing canonical current" in error for error in errors), errors)

    def test_init_nonempty_unrelated_repo_is_non_destructive(self) -> None:
        root = Path(tempfile.mkdtemp(prefix="continuity-init-"))
        self.addCleanup(shutil.rmtree, root, True)
        (root / "notes.txt").write_text("keep me\n", encoding="utf-8")
        results = init_repo(root, "minimal", "Example", "PCM")
        self.assertEqual((root / "notes.txt").read_text(encoding="utf-8"), "keep me\n")
        self.assertTrue(any(line.endswith("PROJECT.md") for line in results))
        self.assertEqual(validate_repo(root), [])

    def test_init_refuses_conflicting_existing_content_before_writes(self) -> None:
        root = Path(tempfile.mkdtemp(prefix="continuity-conflict-"))
        self.addCleanup(shutil.rmtree, root, True)
        (root / "PROJECT.md").write_text("user content\n", encoding="utf-8")
        with self.assertRaisesRegex(Exception, "initialization conflicts"):
            init_repo(root, "minimal", "Example", "PCM")
        self.assertFalse((root / ".continuity" / "config.json").exists())
        self.assertEqual((root / "PROJECT.md").read_text(encoding="utf-8"), "user content\n")

    def test_preflight_accepts_explicit_valid_target(self) -> None:
        root = Path(tempfile.mkdtemp(prefix="continuity-preflight-target-"))
        self.addCleanup(shutil.rmtree, root, True)
        init_repo(root, "minimal", "Inference Recommendation Engine", "IRE")
        mode, errors = preflight_repo(root)
        self.assertEqual(mode, "TARGET_VALID")
        self.assertEqual(errors, [])

    def test_preflight_rejects_pcm_helper_as_target(self) -> None:
        root = Path(tempfile.mkdtemp(prefix="continuity-preflight-helper-"))
        self.addCleanup(shutil.rmtree, root, True)
        init_repo(root, "minimal", "Project Continuity Modules", "PCM")
        mode, errors = preflight_repo(root)
        self.assertEqual(mode, "HELPER_REPOSITORY")
        self.assertTrue(any("helper repository" in error for error in errors), errors)

    def test_preflight_rejects_continuity_looking_but_invalid_target(self) -> None:
        root = Path(tempfile.mkdtemp(prefix="continuity-preflight-invalid-"))
        self.addCleanup(shutil.rmtree, root, True)
        (root / ".continuity").mkdir(parents=True)
        (root / ".continuity" / "config.json").write_text(
            json.dumps({
                "protocolVersion": "0.1.0",
                "projectName": "inference-recommendation-engine",
                "taskPrefix": "IRE",
                "activeTask": "IRE-0001",
            }),
            encoding="utf-8",
        )
        mode, errors = preflight_repo(root)
        self.assertEqual(mode, "INVALID_TARGET")
        self.assertTrue(errors)

    def test_task_new_allocates_stable_next_id(self) -> None:
        root = self.copy_fixture("valid-minimal")
        path = task_new(root, "second task", "Do the second thing.", "Exercise ID allocation.", "agent", "P1")
        self.assertEqual(path.name, "TASK-PCM-0002-second-task.md")
        meta = extract_marker(path.read_text(encoding="utf-8"), "task")
        self.assertEqual(meta["id"], "PCM-0002")

    def test_checkpoint_preserves_existing_history_and_adds_marker(self) -> None:
        root = self.copy_fixture("valid-minimal")
        task = root / "tasks" / "TASK-PCM-0001-example.md"
        original = task.read_text(encoding="utf-8")
        path = checkpoint_task(
            root,
            "PCM-0001",
            "test-agent",
            "2026-09-20T18:00:00Z",
            ["implemented fixture"],
            ["python -m unittest -> pass"],
            ["use append-only checkpoints"],
            ["tests/test_cli.py"],
            [],
            "run validation",
        )
        updated = path.read_text(encoding="utf-8")
        self.assertIn(original.split("## Handoff", 1)[0].rstrip(), updated)
        self.assertIn("continuity:checkpoint", updated)
        self.assertIn("implemented fixture", updated)
        self.assertEqual(validate_repo(root), [])

    def test_pack_records_git_provenance_and_sources(self) -> None:
        root = self.copy_fixture("valid-minimal")
        subprocess.run(["git", "init", "-q", root], check=True)
        subprocess.run(["git", "-C", root, "config", "user.email", "fixture@example.invalid"], check=True)
        subprocess.run(["git", "-C", root, "config", "user.name", "Fixture"], check=True)
        subprocess.run(["git", "-C", root, "add", "."], check=True)
        subprocess.run(["git", "-C", root, "commit", "-qm", "fixture"], check=True)
        subprocess.run(["git", "-C", root, "remote", "add", "origin", "https://example.invalid/fixture.git"], check=True)
        output = pack_task(root, "PCM-0001", None)
        meta = extract_marker(output.read_text(encoding="utf-8"), "context-pack")
        self.assertEqual(meta["repository"], "https://example.invalid/fixture.git")
        self.assertNotEqual(meta["commit"], "unknown")
        self.assertIn("PROJECT.md", meta["sources"])
        self.assertEqual(validate_repo(root), [])

    def test_minimal_end_to_end_dogfood_flow(self) -> None:
        root = Path(tempfile.mkdtemp(prefix="continuity-e2e-"))
        self.addCleanup(shutil.rmtree, root, True)

        init_repo(root, "minimal", "Dogfood", "DOG")
        self.assertEqual(validate_repo(root), [])

        task = task_new(
            root,
            "first dogfood task",
            "Exercise the initialized minimal repository.",
            "Verify the v1 commands compose end to end.",
            "dogfood-agent",
            "P0",
        )
        self.assertEqual(task.name, "TASK-DOG-0001-first-dogfood-task.md")
        self.assertEqual(validate_repo(root), [])

        original = task.read_text(encoding="utf-8")
        checkpoint_task(
            root,
            "DOG-0001",
            "dogfood-agent",
            "2026-09-20T18:35:00Z",
            ["initialized and validated the minimal repository"],
            ["init and validate returned success"],
            ["keep the minimal profile dependency-free"],
            ["tasks/TASK-DOG-0001-first-dogfood-task.md"],
            [],
            "generate a provenance-bearing context pack",
        )
        updated = task.read_text(encoding="utf-8")
        self.assertIn(original.split("## Handoff", 1)[0].rstrip(), updated)
        self.assertIn("continuity:checkpoint", updated)
        self.assertEqual(validate_repo(root), [])

        subprocess.run(["git", "init", "-q", root], check=True)
        subprocess.run(["git", "-C", root, "config", "user.email", "dogfood@example.invalid"], check=True)
        subprocess.run(["git", "-C", root, "config", "user.name", "PCM Dogfood"], check=True)
        subprocess.run(["git", "-C", root, "add", "."], check=True)
        subprocess.run(["git", "-C", root, "commit", "-qm", "dogfood source state"], check=True)
        subprocess.run(["git", "-C", root, "remote", "add", "origin", "https://example.invalid/pcm-minimal-dogfood.git"], check=True)

        output = pack_task(root, "DOG-0001", None)
        meta = extract_marker(output.read_text(encoding="utf-8"), "context-pack")
        self.assertEqual(meta["repository"], "https://example.invalid/pcm-minimal-dogfood.git")
        self.assertEqual(meta["task_id"], "DOG-0001")
        self.assertNotEqual(meta["commit"], "unknown")
        self.assertIn("PROJECT.md", meta["sources"])
        self.assertIn("checkpoints/CURRENT.md", meta["sources"])
        self.assertIn("tasks/TASK-DOG-0001-first-dogfood-task.md", meta["sources"])
        self.assertEqual(validate_repo(root), [])


if __name__ == "__main__":
    unittest.main()
