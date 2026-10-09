"""Portable tiny preimport controls; no backend or private admitted-plan mutation."""
import hashlib,importlib.util,json,tempfile,types,unittest,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent

COLLECTORS = ['run.py']

def module(kind):
 p=HERE/kind;m=types.ModuleType('collector_'+kind);m.__file__=str(p);exec(compile(p.read_bytes(),str(p),'exec'),m.__dict__);return m

class Admission(unittest.TestCase):
 def test_transitive_drift_before_any_load(self):
  for kind in COLLECTORS:
   with self.subTest(kind=kind),tempfile.TemporaryDirectory() as tmp:
    m=module(kind);p=Path(tmp);helper=p/'transitive.py';helper.write_text('raise AssertionError("MUST NOT EXECUTE")\n');python=str(Path(sys.executable).resolve())
    plan={'tools':{'python':python},'pins':{python:m.sha(python),str(helper):'0'*64}};f=p/'plan.json';f.write_text(json.dumps(plan));m.load=lambda *args:(_ for _ in()).throw(AssertionError('runtime reached'))
    with self.assertRaisesRegex(ValueError,'before helper import'):m.run(f,m.sha(f),'source-only control')
 def test_cached_module_ignored(self):
  for kind in COLLECTORS:
   with self.subTest(kind=kind),tempfile.TemporaryDirectory() as tmp:
    m=module(kind);p=Path(tmp)/'source.py';p.write_text('VALUE = 17\n');m.VERIFIED_SOURCES={str(p):p.read_bytes()};cached=types.ModuleType('malicious');cached.VALUE=99;sys.modules['malicious']=cached
    try:self.assertEqual(m.load('malicious',p).VALUE,17)
    finally:del sys.modules['malicious']
 def test_bad_plan_digest_before_import(self):
  for kind in COLLECTORS:
   with self.subTest(kind=kind),tempfile.TemporaryDirectory() as tmp:
    m=module(kind);p=Path(tmp)/'plan.json';p.write_text('{}');m.load=lambda *args:(_ for _ in()).throw(AssertionError('runtime reached'))
    with self.assertRaisesRegex(ValueError,'digest mismatch'):m.run(p,'0'*64,'source-only control')



# The real paired driver must retain and summarize all86 mocked routes. This
# executes no backend; shared ReceiptBoundary is real and the executor is a
# temporary, source-pinned deterministic stub.
class CompleteDriver(unittest.TestCase):
 def fixture(self,tmp,fail_last):
  m=module('run.py');p=Path(tmp);m.ROOT=p
  (p/'scripts').mkdir();root=HERE.resolve().parents[6]
  boundary=p/'scripts/evidence_boundary.py';boundary.write_bytes((root/'scripts/evidence_boundary.py').read_bytes())
  executor=p/'scripts/task_runner.py'
  executor.write_text("import json\ncalls=0\ndef execute_result(argv,cap,env,cwd,mode):\n global calls\n calls+=1\n role=argv[0];raw=(role+'\\n').encode();digest=2166136261\n for byte in raw:digest=((digest^byte)*16777619)&0xffffffff\n meta={'elapsedNs':str({'TS':10,'JS':20,'Native':5}[role]),'bytes':len(raw),'digest':digest}\n return {'exit':1 if "+repr(fail_last)+" and calls==86 else 0,'failure':None,'stdout':raw,'stderr':json.dumps(meta).encode()+b'\\n'}\n")
  sampler=p/'sampling-io.py';sampler.write_bytes((HERE/'sampling-io.py').read_bytes())
  source=(HERE.parent/'transport-v1/transport.py').read_text();metric=source[source.index('\nimport json\n'):]
  roles={};pins={str(f):m.sha(f) for f in [boundary,executor,sampler]}
  for role in ['TS','JS','Native']:
   directory=p/role;directory.mkdir();entry=directory/'entry';entry.write_text(role)
   inventory=directory/'inventory.json';inventory.write_text(json.dumps({'entrypoint':str(entry),'sourceSHA256':{str(entry):m.sha(entry)}}))
   transport=directory/'transport.py';transport.write_text("import json\nfrom pathlib import Path\nclass Transport:\n def __init__(self,entry):self.entry=Path(entry)\n def inventory(self):return json.loads((self.entry.parent/'inventory.json').read_bytes())\n"+metric)
   oracle=directory/'expected.json';oracle.write_text(json.dumps(role+'\n'))
   for f in [entry,inventory,transport,oracle]:pins[str(f)]=m.sha(f)
   roles[role]={'entrypoint':str(entry),'inventory':str(inventory),'transport':str(transport),'oracle':str(oracle),'expectedSHA256':m.sha(oracle),'environment':{},'cwd':str(p)}
  sm=m.load('sampler',sampler);rows=sm.schedule({'pairs':20,'warmups':2,'seed':20261007},[1])
  python=str(Path(sys.executable).resolve());pins[python]=m.sha(python)
  commands=[{'label':row['label'],'role':row['role'],'argv':[row['role']],'capSeconds':5}for row in rows]
  plan={'scope':'mocked no-child driver control','roles':roles,'samplingRows':rows,'samplingHelper':str(sampler),'tools':{'python':python},'pins':pins,'resourceRoots':[],'resourceInventory':{},'wholeCohortLock':str(p/'lock'),'commands':commands}
  file=p/'plan.json';file.write_text(json.dumps(plan));return m,file
 def test_complete86_and_last_failure_receipt(self):
  for failing in [False,True]:
   with self.subTest(failing=failing),tempfile.TemporaryDirectory() as tmp:
    m,p=self.fixture(tmp,failing)
    if failing:
     with self.assertRaisesRegex(ValueError,'Timer consumer failed'):m.run(p,m.sha(p),'source-only mocked cohort')
    else:m.run(p,m.sha(p),'source-only mocked cohort')
    receipt=json.loads((p.parent/'receipt.json').read_bytes());self.assertEqual(len(receipt['commands']),86)
    self.assertTrue(json.loads((p.parent/'final.guard.json').read_bytes())['unchanged'])
    if not failing:
     self.assertEqual(len(receipt['samplingRaw']),86);self.assertEqual(len(receipt['observations']),86)
     self.assertEqual([s['medianPairedRatio']for s in receipt['summary']['summary']],[2,0.5])
     self.assertTrue(all(len(s['allPairs'])==20 for s in receipt['summary']['summary']))

if __name__=='__main__':unittest.main()
