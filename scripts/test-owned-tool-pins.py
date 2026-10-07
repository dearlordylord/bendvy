"""Contract and drift controls; no unsupervised execution fallback."""
from pathlib import Path
import importlib.util
import os
import shutil
import sys
import tempfile
import unittest

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner


ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location('owned_pins', ROOT/'scripts/owned-tool-pins.py')
pins = importlib.util.module_from_spec(spec); spec.loader.exec_module(pins)
sys.path.insert(0, str(ROOT/'scripts'))
sys.path.insert(0, str(ROOT/'experiments/public-relations/promotion-stage/current-core-replay/guarded-v2'))


class Contract(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(); self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name); self.resource = self.root/'resources'; self.resource.mkdir()
        (self.resource/'base').write_bytes(b'base')
        self.library = self.root/'library.so'; self.library.write_bytes(b'library')
        self.binary = self.root/'tool'; self.binary.write_bytes(b'tool')
        self.calls = []
        self.cfg = dict(execute=self.execute, tools={'tool': self.binary},
                        resource_roots=[self.resource], ldd=shutil.which('ldd'),
                        taskset=shutil.which('taskset'), cpu=min(os.sched_getaffinity(0)),
                        env=dict(os.environ), capture_mode='split')

    def execute(self, argv, cap, env=None):
        self.calls.append((argv, cap, env))
        return {'stdout': f'lib => {self.library} (0x0)\n'.encode(),
                'stderr': b'raw warning\n', 'exit': 0, 'failure': None}

    def test_contract_raw_streams_cap_cpu_env(self):
        got = pins.snapshot(**self.cfg); call = self.calls[0]
        self.assertEqual(call[1], 5); self.assertEqual(call[0][1:3], ['-c', str(self.cfg['cpu'])])
        self.assertEqual(call[2], self.cfg['env'])
        self.assertEqual(got['resolved_libraries']['tool']['stderr'], b'raw warning\n')
        self.assertIn(str(Path(shutil.which('ldd')).resolve()), got['pins'])
        pins.verify(got, **self.cfg)

    def test_missing_library_and_nonzero_refuse(self):
        for output, code in [(b'lib => not found\n', 0), (b'refused\n', 1)]:
            with self.subTest(code=code):
                cfg = dict(self.cfg, execute=lambda *a, **k: dict(stdout=output, stderr=b'', exit=code, failure=None))
                with self.assertRaises(RuntimeError): pins.snapshot(**cfg)

    def test_aslr_addresses_only_normalized(self):
        got = pins.snapshot(**self.cfg)
        def changed_address(*a, **k):
            result = self.execute(*a, **k)
            result['stdout'] = result['stdout'].replace(b'(0x0)', b'(0xABC123)')
            return result
        current = pins.verify(got, **dict(self.cfg, execute=changed_address))
        self.assertIn(b'(0xABC123)', current['resolved_libraries']['tool']['stdout'])
        other = self.root/'other-library.so'; other.write_bytes(b'library')
        for stdout, stderr in [
            (f'lib => {other} (0xABC123)\n'.encode(), b'raw warning\n'),
            (f'lib => {self.library} (0xABC123)\n'.encode(), b'changed warning\n'),
            (f'different => {self.library} (0xABC123)\n'.encode(), b'raw warning\n'),
        ]:
            with self.subTest(stdout=stdout, stderr=stderr):
                def changed(*a, **k):
                    return dict(stdout=stdout, stderr=stderr, exit=0, failure=None)
                with self.assertRaises(RuntimeError):
                    pins.verify(got, **dict(self.cfg, execute=changed))

    def test_environment_digest_and_structured_refusal(self):
        cfg = dict(self.cfg, env=dict(self.cfg['env'], PRIVATE_CREDENTIAL='secret-value'))
        got = pins.snapshot(**cfg)
        self.assertNotIn('environment', got)
        self.assertNotIn('secret-value', repr(got))
        with self.assertRaises(RuntimeError):
            pins.verify(got, **dict(cfg, env=dict(cfg['env'], PRIVATE_CREDENTIAL='changed')))
        def refused(argv, cap, env=None):
            if str(self.binary) == argv[-1]:
                return self.execute(argv, cap, env)
            return dict(stdout=b'\x00\xffraw', stderr=b'\xfe\x00error', exit=7, failure=None)
        cfg = dict(self.cfg, tools={'first': self.binary, 'second': self.library}, execute=refused)
        with self.assertRaises(pins.ProbeFailure) as caught:
            pins.snapshot(**cfg)
        failure = caught.exception
        self.assertEqual(failure.captures['second']['stdout'], b'\x00\xffraw')
        self.assertEqual(failure.captures['second']['stderr'], b'\xfe\x00error')
        self.assertEqual(failure.captures['second']['exit'], 7)
        self.assertEqual(failure.captures['first']['stderr'], b'raw warning\n')
        self.assertEqual(failure.probe['name'], 'second')
        self.assertNotIn('raw', str(failure))

    def test_bytes_and_resource_membership_drift(self):
        for kind in ['library', 'membership']:
            with self.subTest(kind=kind):
                got = pins.snapshot(**self.cfg)
                if kind == 'library': self.library.write_bytes(b'changed')
                else: (self.resource/'new').write_bytes(b'new')
                with self.assertRaises(RuntimeError): pins.verify(got, **self.cfg)

    def test_inflight_drift_and_executor_required(self):
        def drift(*args, **kwargs):
            self.binary.write_bytes(b'changed'); return self.execute(*args, **kwargs)
        with self.assertRaises(RuntimeError): pins.snapshot(**dict(self.cfg, execute=drift))
        with self.assertRaises(TypeError): pins.snapshot(**dict(self.cfg, execute=None))
        with self.assertRaises(TypeError): pins.snapshot(**{k:v for k,v in self.cfg.items() if k!='execute'})
        text = (ROOT/'scripts/owned-tool-pins.py').read_text()
        self.assertNotIn('subprocess', text); self.assertNotIn('Popen', text)

    def test_actual_reviewed_executor_raw_merged_and_five_second_argument(self):
        # Actual child invocation under the reviewed cleanup policy, not a mock.
        script = self.root/'ldd-fixture'; script.write_text('#!/bin/sh\nprintf "out\\n"\nprintf "err\\n" >&2\n'); script.chmod(0o755)
        calls = []
        def supervised(argv, cap, env=None):
            calls.append(cap); return task_runner.execute_result(argv, cap, env=env)
        got = pins.snapshot(**dict(self.cfg, execute=supervised, ldd=script, capture_mode='merged-stdout'))
        self.assertEqual(calls, [5])
        self.assertEqual(got['resolved_libraries']['tool']['stdout'], b'out\nerr\n')
        self.assertEqual(got['resolved_libraries']['tool']['stderr'], b'')


if __name__ == '__main__': unittest.main(verbosity=2)
