"""No-child complete recorded TS reference observation/source/model joins."""
import gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;E=HERE/'evidence/current-v2'
sha=lambda raw:hashlib.sha256(raw).hexdigest()
read=lambda p:gzip.decompress(p.read_bytes())
plan=json.loads((E/'plan.json').read_text());receipt=json.loads((E/'receipt.json').read_text());binding=json.loads((E/'prepared-plan-v2-digest.json').read_text());joins=json.loads((E/'source-joins.json').read_text())
assert sha((E/'plan.json').read_bytes())==binding['planSha256']==receipt['preparedPlanSha256']=='6528818a13b89db7632bc03eb69a9edf172847c2a371aaa89a3401d2bd0fdb2a'
assert plan['oracleCommit']=='e2a1097a' and plan['oracleSha256']=='3428e431adc007588a59c1efaf4652e06e3bb9d42946b7947e63c1220d488b1d'
assert plan['argv'][:3]==['/usr/bin/taskset','-c','5'] and plan['capSeconds']==5
assert receipt['status']=='DEVELOPMENT_PASS' and receipt.get('guardFailures',[])==[] and 'error' not in receipt
assert receipt['command']['exit']==0 and receipt['command']['failure'] is None and receipt['command']['capture']=='split'
for alias,row in joins.items():
 p=E/'source-objects'/row['object'];assert p.is_file() and not p.is_symlink() and sha(read(p))==row['sha256']
 expected=plan['inputs'].get(alias)
 if expected is not None:assert expected==row['sha256']
 for root,members in plan['inputs'].items():
  if type(members) is dict and alias.startswith(root+'/'):assert members[alias[len(root)+1:]]==row['sha256']
for root,members in plan['inputs'].items():
 if type(members) is dict:assert {k[len(root)+1:]:v['sha256'] for k,v in joins.items() if k.startswith(root+'/')}==members
assert set(p.name for p in (E/'raw').iterdir())=={k+'.gz' for k in receipt['rawHashes']}
for leaf,digest in receipt['rawHashes'].items():assert sha(read(E/'raw'/(leaf+'.gz')))==digest
assert read(E/'raw/reference-run.stderr.gz')==b''
expected=[v for k,v in joins.items() if k.endswith('/oracle-v1/expected-v2.json')];assert len(expected)==1 and expected[0]['sha256']==plan['oracleSha256']
basis=json.loads(read(E/'source-objects'/joins[plan['sourceBasis']]['object']));assert basis['expectedSHA256']==plan['oracleSha256']
for filename,digest in basis['sources'].items():assert joins[filename]['sha256']==digest
runner_alias=[k for k in joins if k.endswith('/reference-v1/run.py')];assert len(runner_alias)==1 and sha((HERE/'run.py').read_bytes())==joins[runner_alias[0]]['sha256']
spec=importlib.util.spec_from_file_location('captured_ts_runner',HERE/'run.py');r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
raw=read(E/'raw/reference-run.stdout.gz');r.strict(json.loads(raw),json.loads(read(E/'source-objects'/expected[0]['object'])))
assert receipt['command']['runnerSHA256']==joins['/workspace/formal-proofs/bendvy/scripts/task_runner.py']['sha256']
assert any(k.startswith('/usr/bin/python3.') for k in plan['inputs'])
print(json.dumps({'status':'COMPLETE_TS_MODEL_PASS','bytes':len(raw),'rawSha256':sha(raw),'sourceAliases':len(joins),'scope':'Original entry development only; no normalization, affine TS ownership, Native delivery, full46 or performance claim'}))
