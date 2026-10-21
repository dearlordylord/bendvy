#!/usr/bin/env python3
import pathlib
import concurrent.futures
import fcntl
import os
import time
import tempfile
import unittest
from task_runner import run

ROOT = pathlib.Path(__file__).resolve().parents[1]
namespace = {'__name__': 'coordination_test'}
exec(compile((ROOT / 'scripts/check-coordination.py').read_bytes(), 'check-coordination.py', 'exec'), namespace)

class Controls(unittest.TestCase):
    def test_current_table(self):
        self.assertEqual(namespace['check']((ROOT / 'docs/parity/README.md').read_text()), [])
    def test_missing_or_malformed(self):
        self.assertTrue(namespace['check']('No table'))
        self.assertTrue(namespace['check']('| Task | A | B | C | D |\n| wrong | cells |'))
    def test_historical_sprawl(self):
        self.assertTrue(namespace['check']('| Task | A | B | C | D |\n| X | Y | Z | '+ 'a'*1300 +' | N |'))
    def test_pinned_wrapper_ignores_alias(self):
        with tempfile.TemporaryDirectory() as directory:
            base=pathlib.Path(directory)
            (base/'scripts').mkdir(); (base/'experiments/public-simulation/delivery-v1').mkdir(parents=True)
            wrapper=base/'scripts/bend-check'; wrapper.write_bytes((ROOT/'scripts/bend-check').read_bytes())
            compiler=base/'pinned'; compiler.write_text('#!/bin/sh\n[ "$1" = sample.bend ] && [ "$2" = --check-only ]\n'); compiler.chmod(0o755)
            (base/'scripts/installed-config.py').write_text("TOOL_PATHS={'bend':"+repr(str(compiler))+"}\nraise RuntimeError('must not execute config')\n")
            result=run(['/bin/sh',str(wrapper),'sample.bend'],timeout=5,capture_output=True)
            self.assertEqual(result.returncode,0,result.stderr)

    def wrapper_fixture(self, base):
        (base/'scripts').mkdir()
        (base/'experiments/public-simulation/delivery-v1').mkdir(parents=True)
        wrapper=base/'scripts/bend-check'
        wrapper.write_bytes((ROOT/'scripts/bend-check').read_bytes())
        marker=base/'compiler-entered'
        compiler=base/'pinned'
        compiler.write_text('#!/bin/sh\nprintf entered > '+str(marker)+'\nexit 7\n')
        compiler.chmod(0o755)
        (base/'scripts/installed-config.py').write_text(
            'TOOL_PATHS={"bend":'+repr(str(compiler))+'}\n')
        return wrapper, marker

    def test_shared_cpu_waits_before_starting_compiler(self):
        cpu=min(os.sched_getaffinity(0))
        lock=pathlib.Path(f'/tmp/bendvy-source-check-{os.getuid()}-cpu-{cpu}.lock')
        with tempfile.TemporaryDirectory() as directory, lock.open('a') as held:
            wrapper, marker=self.wrapper_fixture(pathlib.Path(directory))
            fcntl.flock(held, fcntl.LOCK_EX)
            inode=os.fstat(held.fileno()).st_ino
            with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
                future=pool.submit(run, ['/usr/bin/taskset','-c',str(cpu),'/bin/sh',str(wrapper),'sample.bend'],
                                   timeout=5,capture_output=True)
                try:
                    deadline=time.monotonic()+2
                    blocked=False
                    while time.monotonic()<deadline:
                        blocked=any('-> FLOCK' in line and str(inode) in line.split()[6]
                                    for line in pathlib.Path('/proc/locks').read_text().splitlines())
                        if blocked or future.done(): break
                        time.sleep(0.01)
                    self.assertTrue(blocked, 'wrapper did not wait on the shared CPU lock')
                    self.assertFalse(marker.exists(), 'compiler started before acquiring its CPU')
                finally:
                    fcntl.flock(held, fcntl.LOCK_UN)
                result=future.result()
            self.assertEqual(result.returncode,7,result.stderr)
            self.assertTrue(marker.exists())
            self.assertIn(b'waiting for source-check CPU',result.stderr)

    def test_lock_survives_compiler_exec(self):
        cpu=min(os.sched_getaffinity(0))
        lock=f'/tmp/bendvy-source-check-{os.getuid()}-cpu-{cpu}.lock'
        with tempfile.TemporaryDirectory() as directory:
            base=pathlib.Path(directory)
            wrapper, _=self.wrapper_fixture(base)
            (base/'pinned').write_text(
                '#!/usr/bin/env python3\nimport fcntl, os\n'
                'fd=os.open('+repr(lock)+',os.O_RDWR)\n'
                'try: fcntl.flock(fd,fcntl.LOCK_EX|fcntl.LOCK_NB)\n'
                'except BlockingIOError: raise SystemExit(7)\n'
                'raise SystemExit(99)\n')
            result=run(['/usr/bin/taskset','-c',str(cpu),'/bin/sh',str(wrapper),'sample.bend'],
                       timeout=5,capture_output=True)
            self.assertEqual(result.returncode,7,result.stderr)

    def test_disjoint_cpu_is_not_blocked(self):
        cpus=sorted(os.sched_getaffinity(0))
        if len(cpus)<2: self.skipTest('requires two allowed CPUs')
        with tempfile.TemporaryDirectory() as directory:
            wrapper, marker=self.wrapper_fixture(pathlib.Path(directory))
            lock=pathlib.Path(f'/tmp/bendvy-source-check-{os.getuid()}-cpu-{cpus[0]}.lock')
            with lock.open('a') as held:
                fcntl.flock(held,fcntl.LOCK_EX)
                result=run(['/usr/bin/taskset','-c',str(cpus[1]),'/bin/sh',str(wrapper),'sample.bend'],
                           timeout=5,capture_output=True)
            self.assertEqual(result.returncode,7,result.stderr)
            self.assertTrue(marker.exists())
            self.assertNotIn(b'waiting for source-check CPU',result.stderr)

if __name__=='__main__': unittest.main()
