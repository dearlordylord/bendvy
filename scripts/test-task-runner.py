"""Real-process controls for command ownership, capture and evidence refusal."""
import concurrent.futures
import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock
import task_runner

from task_runner import Inputs, Runner, execute, execute_result, execute_split
spec = importlib.util.spec_from_file_location('logs', Path(__file__).with_name('receipt-logs.py'))
logs = importlib.util.module_from_spec(spec)
spec.loader.exec_module(logs)


def command(code):
    return [sys.executable, '-c', code]


class Execution(unittest.TestCase):
    def test_implementation_drift_refuses_execution(self):
        with mock.patch.object(task_runner, 'IMPLEMENTATION_SHA256', 'changed'):
            with self.assertRaises(RuntimeError): execute_result(command('pass'), 3)

    def test_adapters_delegate_and_no_public_process_copies(self):
        root = Path(__file__).resolve().parents[1]
        for path in root.glob('experiments/public-*/**/*.py'):
            source = path.read_text()
            self.assertNotIn('subprocess.Popen(', source, str(path))
            self.assertNotIn('subprocess.run(', source, str(path))
        paths = ['experiments/s-prep/fivehour-connected-gates/supervisor.py',
                 'experiments/public-component-state/supervisor.py',
                 'experiments/public-component-state/timing/supervisor.py',
                 'experiments/public-identity/production-candidate/promotion/supervisor.py']
        for name in paths:
            spec = importlib.util.spec_from_file_location('adapter', root/name)
            adapter = importlib.util.module_from_spec(spec); spec.loader.exec_module(adapter)
            self.assertIs(adapter.execute, task_runner.execute)
            self.assertIs(adapter.cleanup_owned, task_runner.cleanup_owned)
        for name in ['experiments/public-relations/promotion-stage/query-lifetime/raw-supervisor.py',
                     'experiments/public-relations/promotion-stage/current-core-replay/guarded-v2/raw_supervisor.py']:
            spec = importlib.util.spec_from_file_location('adapter', root/name)
            adapter = importlib.util.module_from_spec(spec); spec.loader.exec_module(adapter)
            self.assertEqual(adapter.execute(command('print("raw")'),3)['stdout'],b'raw\n')

    def test_completed_process_adapter(self):
        result = task_runner.run(command('import os; os.write(1,b"a\\r\\n"); os.write(2,b"err"); exit(7)'),timeout=3,capture_output=True,text=True)
        self.assertEqual((result.returncode,result.stdout,result.stderr),(7,'a\n','err'))
        self.assertEqual(result.runner_result['stdout'],b'a\r\n')
        with self.assertRaises(subprocess.CalledProcessError):
            task_runner.run(command('exit(7)'),timeout=3,capture_output=True,check=True)
        with self.assertRaises(subprocess.TimeoutExpired) as caught:
            task_runner.run(command('import os,time; os.write(1,b"raw"); time.sleep(60)'),timeout=.2,capture_output=True,text=True)
        self.assertEqual(caught.exception.output,b'raw')

    def test_caller_cancellation_cleans_owned_command(self):
        with tempfile.TemporaryDirectory() as directory:
            pidfile = Path(directory)/'pid'
            context = task_runner.multiprocessing.get_context('fork')
            receiver, sender = context.Pipe(duplex=False)
            class InterruptedReceiver:
                def poll(self, timeout):
                    ready = receiver.poll(timeout)
                    if pidfile.exists(): raise KeyboardInterrupt()
                    return ready
                def close(self): receiver.close()
            fake_context = mock.Mock()
            fake_context.Pipe.return_value = (InterruptedReceiver(), sender)
            fake_context.Process.side_effect = context.Process
            code = 'import os,time; open('+repr(str(pidfile))+',"w").write(str(os.getpid())); time.sleep(60)'
            with mock.patch.object(task_runner.multiprocessing,'get_context',return_value=fake_context):
                with self.assertRaises(KeyboardInterrupt): execute_result(command(code),10)
            self.assertFalse(Path('/proc',pidfile.read_text()).exists())

    def test_staged_adapter_and_current_provenance(self):
        import hashlib, json, shutil
        root = Path(__file__).resolve().parents[1]
        provenance = json.loads((root/'experiments/public-identity/production-candidate/promotion/supervisor-provenance.json').read_text())
        self.assertEqual(hashlib.sha256((root/provenance['implementation']).read_bytes()).hexdigest(),provenance['implementationSHA256'])
        original = (root/provenance['origin']).read_bytes()
        self.assertEqual(hashlib.sha256(original).hexdigest(),provenance['originSHA256'])
        adapter = root/'experiments/public-identity/production-candidate/promotion/supervisor.py'
        self.assertEqual(adapter.read_bytes()[:provenance['unchangedPrefixBytes']],original)
        with tempfile.TemporaryDirectory() as directory:
            stage = Path(directory)
            (stage/'scripts').mkdir(); (stage/'experiment').mkdir()
            shutil.copyfile(root/'scripts/task_runner.py',stage/'scripts/task_runner.py')
            shutil.copyfile(adapter,stage/'experiment/supervisor.py')
            code = 'import sys;sys.path.insert(0,'+repr(str(stage/'experiment'))+'); import supervisor; print(supervisor.execute([sys.executable,"-c","print(123)"],3))'
            result = execute_result(command(code),5,cwd=directory)
            self.assertIsNone(result['failure'])
            self.assertEqual(result['exit'],0)
            self.assertEqual(result['stdout'],b"(0, '123\\n')\n")

    def test_raw_bytes_and_exit(self):
        result = execute_result(command('import os; os.write(1,b"a\\x00\\xff"); os.write(2,b"b\\xfe"); exit(7)'), 3, capture='split')
        self.assertEqual((result['exit'], result['failure']), (7, None))
        self.assertEqual((result['stdout'], result['stderr']), (b'a\0\xff', b'b\xfe'))

    def test_merged_and_compatibility(self):
        cmd = command('import os; os.write(1,b"a"); os.write(2,b"b")')
        result = execute_result(cmd, 3)
        self.assertEqual((result['stdout'], result['stderr']), (b'ab', b''))
        self.assertEqual(execute(cmd, 3), (0, 'ab'))
        self.assertEqual(execute_split(cmd, 3), (0, b'a', b'b'))

    def test_cwd_environment_and_affinity(self):
        with tempfile.TemporaryDirectory() as directory:
            env = dict(os.environ, RUNNER_TEST='present')
            affinity = sorted(os.sched_getaffinity(0))
            result = execute_result(command('import os; print(os.getcwd()); print(os.environ["RUNNER_TEST"]); print(sorted(os.sched_getaffinity(0)))'), 3, env, directory)
            self.assertEqual(result['stdout'].decode().splitlines(), [directory, 'present', str(affinity)])

    def test_refusals(self):
        for timeout in (0, -1, float('nan'), float('inf'), True):
            with self.subTest(timeout=timeout), self.assertRaises(ValueError):
                execute_result(command('pass'), timeout)
        with self.assertRaises(ValueError):
            execute_result([], 1)
        result = execute_result(['/no-such-runner-command'], 1)
        self.assertIn('FileNotFoundError', result['failure'])
        self.assertEqual(result['stdout'], b'')

    def test_timeout_keeps_partial_bytes(self):
        started = time.monotonic()
        result = execute_result(command('import os,time; os.write(1,b"partial\\xff"); os.write(2,b"err\\x00"); time.sleep(60)'), .2, capture='split')
        self.assertEqual(result['failure'], 'child deadline')
        self.assertIsNone(result['exit'])
        self.assertEqual((result['stdout'], result['stderr']), (b'partial\xff', b'err\0'))
        self.assertLess(time.monotonic() - started, 4)

    def descendants(self, parent_waits, hold_pipes):
        with tempfile.TemporaryDirectory() as directory:
            pidfile = Path(directory) / 'pid'
            child = 'import os,time; os.setsid(); '
            if not hold_pipes:
                child += 'os.close(1); os.close(2); '
            child += 'open('+repr(str(pidfile))+',"w").write(str(os.getpid())); time.sleep(60)'
            parent = 'import subprocess,sys,time; subprocess.Popen([sys.executable,"-c",'+repr(child)+']); '
            parent += 'time.sleep(60)' if parent_waits else 'time.sleep(.15)'
            result = execute_result(command(parent), .4 if parent_waits else 3)
            self.assertIsNotNone(result['failure'])
            pid = int(pidfile.read_text())
            self.assertFalse(Path('/proc', str(pid)).exists(), 'detached child survived or remains zombie')

    def test_timeout_reaps_detached_descendant(self):
        self.descendants(True, True)

    def test_success_with_detached_descendant_is_refused(self):
        self.descendants(False, False)

    def test_inherited_pipes_do_not_escape_deadline(self):
        self.descendants(False, True)

    def test_unrelated_and_concurrent_children_survive(self):
        sibling = subprocess.Popen(command('import time; time.sleep(60)'))
        try:
            with concurrent.futures.ThreadPoolExecutor(2) as pool:
                a = pool.submit(execute_result, command('import time; time.sleep(60)'), .15)
                b = pool.submit(execute_result, command('import time; time.sleep(.3); print("ok")'), 3)
                self.assertEqual(a.result()['failure'], 'child deadline')
                self.assertEqual(b.result()['stdout'], b'ok\n')
            self.assertIsNone(sibling.poll())
        finally:
            sibling.kill()
            sibling.wait()

    def test_compatibility_failure_retains_raw_output(self):
        with self.assertRaises(TimeoutError) as raised:
            execute_split(command('import os,time; os.write(1,b"x"); time.sleep(60)'), .15)
        self.assertEqual(raised.exception.stdout, b'x')


