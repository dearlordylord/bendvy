"""Controls for previously missed command log corruption and label collisions."""
import importlib.util
import ast
import hashlib
import json
from pathlib import Path
import tempfile
import types
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('receipt_logs', Path(__file__).with_name('receipt-logs.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class LogControls(unittest.TestCase):
    def test_declaration_receipt_retains_partial_publication_before_guards(self):
        root = Path(__file__).resolve().parents[1]
        collector = root / 'experiments/public-owned-events/declaration-read-v1/development-run.py'
        main = next(node for node in ast.parse(collector.read_bytes()).body
                    if isinstance(node, ast.FunctionDef) and node.name == 'main')
        guard_source = next(node for node in main.body
                            if isinstance(node, ast.FunctionDef) and node.name == 'guard')
        guard_code = compile(ast.Module(body=[guard_source], type_ignores=[]), str(collector), 'exec')
        def load(name, path):
            spec = importlib.util.spec_from_file_location(name, path)
            loaded = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(loaded)
            return loaded
        runner_module = load('partial_runner', root / 'scripts/task_runner.py')
        boundary = load('partial_boundary', root / 'scripts/evidence_boundary.py')
        for drift in (False, True):
            with self.subTest(input_drift=drift), tempfile.TemporaryDirectory() as directory:
                directory = Path(directory)
                generated = directory / 'generated'
                generated.mkdir()
                raw = directory / 'raw'
                raw.mkdir()
                input_path = directory / 'input'
                input_path.write_bytes(b'frozen')
                frozen = runner_module.Inputs(files=[input_path])
                logs = module.CommandLogs(raw, ['normal'])
                record = {'status': 'INCOMPLETE', 'logs': {}, 'generated': {}, 'commands': []}
                namespace = dict(record=record, logs=logs, frozen=frozen, generated=generated,
                                 admitted_plan=lambda *args: {}, plan_path=directory / 'plan.json',
                                 plan_digest='unused', admitted={}, hashlib=hashlib)
                exec(guard_code, namespace)
                guard = namespace['guard']
                original_open = Path.open
                class PartialStream:
                    def __enter__(self):
                        self.stream = original_open(raw / 'normal.stderr', 'xb')
                        return self
                    def write(self, data):
                        self.stream.write(data[:1])
                        if drift:
                            input_path.write_bytes(b'changed')
                        raise OSError('stderr publication interrupted')
                    def __exit__(self, *args):
                        self.stream.close()
                def open_stream(path, *args, **kwargs):
                    if path == raw / 'normal.stderr' and args == ('xb',):
                        return PartialStream()
                    return original_open(path, *args, **kwargs)
                completed = {'exit': 0, 'failure': None, 'stdout': b'complete\x00\xff\n',
                             'stderr': b'diagnostic\n'}
                runner = runner_module.Runner(logs, inputs=frozen)
                with patch.object(runner_module, 'execute_result', return_value=completed), \
                     patch.object(Path, 'open', open_stream):
                    with self.assertRaisesRegex(OSError, 'stderr publication interrupted'):
                        with boundary.ReceiptBoundary(record, directory / 'receipt.json', [('capture', guard)]):
                            with boundary.GuardBoundary([('capture', guard)]):
                                try:
                                    runner.run('normal', ['unused'], 5)
                                except BaseException as error:
                                    record['commands'].append({key: value for key, value in error.result.items()
                                                               if not isinstance(value, bytes)})
                                    raise
                receipt = json.loads((directory / 'receipt.json').read_bytes())
                self.assertEqual(receipt['status'], 'INCOMPLETE')
                self.assertEqual(receipt['commands'][0]['exit'], 0)
                self.assertEqual(receipt['logs'], {'normal.stdout': hashlib.sha256(completed['stdout']).hexdigest()})
                self.assertEqual((raw / 'normal.stdout').read_bytes(), completed['stdout'])
                self.assertEqual((raw / 'normal.stderr').read_bytes(), b'd')
                self.assertTrue(receipt['guardFailures'])

    def test_duplicate_plan_refused_before_capture(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaises(ValueError):
                module.CommandLogs(directory, ['runtime-check', 'runtime-check'])
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_raw_channels_and_overwrite(self):
        with tempfile.TemporaryDirectory() as directory:
            logs = module.CommandLogs(directory, ['normal'])
            logs.record('normal', b'\x00\xff\n', b'diagnostic\n')
            self.assertEqual((Path(directory) / 'normal.stdout').read_bytes(), b'\x00\xff\n')
            self.assertEqual((Path(directory) / 'normal.stderr').read_bytes(), b'diagnostic\n')
            with self.assertRaises(AssertionError):
                logs.record('normal', b'', b'')

    def test_tampered_deleted_and_extra_logs(self):
        for mutation in ('tamper', 'delete', 'extra'):
            with self.subTest(mutation=mutation), tempfile.TemporaryDirectory() as directory:
                logs = module.CommandLogs(directory, ['normal'])
                logs.record('normal', b'complete observation', b'')
                path = Path(directory) / 'normal.stdout'
                if mutation == 'tamper':
                    path.write_bytes(b'replacement')
                elif mutation == 'delete':
                    path.unlink()
                else:
                    (Path(directory) / 'unrecorded.stderr').write_bytes(b'')
                with self.assertRaises(AssertionError):
                    logs.guard()

    def test_unplanned_label_and_text_refused(self):
        with tempfile.TemporaryDirectory() as directory:
            logs = module.CommandLogs(directory, ['normal'])
            with self.assertRaises(ValueError):
                logs.record('unplanned', b'', b'')
            with self.assertRaises(TypeError):
                logs.record('normal', 'decoded', b'')
            self.assertEqual(list(Path(directory).iterdir()), [])


if __name__ == '__main__':
    unittest.main()
