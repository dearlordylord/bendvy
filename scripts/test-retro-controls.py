"""Regress actual Work3 failure classes using temporary, noncompiler fixtures."""
import copy
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
import delivery_preflight as preflight
import delivery_batch
import owned_stage
import scenario_controls
import native_reduce
import task_runner


def plan(native=False):
    generated = '/tmp/candidate.c' if native else '/tmp/candidate.js'
    commands = [{'label': 'emit', 'argv': ['bend', 'entry.bend', '-o', generated]}]
    if native:
        commands.append({'label': 'build', 'argv': ['clang', generated, '-o', '/tmp/candidate.native']})
    commands.append({'label': 'consumer', 'argv': ['/tmp/candidate.native'] if native else ['node', generated]})
    return {'generated': generated, 'native': '/tmp/candidate.native', 'commands': commands}


class Plans(unittest.TestCase):
    def test_valid_backend_plans(self):
        self.assertEqual(preflight.validate(plan()), 'js')
        self.assertEqual(preflight.validate(plan(True)), 'native')

    def test_native_js_metadata_typo(self):
        value = plan(True)
        value['generated'] = '/tmp/candidate.js'
        with self.assertRaisesRegex(ValueError, 'artifact'):
            preflight.validate(value)

    def test_wrong_emit_build_and_consumer_join(self):
        for index in range(3):
            value = plan(True)
            value['commands'][index]['argv'] = ['other', '-o', '/tmp/other.c']
            with self.assertRaises(ValueError):
                preflight.validate(value)

    def test_check_only_dispatch(self):
        value = {'commands': [{'label': 'support', 'argv': ['bend', '--check-only']}]}
        with self.assertRaisesRegex(ValueError, 'source-'):
            preflight.validate(value)
        value['commands'][0]['label'] = 'source-support'
        self.assertEqual(preflight.validate(value), 'source')

    def test_duplicates_and_mixed_modes(self):
        value = plan()
        value['commands'][1]['label'] = 'emit'
        with self.assertRaises(ValueError):
            preflight.validate(value)
        value = plan()
        value['commands'][1]['argv'].append('--check-only')
        with self.assertRaises(ValueError):
            preflight.validate(value)