class Evidence(unittest.TestCase):
    def test_inputs_bytes_membership_and_missing(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / 'source'
            path.write_bytes(b'one')
            inputs = Inputs(files=[path], directories=[root])
            inputs.guard()
            path.write_bytes(b'two')
            with self.assertRaises(RuntimeError): inputs.guard()
            path.write_bytes(b'one')
            (root / 'extra').write_bytes(b'new')
            with self.assertRaises(RuntimeError): inputs.guard()
            path.unlink()
            with self.assertRaises(FileNotFoundError): inputs.guard()

    def test_runner_logs_and_refuses_nonzero(self):
        with tempfile.TemporaryDirectory() as directory:
            logger = logs.CommandLogs(directory, ['ok', 'bad'])
            runner = Runner(logger, inputs=Inputs())
            runner.run('ok', command('print("yes")'), 3)
            self.assertEqual((Path(directory)/'ok.stdout').read_bytes(), b'yes\n')
            with self.assertRaises(RuntimeError): runner.run('bad', command('print("no"); exit(7)'), 3)
            self.assertEqual((Path(directory)/'bad.stdout').read_bytes(), b'no\n')
            logger.guard()
            with self.assertRaises(ValueError): runner.run('ok', command('pass'), 3)

    def test_inflight_drift_retains_logs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root/'input'; source.write_bytes(b'old')
            logger = logs.CommandLogs(root, ['drift'])
            runner = Runner(logger, inputs=Inputs(files=[source]))
            with self.assertRaises(RuntimeError):
                runner.run('drift', command('from pathlib import Path; Path('+repr(str(source))+').write_bytes(b"changed"); print("recorded")'), 3)
            self.assertEqual((root/'drift.stdout').read_bytes(), b'recorded\n')

    def test_timeout_logs_and_tamper(self):
        with tempfile.TemporaryDirectory() as directory:
            logger = logs.CommandLogs(directory, ['timeout', 'next'])
            runner = Runner(logger, inputs=Inputs())
            with self.assertRaises(TimeoutError):
                runner.run('timeout', command('import os,time; os.write(1,b"partial"); time.sleep(60)'), .15)
            self.assertEqual((Path(directory)/'timeout.stdout').read_bytes(), b'partial')
            (Path(directory)/'timeout.stdout').write_bytes(b'fake')
            with self.assertRaises(AssertionError): runner.run('next', command('pass'), 3)


if __name__ == '__main__':
    unittest.main()
