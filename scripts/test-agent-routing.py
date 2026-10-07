"""Mutation controls for instruction regrowth and broken navigation."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("routing", Path(__file__).with_name("check-agent-routing.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class RoutingControls(unittest.TestCase):
    def fixture(self, root):
        (root / "docs").mkdir()
        (root / "AGENTS.md").write_text("# Router\n\n- Task: read [workflow](docs/agent-workflow.md#delivery).\n")
        (root / "CODING_STANDARDS.md").write_text("# Criteria\n")
        (root / "docs/agent-workflow.md").write_text("# Workflow\n\n## Delivery\n")
        (root / "docs/next-core-checkpoint.md").write_text("# Navigation\n")

    def test_mutations(self):
        mutations = ("\nUnlinked instructions.\n", "\n- Read [issue #42 approved](CODING_STANDARDS.md).\n",
                     "\n- Read [2026-10-07](CODING_STANDARDS.md).\n",
                     "\n- Read [" + "a" * 40 + "](CODING_STANDARDS.md).\n",
                     "\n- " + "word " * 100 + "[criteria](CODING_STANDARDS.md).\n",
                     "\n" * 13,
                     "\n- Read [missing](missing.md).\n",
                     "\n- Read [missing heading](docs/agent-workflow.md#absent).\n")
        for addition in mutations:
            with self.subTest(addition=addition), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                self.fixture(root)
                self.assertEqual(module.check(root), [])
                path = root / "AGENTS.md"
                path.write_text(path.read_text() + addition)
                self.assertTrue(module.check(root))


if __name__ == "__main__":
    unittest.main()
