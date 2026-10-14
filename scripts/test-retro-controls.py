"""Regress delivery-process failure classes using temporary, noncompiler fixtures."""
import copy
from contextlib import redirect_stdout
import hashlib
import io
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


class SavedPreflightRegressions(unittest.TestCase):
    artifact_guard = 'Existing collector guards both generated and native parents before/acquired/post/final.'

    def write_batch(self, root, plan_value, plan_path=None):
        plan_path = plan_path or (root / 'plan.json')
        plan_path.parent.mkdir(parents=True, exist_ok=True)
        plan_path.write_text(json.dumps(plan_value))
        manifest_path = root / 'batch.json'
        manifest_path.write_text(json.dumps({'jobs': [{
            'id': 'guarded', 'kind': 'ordinary', 'plan': str(plan_path),
            'planSHA256': hashlib.sha256(plan_path.read_bytes()).hexdigest(),
            'argv': ['recorded-child'], 'cwd': str(root), 'capSeconds': 1,
        }]}))
        return plan_path, manifest_path

    def guarded_native_plan(self, root, artifact_parent):
        generated = str(artifact_parent / 'scenario.c')
        native = str(artifact_parent / 'scenario.native')
        value = plan(native=True)
        value['generated'] = generated
        value['native'] = native
        value['commands'][0]['argv'][-1] = generated
        value['commands'][1]['argv'] = ['clang', generated, '-o', native]
        value['commands'][2]['argv'] = [native]
        value['artifactOutputRoot'] = str(artifact_parent)
        value['artifactParentGuard'] = self.artifact_guard
        return value

    def test_saved_artifact_parent_refusal_and_valid_successor(self):
        # Replays profile-v1's plan-above-native-output parent mismatch and
        # profile-v2's matching plan/output-directory successor.
        fake_result = {'exit': 0, 'failure': None, 'stdout': b'', 'stderr': b''}
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            profile = root / 'profile-v1'
            nested = profile / 'native-output'
            nested.mkdir(parents=True)
            malformed = self.guarded_native_plan(profile, nested)
            historical_plan = profile / 'PLAN.json'
            historical_plan.write_text(json.dumps(malformed))
            with self.assertRaisesRegex(ValueError, 'artifactOutputRoot'):
                preflight.validate(malformed, plan_path=historical_plan)
            # Isolate the collector's actual artifact-parent invariant from
            # the metadata mismatch in the saved predecessor.
            parent_mismatch = copy.deepcopy(malformed)
            parent_mismatch['artifactOutputRoot'] = str(profile)
            _, manifest = self.write_batch(root, parent_mismatch, historical_plan)
            output = root / 'rejected-output'
            with patch.object(delivery_batch.task_runner, 'execute_result') as execute:
                with self.assertRaisesRegex(ValueError, 'artifact parent escaped'):
                    delivery_batch.run_batch(manifest, output)
                execute.assert_not_called()
            self.assertFalse(output.exists())

        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            output_parent = root / 'profile-v2' / 'native-output'
            output_parent.mkdir(parents=True)
            valid = self.guarded_native_plan(output_parent, output_parent)
            valid_plan = output_parent / 'plan.json'
            _, manifest = self.write_batch(root, valid, valid_plan)
            output = root / 'accepted-output'
            with patch.object(delivery_batch.task_runner, 'execute_result', return_value=fake_result) as execute:
                receipt = delivery_batch.run_batch(manifest, output)
            self.assertEqual(receipt['status'], 'WRAPPERS_PASS')
            execute.assert_called_once()

    def test_saved_emit_only_profile_metadata_does_not_admit_runtime_role(self):
        # The two saved profiling plans use the metadata guard but have an
        # emit-only collector dialect. Replay that distinction: metadata-only
        # validation diagnoses the old parent, accepts the direct-parent
        # successor, and ordinary preflight still rejects its unsupported role.
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            old_profile = root / 'profile-v1'
            old_output = old_profile / 'native-output'
            old_output.mkdir(parents=True)
            old_plan_path = old_profile / 'PLAN.json'
            old_plan = {
                'commands': [{'label': 'emit', 'argv': ['bend', 'entry.bend', '-o',
                                                        str(old_output / 'scenario.c')]}],
                'generated': str(old_output / 'scenario.c'),
                'native': str(old_output / 'scenario.native'),
                'artifactOutputRoot': str(old_output),
                'artifactParentGuard': self.artifact_guard,
            }
            old_plan_path.write_text(json.dumps(old_plan))
            with self.assertRaisesRegex(ValueError, 'artifactOutputRoot'):
                preflight.validate_bindings(old_plan, old_plan_path)

            new_output = root / 'profile-v2' / 'native-output'
            new_output.mkdir(parents=True)
            new_plan_path = new_output / 'plan.json'
            new_plan = {
                'commands': [{'label': 'emit', 'argv': ['bend', 'entry.bend', '-o',
                                                        str(new_output / 'scenario.c')]}],
                'generated': str(new_output / 'scenario.c'),
                'native': str(new_output / 'scenario.native'),
                'artifactOutputRoot': str(new_output),
                'artifactParentGuard': self.artifact_guard,
            }
            new_plan_path.write_text(json.dumps(new_plan))
            preflight.validate_bindings(new_plan, new_plan_path)
            with self.assertRaisesRegex(ValueError, 'runtime command order'):
                preflight.validate(new_plan, plan_path=new_plan_path)

    def test_manifest_cli_supplies_plan_path_to_opt_in_guard(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            value = self.guarded_native_plan(root, root)
            plan_path = root / 'plan.json'
            plan_path.write_text(json.dumps(value))
            manifest_path = root / 'plans.json'
            manifest_path.write_text(json.dumps({'plans': [str(plan_path)]}))
            with patch.object(sys, 'argv', ['delivery_preflight', '--manifest', str(manifest_path)]):
                with redirect_stdout(io.StringIO()):
                    preflight.main()

    def current_provenance_plan(self):
        value = plan(native=True)
        generated = value['generated']
        compiler = '/tmp/pinned-candidate.mjs'
        receipt = '/tmp/emit-receipt.json'
        c_sha = '47860766951e7f10329e7512dc40b06d8de1aeb16a4539d09ebace652564f2f9'
        compiler_sha = 'f686d14a08a7f1b6621c7d10184f0f9f53bd5e934855272f90a28596d5454a41'
        receipt_sha = '4040bf32e6a0bae69790c1279fb2e248818e06e20bb14e6ff20e05faf58bfd71'
        value['tools'] = {'bend': compiler}
        value['pins'] = {generated: c_sha, compiler: compiler_sha, receipt: receipt_sha}
        value['provenance'] = {
            'currentC': generated,
            'currentCSHA256': c_sha,
            'currentCompilerSHA256': compiler_sha,
            'currentEmitReceipt': receipt,
            'currentEmitReceiptSHA256': receipt_sha,
        }
        return value

    def test_saved_stale_current_compiler_provenance_and_valid_successor(self):
        # Replays current-o3-stack-v1's stale currentC/compiler lineage and its
        # successor's current generated-C, compiler, and emit-receipt bindings.
        stale = self.current_provenance_plan()
        old_c = '/tmp/canary-enum01/inspectors-runtime.c'
        stale['provenance'].pop('currentCompilerSHA256')
        stale['provenance'].pop('currentEmitReceipt')
        stale['provenance'].pop('currentEmitReceiptSHA256')
        stale['provenance']['currentC'] = old_c
        stale['provenance']['currentCSHA256'] = 'c7ae6a5cd33ae99455ce41d58f3aeb0b06438cf5e7d1f3944215c493370c34e7'
        stale['pins'][old_c] = stale['provenance']['currentCSHA256']
        with self.assertRaisesRegex(ValueError, 'fields must be declared together'):
            preflight.validate(stale)

        stale_path = self.current_provenance_plan()
        stale_path['provenance']['currentC'] = old_c
        with self.assertRaisesRegex(ValueError, 'currentC must identify'):
            preflight.validate(stale_path)

        successor = self.current_provenance_plan()
        self.assertEqual(preflight.validate(successor), 'native')

        stale_compiler = self.current_provenance_plan()
        stale_compiler['provenance']['currentCompilerSHA256'] = 'd' * 64
        with self.assertRaisesRegex(ValueError, 'compiler digest'):
            preflight.validate(stale_compiler)

        stale_receipt = self.current_provenance_plan()
        stale_receipt['provenance']['currentEmitReceiptSHA256'] = 'd' * 64
        with self.assertRaisesRegex(ValueError, 'emit receipt digest'):
            preflight.validate(stale_receipt)

    def test_generic_provenance_and_unpinned_fresh_output_remain_accepted(self):
        # Ordinary #56 plans summarize source/oracle lineage without the
        # current-C/compiler dialect. Fresh emit outputs are not pre-pinned.
        ordinary = plan(native=True)
        ordinary['provenance'] = {
            'parentPlanSHA256': 'a' * 64,
            'normalOracleSHA256': 'b' * 64,
        }
        self.assertEqual(preflight.validate(ordinary), 'native')

    def test_saved_import_closure_order_and_valid_successor(self):
        # runtime01's sourceInventory mapping order is intentionally retained;
        # the collector contract requires only the separate importClosure list
        # to be sorted and set-equal. runtime02 sorts that list only.
        value = plan()
        inventory = {'/tmp/zeta.bend': 'a' * 64, '/tmp/alpha.bend': 'b' * 64}
        value['sourceInventory'] = inventory
        value['importClosure'] = sorted(inventory)
        self.assertEqual(preflight.validate(value), 'js')
        self.assertEqual(list(value['sourceInventory']), ['/tmp/zeta.bend', '/tmp/alpha.bend'])

        malformed = copy.deepcopy(value)
        malformed['importClosure'].reverse()
        with self.assertRaisesRegex(ValueError, 'sorted exact'):
            preflight.validate(malformed)

        missing_path = copy.deepcopy(value)
        missing_path['importClosure'].pop()
        with self.assertRaisesRegex(ValueError, 'sorted exact'):
            preflight.validate(missing_path)

        wrong_type = copy.deepcopy(value)
        wrong_type['importClosure'] = {'/tmp/alpha.bend': True, '/tmp/zeta.bend': True}
        with self.assertRaisesRegex(ValueError, 'must be a list'):
            preflight.validate(wrong_type)


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