class Queue(unittest.TestCase):
    def fixture(self, root, failing=False):
        p = root / 'plan.json'
        p.write_text(json.dumps(plan()))
        digest = hashlib.sha256(p.read_bytes()).hexdigest()
        lock, order = root / 'lock', root / 'order'
        jobs = []
        for index in range(2):
            # An internal collector lock must not deadlock against an outer lock.
            code = ('import fcntl,time;from pathlib import Path;'
                    f'f=open({str(lock)!r},"a");fcntl.flock(f,fcntl.LOCK_EX);'
                    f'p=Path({str(order)!r});'
                    f'p.open("a").write("start{index}\\n");time.sleep(.01);'
                    f'p.open("a").write("end{index}\\n");'
                    f'print("job{index}");raise SystemExit({7 if failing and index == 0 else 0})')
            jobs.append({'id': str(index), 'kind': 'ordinary', 'plan': str(p),
                         'planSHA256': digest, 'argv': [sys.executable, '-c', code],
                         'cwd': str(root), 'capSeconds': 3})
        manifest = root / 'batch.json'
        manifest.write_text(json.dumps({'jobs': jobs}))
        return manifest, order

    def test_real_sequential_children_internal_lock_and_logs(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            manifest, order = self.fixture(root)
            receipt = delivery_batch.run_batch(manifest, root / 'output')
            self.assertEqual(order.read_text().splitlines(), ['start0', 'end0', 'start1', 'end1'])
            self.assertEqual(receipt['status'], 'WRAPPERS_PASS')
            self.assertEqual((root / 'output/1.stdout').read_bytes(), b'job1\n')
            with self.assertRaises(FileExistsError):
                delivery_batch.run_batch(manifest, root / 'output')

    def test_failed_job_retains_terminal_and_never_starts_next(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            manifest, order = self.fixture(root, True)
            with self.assertRaisesRegex(RuntimeError, 'job failed'):
                delivery_batch.run_batch(manifest, root / 'output')
            receipt = json.loads((root / 'output/receipt.json').read_text())
            self.assertEqual(receipt['status'], 'INCOMPLETE')
            self.assertEqual(receipt['commands'][0]['exit'], 7)
            self.assertEqual(receipt['pending'], ['1'])
            self.assertEqual(order.read_text().splitlines(), ['start0', 'end0'])

    def test_performance_and_changed_plan_rejected_before_output(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            manifest, _ = self.fixture(root)
            value = json.loads(manifest.read_text())
            value['jobs'][0]['kind'] = 'performance'
            manifest.write_text(json.dumps(value))
            with self.assertRaises(ValueError):
                delivery_batch.run_batch(manifest, root / 'output')
            self.assertFalse((root / 'output').exists())
            value['jobs'][0]['kind'] = 'ordinary'
            value['jobs'][0]['planSHA256'] = 'wrong'
            manifest.write_text(json.dumps(value))
            with self.assertRaises(ValueError):
                delivery_batch.run_batch(manifest, root / 'output')


class Ownership(unittest.TestCase):
    def test_foreign_independent_model_is_rejected(self):
        with self.assertRaisesRegex(ValueError, 'outside ownership'):
            owned_stage.check_owned({'consumer.bend'}, ['consumer.bend', 'model.py.source'])

    def test_normalized_exact_paths(self):
        for name in ['../other', '/absolute', 'a//b', './file', '.']:
            with self.assertRaises(ValueError):
                owned_stage.owned_paths({'paths': [name]})

    def test_real_index_literal_paths_and_inherited_git_env(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            owned_stage.git(root, 'init', '-q')
            (root / 'a[1].txt').write_text('owned')
            (root / 'a1.txt').write_text('unowned')
            manifest = root / 'owned.json'
            manifest.write_text(json.dumps({'paths': ['a[1].txt']}))
            with patch.dict(os.environ, {'GIT_DIR': '/missing/foreign', 'GIT_INDEX_FILE': '/missing/index'}):
                self.assertEqual(owned_stage.stage(root, manifest, True), ['a[1].txt'])
            owned_stage.git(root, 'add', '--', 'a1.txt')
            with self.assertRaises(ValueError):
                owned_stage.stage(root, manifest)


class Scenarios(unittest.TestCase):
    def test_breadth_model_accidentally_dispatches_depth(self):
        expected = {'LIVE_DEPTH': [2, 4, 3], 'LIVE_BREADTH': [2, 3, 4], 'DEAD_BREADTH': [2, 3]}
        actual = copy.deepcopy(expected)
        actual['LIVE_BREADTH'] = actual['LIVE_DEPTH']
        with self.assertRaisesRegex(ValueError, 'LIVE_BREADTH'):
            scenario_controls.scenes(actual, expected)
        scenario_controls.scenes(expected, expected)
        actual = copy.deepcopy(expected)
        del actual['DEAD_BREADTH']
        with self.assertRaises(ValueError):
            scenario_controls.scenes(actual, expected)

    def test_success_timeout_and_unrelated_refusal_do_not_pass(self):
        for result, stderr in [({'exit': 0, 'failure': None}, 'Cap.Write'),
                               ({'exit': 1, 'failure': 'child deadline'}, 'Cap.Write'),
                               ({'exit': 1, 'failure': None}, 'syntax error')]:
            with self.assertRaises(ValueError):
                scenario_controls.negative(result, stderr, ['Cap.Write', 'Cap.ValueRead'])
        scenario_controls.negative({'exit': 1, 'failure': None},
                                   'expected Cap.Write observed Cap.ValueRead', ['Cap.Write', 'Cap.ValueRead'])


class Reduction(unittest.TestCase):
    source = 'import ./dep.bend as D\ndef specs() -> List<&2,Spec>:[\n  Spec{One{}},\n  Spec{Two{}}\n]\ndef main() -> String:"full"\n'

    def test_subset_preserves_surrounding_helpers_and_order(self):
        reduced = native_reduce.reduce_specs(self.source, [1])
        self.assertNotIn('Spec{One{}}', reduced)
        self.assertIn('Spec{Two{}}', reduced)
        self.assertEqual(reduced.split('def main()')[1], self.source.split('def main()')[1])
        with self.assertRaises(ValueError):
            native_reduce.reduce_specs(self.source, [2])

    def test_relocated_imports_and_immutable_source(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            source = root / 'source.bend'
            (root / 'dep.bend').write_text('import Base\n')
            source.write_text(self.source)
            native_reduce.prepare(source, root / 'candidate', [0])
            self.assertEqual(source.read_text(), self.source)
            self.assertIn(str(root / 'dep.bend'), (root / 'candidate/main.bend').read_text())
            self.assertEqual(json.loads((root / 'candidate/REDUCTION.json').read_text())['status'], 'PREPARED_NOT_EXECUTED')

    def test_nested_completed_and_open_phase_markers(self):
        result = native_reduce.phase_summary([{'phase': 'validate', 'event': 'start'},
                                             {'phase': 'validate', 'event': 'end'},
                                             {'phase': 'lower', 'event': 'start'}])
        self.assertEqual(result['completed'], ['validate'])
        self.assertEqual(result['openAtCaptureEnd'], ['lower'])
        with self.assertRaises(ValueError):
            native_reduce.phase_summary([{'phase': 'missing', 'event': 'end'}])

    def test_real_marker_dialect_retains_unfinished_definition(self):
        rows = [{'phase': 'book-read-enter', 'ms': 0},
                {'phase': 'book-load-complete', 'ms': 1},
                {'phase': 'validation-enter', 'definition': 'execute', 'index': 7, 'ms': 2}]
        result = native_reduce.phase_log('\n'.join(map(json.dumps, rows)))
        self.assertEqual(result['lastMarker']['definition'], 'execute')
        self.assertEqual(result['completedMarkers'], 1)
        self.assertEqual(len(result['openAtCaptureEnd']), 2)


if __name__ == '__main__':
    unittest.main()
