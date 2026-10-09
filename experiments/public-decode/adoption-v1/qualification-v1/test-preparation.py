"""No-child admission and full DTO transport refusal controls."""
import copy,hashlib,importlib.util,json,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('runner',HERE/'development-run.py');runner=importlib.util.module_from_spec(spec);spec.loader.exec_module(runner)
t=runner.load('typed',HERE/'transport.py')
oracles=Path('/workspace/formal-proofs/bendvy-worktrees/parity-58-snapshot-research/experiments/public-decode/adoption-v1/qualification-v1/oracle-v1')
observations=[]
for role,definition in runner.ORACLE_FILES.items():
 expected=json.loads((oracles/definition['name']).read_text())
 entry=HERE/'main.bend' if role=='normal' else HERE/'mutants'/('skipped-validator-v1' if role=='skipped' else 'partial-write-v1')/'qualification-v1/main.bend'
 raw=t.render(expected,entry);assert t.parse(raw,entry)==expected
 try:t.parse(raw+b'\n',entry)
 except AssertionError:pass
 else:raise AssertionError('extra LF accepted')
 changed=copy.deepcopy(expected);changed['extension']['decodeOverrides']['sentinel'][-1]=999
 assert t.parse(t.render(changed,entry),entry)!=expected,'last affine sentinel disappeared'
 incomplete=copy.deepcopy(expected);del incomplete['extension']['handleWrongType']
 try:t.render(incomplete,entry)
 except AssertionError:pass
 else:raise AssertionError('missing last extension accepted')
 observations.append({'role':role,'bytes':len(raw),'roundtrip':'PASS','extraLF':'REFUSED','lastSentinelChange':'DETECTED','missingExtension':'REFUSED'})
with tempfile.TemporaryDirectory() as directory:
 plan=Path(directory)/'plan.json';plan.write_bytes(b'{"role":"normal"}\n');digest=hashlib.sha256(plan.read_bytes()).hexdigest()
 assert runner.admitted_plan(plan,digest)=={'role':'normal'}
 for change in ('wrong-digest','plan-drift'):
  if change=='plan-drift':plan.write_bytes(b'{"role":"partial"}\n')
  try:runner.admitted_plan(plan,'0'*64 if change=='wrong-digest' else digest)
  except AssertionError:pass
  else:raise AssertionError(change+' accepted')
print(json.dumps({'scope':'NO_CHILD','transport':observations,'wrongDigest':'REFUSED','planDrift':'REFUSED'}))
