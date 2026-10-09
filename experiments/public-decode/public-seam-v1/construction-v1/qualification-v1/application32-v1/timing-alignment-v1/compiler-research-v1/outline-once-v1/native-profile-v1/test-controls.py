"""Portable syscall doubles and exact ELF address controls; no target child."""
from pathlib import Path
import hashlib
import json
import os
import signal
import struct
import tempfile
import types
import unittest
from unittest.mock import patch

HERE = Path(__file__).resolve().parent
module = types.ModuleType('sampler_control')
module.__file__ = str(HERE / 'sampler.py')
exec(compile((HERE / 'sampler.py').read_bytes(), module.__file__, 'exec'), module.__dict__)

class FakeTrace:
    def __init__(self, failed=False):
        self.calls = []
        self.failed = failed
    def call(self, operation, tid, **kwargs):
        self.calls.append((operation, tid))
    def pc(self, tid):
        if self.failed:
            raise OSError('GETREGSET failure sentinel')
        return 0x12345678

class Controls(unittest.TestCase):
    def test_resume_after_actual_stopped_register_failure(self):
        trace = FakeTrace(True)
        status = (128 << 16) | (signal.SIGTRAP << 8) | 0x7f
        with self.assertRaisesRegex(OSError, 'sentinel'):
            module.sample_tid(trace, 77, 1000, wait=lambda *args:(77,status), clock=lambda:10)
        self.assertEqual(trace.calls, [(module.INTERRUPT,77),(module.CONT,77)])

    def test_pc_and_stop_overhead_include_resume(self):
        trace = FakeTrace()
        status = (128 << 16) | (signal.SIGTRAP << 8) | 0x7f
        clock = iter([10,20,30,40])
        row = module.sample_tid(trace, 77, 1000, wait=lambda *args:(77,status), clock=lambda:next(clock))
        self.assertEqual(row['pc'],0x12345678)
        self.assertEqual(row['stopOverheadNs'],30)
        self.assertEqual(trace.calls[-1],(module.CONT,77))

    def test_unexpected_signal_stop_refuses_but_resumes(self):
        trace = FakeTrace()
        status = (signal.SIGUSR1 << 8) | 0x7f
        with self.assertRaisesRegex(RuntimeError,'unexpected'):
            module.sample_tid(trace,77,1000,wait=lambda *args:(77,status),clock=lambda:10)
        self.assertEqual(trace.calls[-1],(module.CONT,77))

    def test_interrupt_deadline_does_not_claim_stopped(self):
        trace = FakeTrace()
        clock = iter([10,1000])
        with self.assertRaises(TimeoutError):
            module.sample_tid(trace,77,1000,clock=lambda:next(clock))
        self.assertEqual(trace.calls,[(module.INTERRUPT,77)])

    def test_exact_symbol_ranges_aliases_and_no_suffix_stripping(self):
        rows = module.symbols(b'0000000000001000 0000000000000010 T FID_OWNER_0\n0000000000001000 0000000000000010 t alias\n')
        joined = module.join_pc(0x501009,0x500000,rows)
        self.assertEqual([r['name']for r in joined['symbols']],['FID_OWNER_0','alias'])
        self.assertFalse(module.join_pc(0x501010,0x500000,rows)['matched'])

    def test_pt_load_bias_uses_executable_inode_offset(self):
        with tempfile.TemporaryDirectory() as temporary:
            binary=Path(temporary)/'fixture';binary.write_bytes(b'not executed')
            inode=binary.stat().st_ino
            maps=f'501000-502000 r-xp 00001000 00:00 {inode} {binary}\n'
            loads=[dict(flags=1,offset=0x1000,address=0x1000)]
            self.assertEqual(module.load_bias(maps,loads,binary),0x500000)
            with self.assertRaisesRegex(ValueError,'ambiguous'):
                module.load_bias(maps.replace('r-xp','r--p'),loads,binary)

    def test_raw_publication_existing_and_symlink_refuse(self):
        with tempfile.TemporaryDirectory() as temporary:
            target=Path(temporary)/'raw';target.write_bytes(b'original')
            with self.assertRaises(FileExistsError):module.publish(target,b'replacement')
            self.assertEqual(target.read_bytes(),b'original')
            link=Path(temporary)/'link';link.symlink_to(target)
            with self.assertRaises(FileExistsError):module.publish(link,b'replacement')

    def test_pidfd_kill_cleanup_and_reap_on_exception_path(self):
        calls=[]
        runner=types.SimpleNamespace(cleanup_owned=lambda pid:calls.append(('cleanup',pid)))
        with patch.object(signal,'pidfd_send_signal',side_effect=lambda fd,sig:calls.append(('kill',fd,sig))),patch.object(os,'waitpid',side_effect=lambda pid,flags:calls.append(('reap',pid,flags))):
            module.kill_reap(77,5,runner)
        self.assertEqual(calls,[('kill',5,signal.SIGKILL),('cleanup',77),('reap',77,0)])

    def test_actual_bootstrap_rehashes_captured_helper(self):
        with tempfile.TemporaryDirectory() as temporary:
            root=Path(temporary);(root/'scripts').mkdir()
            helper=root/'scripts/task_runner.py'
            helper.write_text("raise AssertionError('unadmitted helper executed')\n")
            plan_path=root/'plan.json'
            python=str(Path(module.sys.executable).resolve())
            helper_sha=hashlib.sha256(b'pass\n').hexdigest()
            plan={'tools':{'python':python},'pins':{python:'pythonSHA',str(helper):helper_sha}}
            plan_path.write_text(json.dumps(plan))
            plan_sha=hashlib.sha256(plan_path.read_bytes()).hexdigest()
            def fake_sha(path):
                return plan_sha if Path(path)==plan_path else plan['pins'][str(path)]
            with patch.object(module,'ROOT',root),patch.object(module,'sha',side_effect=fake_sha):
                with self.assertRaisesRegex(ValueError,'captured helper source drift'):
                    module.run(plan_path,plan_sha)

    def test_actual_collector_exit_failure_pins_partial_profile_artifacts(self):
        collector=types.ModuleType('collector_control')
        collector.__file__=str(HERE/'development.py')
        exec(compile((HERE/'development.py').read_bytes(),collector.__file__,'exec'),collector.__dict__)
        boundary=types.ModuleType('boundary_control')
        boundary.__file__='/workspace/formal-proofs/bendvy/scripts/evidence_boundary.py'
        exec(compile(Path(boundary.__file__).read_bytes(),boundary.__file__,'exec'),boundary.__dict__)
        with tempfile.TemporaryDirectory() as temporary:
            out=Path(temporary);stage=out/'stage';stage.mkdir()
            native=out/'binary';native.write_bytes(b'never executed')
            generated=out/'generated';generated.write_bytes(b'never compiled')
            python=str(Path(collector.sys.executable).resolve())
            plan={'tools':{'python':python},'pins':{python:collector.sha(python)},
                  'generated':str(generated),'native':str(native),'stage':str(stage),
                  'sourceInventory':{},'importClosure':[],'resourceRoots':{},'environment':{},
                  'cwd':str(out),'scope':'mock exit failure','commands':[{'label':'profile','argv':['not-executed'],'capSeconds':10}]}
            path=out/'plan.json';path.write_text(json.dumps(plan));digest=collector.sha(path)
            def execute(*args):
                (out/'samples.json').write_bytes(b'{"partial":true}')
                (out/'target.stdout').write_bytes(b'partial target bytes')
                return {'exit':1,'failure':None,'stdout':b'failure metadata','stderr':b''}
            runner=types.SimpleNamespace(execute_result=execute,Inputs=lambda **kwargs:types.SimpleNamespace(expected={}))
            with patch.object(collector,'load',side_effect=lambda name,path:runner if name=='task_runner' else boundary),patch.object(collector,'validate_imports',return_value=[]):
                with self.assertRaisesRegex(ValueError,'Owned child failed'):
                    collector.run(path,digest)
            receipt=json.loads((out/'receipt.json').read_text())
            actual=receipt['commands'][0]['diagnosticArtifacts']
            self.assertEqual(set(actual),{'samples.json','target.stdout'})
            self.assertEqual(receipt['status'],'INCOMPLETE')
            guard=json.loads(Path(receipt['guards'][-1]['path']).read_text())
            for artifact in actual.values():
                self.assertEqual(guard['actualPins'][artifact['path']],artifact['sha256'])

if __name__=='__main__':unittest.main()
