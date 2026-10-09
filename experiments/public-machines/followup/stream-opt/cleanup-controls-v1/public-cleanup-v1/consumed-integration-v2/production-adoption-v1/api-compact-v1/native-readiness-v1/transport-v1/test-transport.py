import json,tarfile,types,unittest,copy
from pathlib import Path
HERE=Path(__file__).resolve().parent;V=HERE.parent
f=HERE/'transport.py';m=types.ModuleType('tr');m.__file__=str(f);exec(compile(f.read_bytes(),str(f),'exec'),m.__dict__)
ARCHIVE=Path('/workspace/formal-proofs/bendvy/experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/consumed-integration-v2/production-adoption-v1/delivery-js-v1/cohort.tar.gz')
class Whole(unittest.TestCase):
 def test_four_full_models(self):
  with tarfile.open(ARCHIVE) as archive:
   for case,label in [('post-consumption','post-JS'),('failed-batch','failed-JS'),('post-consumption-mutant','post-mutant-JS'),('failed-batch-mutant','failed-mutant-JS')]:
    with self.subTest(case=case):
     scene=case.removesuffix('-mutant');folder=V/'independent-models'/('mutation-clock-v2/models' if case.endswith('-mutant') else 'models')/scene
     expected=json.loads((folder/'expected.json').read_bytes());name=next(n for n in archive.getnames() if n.startswith(label+'/') and n.endswith('consumer.stdout'));actual=m.Transport(V).normalize(archive.extractfile(name).read().decode())
     m.TERM.strict_equal(actual,expected)
     wrong=copy.deepcopy(actual);wrong['B']['instances'].pop()
     with self.assertRaises(ValueError):m.TERM.strict_equal(wrong,expected)
     wrong=copy.deepcopy(actual);wrong['B']['worlds']['B'].pop()
     with self.assertRaises(ValueError):m.TERM.strict_equal(wrong,expected)
     wrong=copy.deepcopy(actual);last=wrong['B']['worlds']['B'][-1]['fields'];key=list(last)[-1];last[key]=last[key]+'CORRUPTED'
     with self.assertRaises(ValueError):m.TERM.strict_equal(wrong,expected)
 def test_actual_canonical_and_mutant_reach(self):
  core=Path('/workspace/formal-proofs/bendvy/src/ecs')
  for scene in ['post-consumption','failed-batch']:
   normal=json.loads((HERE/(scene+'-inventory.json')).read_bytes())['sourceSHA256']
   self.assertIn(str(core/'system-instance.bend'),normal);self.assertIn(str(core/'system-cleanup.bend'),normal)
   mutant=json.loads((HERE/(scene+'-mutant-inventory.json')).read_bytes())['sourceSHA256']
   local=V/(scene+'-mutant')/'stage/experiments/public-machines/followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs'
   self.assertIn(str(local/'system-instance.bend'),mutant);self.assertIn(str(local/'system-cleanup.bend'),mutant)
   self.assertNotIn(str(core/'system-cleanup.bend'),mutant)
   text=(local/'system-cleanup.bend').read_text();self.assertIn('case Sys.Disposed{world}: Cleaned{changed_clock(~S,~C,~R,~E,remove(world,ports))}',text)
   self.assertIn('case Sys.DisposalRejected{world,registry}: CleanupRejected{world,Instance{registry,ports}}',text)
 def test_six_exact_counterleaves(self):
  def diff(a,b,path=()):
   if type(a)!=type(b):return [path]
   if isinstance(a,dict):
    self.assertEqual(set(a),set(b));return [x for k in a for x in diff(a[k],b[k],path+(k,))]
   if isinstance(a,list):
    self.assertEqual(len(a),len(b));return [x for i,(v,w) in enumerate(zip(a,b)) for x in diff(v,w,path+(i,))]
   return [] if a==b else [path]
  for scene in ['post-consumption','failed-batch']:
   normal=json.loads((V/'independent-models/models'/scene/'expected.json').read_bytes());mutant=json.loads((V/'independent-models/mutation-clock-v2/models'/scene/'expected.json').read_bytes());paths=diff(normal,mutant)
   self.assertEqual(len(paths),6);self.assertTrue(all(x[-1]=='componentClock' for x in paths))
if __name__=='__main__':unittest.main()
