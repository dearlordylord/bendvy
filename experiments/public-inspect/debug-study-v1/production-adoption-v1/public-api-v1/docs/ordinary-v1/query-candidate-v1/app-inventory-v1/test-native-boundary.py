import importlib.util
import json
from pathlib import Path
from types import SimpleNamespace
import tempfile
import unittest
from unittest.mock import patch
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('native_inventory',HERE/'development-native.py')
N=importlib.util.module_from_spec(spec);spec.loader.exec_module(N)
ORACLE=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/oracle-v1/app-inventory-v1')
class Boundary(unittest.TestCase):
 def partial(self,failed):
  with tempfile.TemporaryDirectory() as tmp:
   out=Path(tmp)/'cohort';N.prepare(out,ORACLE,'resource');plan=out/'plan.json';p=json.loads(plan.read_text());calls=[]
   def execute(*args):
    label=p['commands'][len(calls)]['label'];calls.append(label)
    target=Path(p['generated'] if label=='emit' else p['native']);target.write_bytes(b'partial '+label.encode())
    return {'exit':1 if label==failed else 0,'failure':'controlled' if label==failed else None,'stdout':b'raw stdout','stderr':b'raw stderr'}
   real=N.load
   def load(name,path):return SimpleNamespace(execute_result=execute,Inputs=real(name,path).Inputs) if name=='task_runner' else real(name,path)
   with patch.object(N,'load',load):
    with self.assertRaisesRegex(ValueError,'Owned child failed: '+failed):N.run(plan,N.sha(plan))
   receipt=json.loads((out/'receipt.json').read_text());self.assertEqual(calls,['emit'] if failed=='emit' else ['emit','build']);self.assertEqual(receipt['commands'][-1]['failure'],'controlled');self.assertNotEqual(receipt.get('status'),'DEVELOPMENT_PASS')
   artifact=Path(p['generated'] if failed=='emit' else p['native'])
   for label in (failed+'-post','final'):
    guard=json.loads((out/(label+'.guard.json')).read_text());self.assertTrue(guard['unchanged']);self.assertEqual(guard['actualPins'][str(artifact)],N.sha(artifact))
 def test_membership_drift_refused_before_child_with_final_receipt(self):
  with tempfile.TemporaryDirectory() as tmp:
   out=Path(tmp)/'cohort';N.prepare(out,ORACLE,'resource');plan=out/'plan.json';p=json.loads(plan.read_text());root=Path(tmp)/'resources';root.mkdir();(root/'seed').write_bytes(b'seed')
   runner=N.load('task_runner',N.ROOT/'scripts/task_runner.py');p['resourceRoots']=[str(root)];p['resourceInventory']=runner.Inputs(directories=[root]).expected;plan.write_text(json.dumps(p));(root/'unexpected').write_bytes(b'new member');calls=[]
   def execute(*args):calls.append(args);raise AssertionError('Child must not run')
   real=N.load
   def load(name,path):return SimpleNamespace(execute_result=execute,Inputs=runner.Inputs) if name=='task_runner' else real(name,path)
   with patch.object(N,'load',load):
    with self.assertRaises(Exception):N.run(plan,N.sha(plan))
   self.assertEqual(calls,[]);receipt=json.loads((out/'receipt.json').read_text());self.assertNotEqual(receipt.get('status'),'DEVELOPMENT_PASS');final=json.loads((out/'final.guard.json').read_text());self.assertFalse(final['unchanged']);self.assertNotEqual(final['actualResources'],p['resourceInventory'])
 def test_failed_emit_partial_c_guarded(self):self.partial('emit')
 def test_failed_build_partial_native_guarded(self):self.partial('build')
# Reuse the existing regular/raw/interpreter controls against this exact helper.
js_spec=importlib.util.spec_from_file_location('native_reused_boundaries',HERE/'test-js-boundary.py')
JS=importlib.util.module_from_spec(js_spec);js_spec.loader.exec_module(JS);JS.N=N
for name in ('test_regular_capture_and_digest','test_linked_capture_refused_without_changing_target','test_nonregular_capture_and_hash_refused','test_actual_interpreter_path_and_hash_drift_refused_before_helpers'):
 setattr(Boundary,name,getattr(JS.Boundary,name))
if __name__=='__main__':unittest.main()
