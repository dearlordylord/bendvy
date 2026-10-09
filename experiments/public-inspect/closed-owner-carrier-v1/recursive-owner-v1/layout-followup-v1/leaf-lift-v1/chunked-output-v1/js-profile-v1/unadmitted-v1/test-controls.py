"""Portable actual collector failure controls; no Node/Bend child."""
from pathlib import Path
import gzip
import hashlib
import json
import tempfile
import types
import unittest
from unittest.mock import patch

HERE=Path(__file__).resolve().parent
module=types.ModuleType('js_profile_control');module.__file__=str(HERE/'development.py')
exec(compile((HERE/'development.py').read_bytes(),module.__file__,'exec'),module.__dict__)
boundary=types.ModuleType('boundary_control');boundary.__file__='/workspace/formal-proofs/bendvy/scripts/evidence_boundary.py'
exec(compile(Path(boundary.__file__).read_bytes(),boundary.__file__,'exec'),boundary.__dict__)
CPU={'nodes':[{'id':1,'callFrame':{},'children':[]}],'samples':[1],'timeDeltas':[0]}
HEAP={'head':{'id':1,'callFrame':{},'children':[],'selfSize':8192},'samples':[{'nodeId':1,'size':8192}]}
ORACLE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-54-layout-provenance/experiments/public-inspect/closed-owner-carrier-v1/recursive-owner-v1/layout-followup-v1/leaf-lift-v1/complete-expected.txt.gz')

class Controls(unittest.TestCase):
    def test_profile_positive_and_typed_identity_refusals(self):
        module.validate_profile('CPU',CPU);module.validate_profile('allocation',HEAP)
        for kind,profile in [('CPU',dict(CPU,samples=[True])),('CPU',dict(CPU,timeDeltas=[False])),('allocation',dict(HEAP,samples=[{'nodeId':True,'size':8192}])),('allocation',dict(HEAP,samples=[{'nodeId':1,'size':False}]))]:
            with self.assertRaises(ValueError):module.validate_profile(kind,profile)

    def actual_run(self,mode):
        with tempfile.TemporaryDirectory() as temporary:
            out=Path(temporary);stage=out/'stage';stage.mkdir()
            js=out/'existing.js';js.write_bytes(b'never executed')
            python=str(Path(module.sys.executable).resolve());profile=out/'scenario.cpuprofile'
            plan={'tools':{'python':python},'pins':{python:module.sha(python),str(js):module.sha(js),str(ORACLE):module.sha(ORACLE)},
                  'generated':str(js),'native':str(js),'stage':str(stage),'sourceInventory':{},'importClosure':[],
                  'resourceRoots':{},'environment':{},'cwd':str(out),'scope':'mock exact collector',
                  'oracle':str(ORACLE),'oracleBytes':5077477,'profileArtifact':str(profile),'profileKind':'CPU',
                  'commands':[{'label':'consumer','argv':['not-executed'],'capSeconds':5}]}
            path=out/'plan.json';path.write_text(json.dumps(plan));calls=[]
            if mode=='existing':profile.write_bytes(b'original')
            if mode=='symlink':profile.symlink_to(js)
            def execute(*arguments):
                calls.append(arguments)
                if mode=='timeout':
                    profile.write_bytes(b'{"partial":')
                    return {'exit':None,'failure':'child deadline','stdout':b'partial report','stderr':b''}
                profile.write_text(json.dumps(CPU))
                raw=gzip.decompress(ORACLE.read_bytes())
                if mode=='tail-corruption':raw=raw[:-2]+b'X\n'
                return {'exit':0,'failure':None,'stdout':raw,'stderr':b''}
            runner=types.SimpleNamespace(execute_result=execute,Inputs=lambda **kwargs:types.SimpleNamespace(expected={}))
            with patch.object(module,'load',side_effect=lambda name,path:runner if name=='task_runner' else boundary),patch.object(module,'validate_imports',return_value=[]):
                if mode=='positive':module.run(path,module.sha(path))
                else:
                    with self.assertRaises(ValueError):module.run(path,module.sha(path))
            receipt=json.loads((out/'receipt.json').read_text())
            if mode in ('existing','symlink'):
                self.assertEqual(calls,[]);self.assertEqual(receipt['commands'],[])
            else:
                capture=receipt['commands'][0]['profileArtifact']
                self.assertEqual(capture['sha256'],module.sha(profile))
                final=json.loads(Path(receipt['guards'][-1]['path']).read_text())
                self.assertEqual(final['actualPins'][str(profile)],module.sha(profile))
            if mode=='positive':self.assertEqual(receipt['status'],'WHOLE_OUTPUT_WITH_JS_PROFILE_CAPTURED_NOT_BENCHMARK')
            else:self.assertEqual(receipt['status'],'INCOMPLETE')

    def test_full_whole_oracle_positive(self):self.actual_run('positive')
    def test_last_raw_byte_corruption_refuses(self):self.actual_run('tail-corruption')
    def test_timeout_partial_profile_final_guard(self):self.actual_run('timeout')
    def test_existing_profile_no_child(self):self.actual_run('existing')
    def test_symlink_profile_no_child(self):self.actual_run('symlink')

if __name__=='__main__':unittest.main()
