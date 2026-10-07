import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import selected_reference as reference


class Selection(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.entry = self.root / "reference-v3.mjs"
        self.entry.write_text("successful comparator\n")
        self.manifest = self.root / "delivery-manifest.json"
        self.manifest.write_text(json.dumps({"files": {
            self.entry.name: hashlib.sha256(self.entry.read_bytes()).hexdigest()
        }}))

    def test_selected_source_and_binding(self):
        expected = reference.binding(self.root, self.manifest, self.entry.name)
        self.assertEqual(reference.verify(self.root, expected), expected)

    def test_old_adapter_rejected_even_with_identical_bytes(self):
        old = self.root / "reference.mjs"
        old.write_bytes(self.entry.read_bytes())
        with self.assertRaisesRegex(RuntimeError, "not selected"):
            reference.binding(self.root, self.manifest, old.name)

    def test_changed_source_rejected(self):
        self.entry.write_text("changed comparator\n")
        with self.assertRaisesRegex(RuntimeError, "bytes changed"):
            reference.binding(self.root, self.manifest, self.entry.name)

    def test_unselected_symlink_alias_rejected(self):
        (self.root / "reference.mjs").symlink_to(self.entry)
        with self.assertRaisesRegex(RuntimeError, "not selected"):
            reference.binding(self.root, self.manifest, "reference.mjs")

    def test_selected_symlink_alias_rejected(self):
        alias = self.root / "selected-alias.mjs"
        alias.symlink_to(self.entry)
        selected = json.loads(self.manifest.read_text())
        selected["files"][alias.name] = selected["files"][self.entry.name]
        self.manifest.write_text(json.dumps(selected))
        with self.assertRaisesRegex(RuntimeError, "path alias"):
            reference.binding(self.root, self.manifest, alias.name)

    def test_manifest_reselection_rejected(self):
        expected = reference.binding(self.root, self.manifest, self.entry.name)
        self.manifest.write_text(self.manifest.read_text() + "\n")
        with self.assertRaisesRegex(RuntimeError, "binding changed"):
            reference.verify(self.root, expected)

    def test_manifest_changed_during_read_binds_original_snapshot(self):
        original = self.manifest.read_bytes()
        read_bytes = Path.read_bytes

        def replacing_read(path):
            contents = read_bytes(path)
            if path == self.manifest:
                self.manifest.write_bytes(contents + b"\n")
            return contents

        with mock.patch.object(Path, "read_bytes", replacing_read):
            expected = reference.binding(self.root, self.manifest, self.entry.name)
        self.assertEqual(expected["manifestSHA256"],
                         hashlib.sha256(original).hexdigest())
        with self.assertRaisesRegex(RuntimeError, "binding changed"):
            reference.verify(self.root, expected)

    def test_outside_root_rejected(self):
        with self.assertRaisesRegex(RuntimeError, "outside"):
            reference.binding(self.root, self.manifest, "../other.mjs")


if __name__ == "__main__":
    unittest.main()
