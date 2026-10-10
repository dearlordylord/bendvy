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
source_spec = importlib.util.spec_from_file_location('python_source', Path(__file__).with_name('check-python-source.py'))
python_source = importlib.util.module_from_spec(source_spec)
source_spec.loader.exec_module(python_source)


def command(code):
    return [sys.executable, '-c', code]


class Execution(unittest.TestCase):
    def test_implementation_drift_refuses_execution(self):
        with mock.patch.object(task_runner, 'IMPLEMENTATION_SHA256', 'changed'):
            with self.assertRaises(RuntimeError): execute_result(command('pass'), 3)

    def test_current_entrypoints_use_one_process_implementation(self):
        root = Path(__file__).resolve().parents[1]
        tracked = set(subprocess.check_output(['git', 'ls-files', '-z'], cwd=root).decode().split('\0'))
        paths=list(root.glob('experiments/public-*/**/*.py'))
        paths += [p for folder in ('benchmarks','docs','examples','scripts') for p in (root/folder).rglob('*.py') if p.name!='task_runner.py' and not p.name.startswith('test-')]
        for path in paths:
            if str(path.relative_to(root)) not in tracked:
                continue
            self.assertTrue(python_source.check(str(path), path.read_bytes()), str(path))

    def test_frozen_execution_chains_reject_cached_loaders(self):
        for name in [*python_source.SOURCE_BOUND_LOADERS,
                     'experiments/public-inspect/native-debug-call-boundary-v1/execution.py']:
            with self.subTest(name=name), mock.patch('builtins.print'):
                self.assertFalse(python_source.check(name, 'spec.loader.exec_module(module)'))
                self.assertTrue(python_source.check(name, 'exec(compile(raw, path, "exec"), module.__dict__)'))
                self.assertTrue(python_source.check(name, 'message = "spec.loader.exec_module(module)"'))
        # A negative cache reproduction is not the frozen runtime loader.
        self.assertTrue(python_source.check(
            'experiments/public-inspect/native-debug-call-boundary-v1/test-execution.py',
            'spec.loader.exec_module(module)'))

    def test_entrypoint_source_refusals(self):
        for folder in ['experiments/public-candidate', 'benchmarks', 'docs', 'examples', 'scripts']:
            for method in ['Popen', 'run', 'check_output', 'check_call', 'call']:
                with self.subTest(folder=folder, method=method), mock.patch('builtins.print'):
                    self.assertFalse(python_source.check(folder + '/candidate.py', f'subprocess.{method}([])'))
        for module in ['supervisor', 'supervise', 'raw_supervisor']:
            with self.subTest(module=module), mock.patch('builtins.print'):
                self.assertFalse(python_source.check('scripts/candidate.py', 'import ' + module))

    def test_entrypoint_source_existing_exemptions(self):
        for name in ['scripts/task_runner.py', 'scripts/test-candidate.py', 'examples/test-candidate.py',
                     'experiments/private-candidate/main.py', 'other/main.py']:
            with self.subTest(name=name):
                self.assertTrue(python_source.check(name, 'import supervisor\nsubprocess.run([])'))
        self.assertTrue(python_source.check('scripts/candidate.py', 'from task_runner import run\nrun([])'))
        # Public experiments had no test-name or task_runner exemption.
        with mock.patch('builtins.print'):
            self.assertFalse(python_source.check('experiments/public-candidate/test-case.py', 'subprocess.run([])'))
            self.assertFalse(python_source.check('experiments/public-candidate/task_runner.py', 'import supervisor'))

    def test_explicit_untracked_source_checked_before_staging(self):
        with tempfile.TemporaryDirectory(dir=Path(__file__).parent) as directory:
            candidate = Path(directory) / 'candidate.py'
            candidate.write_text('import subprocess\nsubprocess.run([])\n')
            with mock.patch.object(sys, 'argv', ['check-python-source.py', str(candidate)]), mock.patch('builtins.print'):
                self.assertEqual(python_source.main(), 1)
            candidate.write_text('from task_runner import run\nrun([])\n')
            with mock.patch.object(sys, 'argv', ['check-python-source.py', str(candidate)]):
                self.assertEqual(python_source.main(), 0)

    def test_runner_publication_and_postguard_failure_keep_process_result(self):
        result = dict(exit=7, failure=None, stdout=b'completed stdout', stderr=b'error')
        for stage in ('publication', 'postguard'):
            with self.subTest(stage=stage):
                inputs, command_logs = mock.Mock(), mock.Mock()
                command_logs.labels = {'probe'}
                command_logs.hashes = {}
                failure = OSError('publication refused') if stage == 'publication' else RuntimeError('input drift')
                if stage == 'publication':
                    command_logs.record.side_effect = failure
                else:
                    inputs.guard.side_effect = [None, failure]
                runner = Runner(command_logs, inputs=inputs)
                with mock.patch.object(task_runner, 'execute_result', return_value=result):
                    with self.assertRaises(type(failure)) as caught:
                        runner.run('probe', ['no child'], 5)
                self.assertIs(caught.exception, failure)
                self.assertIs(caught.exception.result, result)
                self.assertEqual(caught.exception.result['stdout'], b'completed stdout')

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

    def test_staged_shared_module(self):
        import shutil
        root = Path(__file__).resolve().parents[1]
        with tempfile.TemporaryDirectory() as directory:
            stage=Path(directory);(stage/'scripts').mkdir()
            shutil.copyfile(root/'scripts/task_runner.py',stage/'scripts/task_runner.py')
            code='import sys;sys.path.insert(0,'+repr(str(stage/'scripts'))+'); import task_runner; print(task_runner.execute([sys.executable,"-c","print(123)"],3))'
            result=execute_result(command(code),5,cwd=directory)
            self.assertIsNone(result['failure'])
            self.assertEqual(result['exit'],0)
            self.assertEqual(result['stdout'],b"(0, '123\\n')\n")

    def test_raw_bytes_and_exit(self):
        result = execute_result(command('import os; os.write(1,b"a\\x00\\xff"); os.write(2,b"b\\xfe"); exit(7)'), 3, capture='split')
        self.assertEqual((result['exit'], result['failure']), (7, None))
        self.assertEqual((result['stdout'], result['stderr']), (b'a\0\xff', b'b\xfe'))

    def test_completed_result_survives_stale_poll_before_owner_death(self):
        with tempfile.TemporaryDirectory() as directory:
            release = Path(directory) / 'release'
            context = task_runner.multiprocessing.get_context('fork')
            receiver, sender = context.Pipe(duplex=False)
            owners = []
            class StaleReceiver:
                first = True
                def poll(self, timeout):
                    if not self.first:
                        return receiver.poll(timeout)
                    self.first = False
                    # The command cannot finish until this readiness check.
                    self_ready = receiver.poll(0)
                    if self_ready:
                        raise AssertionError('result arrived before release')
                    release.touch()
                    owners[0].join(3)
                    if owners[0].is_alive() or not receiver.poll(0):
                        raise AssertionError('owner did not publish then exit')
                    return False  # The earlier readiness observation is stale.
                def recv(self): return receiver.recv()
                def close(self): receiver.close()
            def process(*args, **kwargs):
                owner = context.Process(*args, **kwargs)
                owners.append(owner)
                return owner
            fake_context = mock.Mock()
            fake_context.Pipe.return_value = (StaleReceiver(), sender)
            fake_context.Process.side_effect = process
            code = 'from pathlib import Path; import time; p=Path('+repr(str(release))+'); '
            code += '\nwhile not p.exists(): time.sleep(.001)\nprint("published")'
            with mock.patch.object(task_runner.multiprocessing, 'get_context', return_value=fake_context):
                result = execute_result(command(code), 3)
            self.assertEqual((result['exit'],result['failure'],result['stdout']), (0,None,b'published\n'))

    def test_abrupt_owner_exit_without_result_refuses(self):
        def abrupt_exit(connection, *args):
            os._exit(23)
        with mock.patch.object(task_runner, '_worker', abrupt_exit):
            with self.assertRaises(EOFError):
                execute_result(command('print("must not run")'), 3)

    def test_owner_surviving_kill_preserves_failure_result_and_handle(self):
        result = dict(exit=None, failure='child deadline', stdout=b'partial\xff',
                      stderr=b'error\x00', capture='split')
        clock = [0.0]
        cleanup_started = []
        owner = mock.Mock()
        owner.is_alive.return_value = True
        owner.terminate.side_effect = lambda: cleanup_started.append(clock[0])
        def join(timeout=None):
            self.assertIsNotNone(timeout, 'cleanup must never wait indefinitely')
            self.assertGreaterEqual(timeout, 0)
            clock[0] += timeout
        owner.join.side_effect = join
        receiver, sender = mock.Mock(), mock.Mock()
        receiver.poll.return_value = True
        receiver.recv.return_value = result
        context = mock.Mock()
        context.Pipe.return_value = (receiver, sender)
        context.Process.return_value = owner
        with mock.patch.object(task_runner.multiprocessing, 'get_context', return_value=context), \
                mock.patch.object(task_runner.time, 'monotonic', side_effect=lambda: clock[0]):
            with self.assertRaisesRegex(RuntimeError, 'command owner failed to exit') as caught:
                execute_result(command('must not execute'), 3, capture='split')
        error = caught.exception
        self.assertIs(error.result, result)
        self.assertEqual(result['failure'], 'child deadline')
        self.assertEqual((error.stdout, error.stderr), (b'partial\xff', b'error\x00'))
        self.assertRegex(str(error.cleanup_failure), 'survived bounded cleanup')
        self.assertIs(error.owner, owner)
        self.assertIs(error.cleanup_failure.owner, owner)
        owner.terminate.assert_called_once()
        owner.kill.assert_called_once()
        self.assertLessEqual(clock[0] - cleanup_started[0], 4)
        owner.close.assert_not_called()
        receiver.close.assert_called_once()

    def test_owner_surviving_kill_preserves_cancellation(self):
        interruption = KeyboardInterrupt('original cancellation')
        clock = [0.0]
        cleanup_started = []
        owner = mock.Mock()
        owner.is_alive.return_value = True
        owner.terminate.side_effect = lambda: cleanup_started.append(clock[0])
        def join(timeout=None):
            self.assertIsNotNone(timeout, 'cleanup must never wait indefinitely')
            self.assertGreaterEqual(timeout, 0)
            clock[0] += timeout
        owner.join.side_effect = join
        receiver, sender = mock.Mock(), mock.Mock()
        receiver.poll.side_effect = interruption
        context = mock.Mock()
        context.Pipe.return_value = (receiver, sender)
        context.Process.return_value = owner
        with mock.patch.object(task_runner.multiprocessing, 'get_context', return_value=context), \
                mock.patch.object(task_runner.time, 'monotonic', side_effect=lambda: clock[0]):
            with self.assertRaises(KeyboardInterrupt) as caught:
                execute_result(command('must not execute'), 3)
        self.assertIs(caught.exception, interruption)
        self.assertRegex(str(interruption.cleanup_failure), 'survived bounded cleanup')
        self.assertIs(interruption.owner, owner)
        self.assertLessEqual(clock[0] - cleanup_started[0], 4)
        owner.terminate.assert_called_once()
        owner.kill.assert_called_once()
        owner.close.assert_not_called()
        receiver.close.assert_called_once()

    def test_owned_children_share_cleanup_phase_deadline(self):
        clock, observed = [0.0], []
        def traversal(pid, *, deadline=None):
            observed.append((pid, deadline))
            clock[0] += .6
        with mock.patch.object(task_runner, 'child_pids', return_value={101, 102, 103}), \
                mock.patch.object(task_runner, 'kill_descendants', side_effect=traversal), \
                mock.patch.object(task_runner.os, 'waitpid'), \
                mock.patch.object(task_runner.time, 'sleep'), \
                mock.patch.object(task_runner.time, 'monotonic', side_effect=lambda: clock[0]):
            with self.assertRaisesRegex(TimeoutError, 'owned descendants did not terminate'):
                task_runner.cleanup_owned()
        self.assertEqual(len(observed), 2)
        self.assertEqual([deadline for _, deadline in observed], [1, 1])

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
            # Logging/refusal is independent of child startup speed; Execution
            # controls separately exercise real deadlines and partial capture.
            result = {'exit': None, 'failure': 'child deadline',
                      'stdout': b'partial', 'stderr': b'', 'capture': 'split',
                      'runnerSHA256': task_runner.IMPLEMENTATION_SHA256}
            with mock.patch.object(task_runner, 'execute_result', return_value=result) as execute_mock:
                with self.assertRaises(TimeoutError) as caught:
                    runner.run('timeout', command('pass'), .15)
                self.assertIs(caught.exception.result, result)
                self.assertEqual((Path(directory)/'timeout.stdout').read_bytes(), b'partial')
                (Path(directory)/'timeout.stdout').write_bytes(b'fake')
                with self.assertRaises(AssertionError): runner.run('next', command('pass'), 3)
                execute_mock.assert_called_once_with(command('pass'), .15, None, None, 'split')


if __name__ == '__main__':
    unittest.main()
