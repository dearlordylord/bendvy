"""Controls for candidate-only adaptation of the exact archived #28 workload."""
import copy
import io
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import generational_fixture as adapter


ROOT = Path(__file__).resolve().parents[1]


class FixtureMigrationControls(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        archive = subprocess.check_output([
            'git', '-C', str(ROOT), 'archive', adapter.BASELINE_COMMIT,
            'examples/query-composition'])
        with tarfile.open(fileobj=io.BytesIO(archive)) as contents:
            cls.archived = {member.name: contents.extractfile(member).read()
                            for member in contents.getmembers() if member.isfile()}

    def stage(self, root, name='candidate'):
        stage = root / name
        for relative, body in self.archived.items():
            path = stage / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(body)
        return stage

    def bodies(self, stage):
        return {str(path.relative_to(stage)): path.read_bytes()
                for path in stage.rglob('*') if path.is_file()}

    def test_exact_candidate_edits_preserve_baseline_and_other_bytes(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            baseline = self.stage(root, 'baseline')
            candidate = self.stage(root)
            record = adapter.migrate_candidate(candidate, adapter.BASELINE_COMMIT)
            changed = self.bodies(candidate)
            self.assertEqual(self.bodies(baseline), self.archived)
            self.assertEqual(len(record['files']), 4)
            self.assertEqual(sum(row['replacements'] for row in record['files']), 5)
            for relative, original in self.archived.items():
                name = Path(relative).name
                if name not in adapter.REPLACEMENTS:
                    self.assertEqual(changed[relative], original)
                    continue
                restored = changed[relative].decode()
                for before, after in reversed(adapter.REPLACEMENTS[name]):
                    self.assertEqual(restored.count(after), 1)
                    restored = restored.replace(after, before)
                self.assertEqual(restored.encode(), original)
            self.assertIn(b'W.Handle{namespace,K.EntityKey{id,0}}',
                          changed['examples/query-composition/scenario-ops.bend'])
            self.assertIn(b'Ops.handle(namespace,2)',
                          changed['examples/query-composition/driver.bend'])
            self.assertIn(b'W.handle_index(~S.Schema,handle)',
                          changed['examples/query-composition/observe.bend'])

    def test_invalid_baseline_hash_membership_and_repeat_fail_before_writes(self):
        for mutation in ('baseline', 'hash', 'extra', 'missing', 'repeat'):
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory() as temporary:
                stage = self.stage(Path(temporary))
                workload = stage / 'examples/query-composition'
                commit = adapter.BASELINE_COMMIT
                if mutation == 'baseline':
                    commit = 'unexpected'
                elif mutation == 'hash':
                    path = workload / 'scenario-ops.bend'
                    path.write_bytes(path.read_bytes() + b'\n')
                elif mutation == 'extra':
                    (workload / 'custom.bend').write_text('custom')
                elif mutation == 'missing':
                    (workload / 'gameplay.bend').unlink()
                elif mutation == 'repeat':
                    adapter.migrate_candidate(stage, commit)
                before = self.bodies(stage)
                with self.assertRaises(ValueError):
                    adapter.migrate_candidate(stage, commit)
                self.assertEqual(self.bodies(stage), before)

    def test_wrong_transform_count_fails_before_any_write(self):
        replacements = copy.deepcopy(adapter.REPLACEMENTS)
        replacements['schema.bend'] = (('missing syntax', 'replacement'),)
        with tempfile.TemporaryDirectory() as temporary:
            stage = self.stage(Path(temporary))
            with patch.object(adapter, 'REPLACEMENTS', replacements):
                with self.assertRaisesRegex(ValueError, 'syntax count'):
                    adapter.migrate_candidate(stage, adapter.BASELINE_COMMIT)
            self.assertEqual(self.bodies(stage), self.archived)

    def test_provider_schema_is_left_for_existing_explicit_overlay(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            stage = self.stage(root)
            provider = root / 'provider'
            provider.mkdir()
            supplied = provider / 'schema.bend'
            supplied.write_bytes(b'custom W.Handle{namespace,id}\n')
            record = adapter.migrate_candidate(stage, adapter.BASELINE_COMMIT,
                                               provider_schema=True)
            self.assertFalse(record['providerFilesTransformed'])
            self.assertEqual(len(record['files']), 3)
            self.assertEqual((stage / 'examples/query-composition/schema.bend').read_bytes(),
                             self.archived['examples/query-composition/schema.bend'])
            self.assertEqual(supplied.read_bytes(), b'custom W.Handle{namespace,id}\n')


if __name__ == '__main__':
    unittest.main()
