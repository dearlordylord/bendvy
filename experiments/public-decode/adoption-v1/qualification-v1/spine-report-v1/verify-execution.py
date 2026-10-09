"""No-child full spine JS and installed C-emission result verification."""
import gzip,hashlib,json
from pathlib import Path
import transport
HERE=Path(__file__).resolve().parent;E=HERE/'evidence/current-v2'
sha=lambda raw:hashlib.sha256(raw).hexdigest()
read=lambda p:gzip.decompress(p.read_bytes())
joins=json.loads((E/'source-joins.json').read_text());bindings=json.loads((E/'prepared-plan-digests.json').read_text())
for alias,row in joins.items():
 p=E/'source-objects'/row['object'];assert p.is_file() and not p.is_symlink() and sha(read(p))==row['sha256']
for p in (HERE/'transport.py',HERE.parent/'transport.py',transport.BASE.PARSER):
 assert joins[str(p.resolve())]['sha256']==sha(p.read_bytes()),'recorded verifier dependency drift'
expected_rows=[v for k,v in joins.items() if k.endswith('/oracle-v1/spine-report-v1/expected.json')];assert len(expected_rows)==1
expected=json.loads(read(E/'source-objects'/expected_rows[0]['object']))
assert expected_rows[0]['sha256']=='26e965901c73e89804b69c1d3d13d10e512478955cb0541f6ccbe8e49693766d'
baseline_rows=[v for k,v in joins.items() if k.endswith('/oracle-v1/normal-expected.json')];assert len(baseline_rows)==1
baseline=read(E/'source-objects'/baseline_rows[0]['object']);assert sha(baseline)=='ca88bdec56290ba3b5460463f59c4ddda389d2dcc7ecfa58d6d633c35016e075'
assert transport.whole(expected)==json.loads(baseline)
result={}
for name,b in bindings.items():
 d=E/name;plan_raw=(d/'plan.json').read_bytes();assert sha(plan_raw)==b['sha256'];plan=json.loads(plan_raw)
 receipt=json.loads((d/'receipt.json').read_text());assert receipt['preparedPlanSha256']==b['sha256'] and receipt.get('guardFailures',[])==[] and 'error' not in receipt
 assert plan['tools']['bend']=='/home/node/.bend/bin/bend-2.0.35' and plan['tools']['python'] in plan['inputs']
 for alias,row in joins.items():
  if alias in plan['inputs']:assert plan['inputs'][alias]==row['sha256']
 assert {p.name for p in (d/'raw').iterdir()}=={k+'.gz' for k in receipt['logs']}
 for k,v in receipt['logs'].items():assert sha(read(d/'raw'/(k+'.gz')))==v
 assert {p.name for p in (d/'generated').iterdir()}=={Path(k).name+'.gz' for k in receipt['generated']}
 for k,v in receipt['generated'].items():assert sha(read(d/'generated'/(Path(k).name+'.gz')))==v
 assert len(receipt['commands'])==len(plan['commands'])
 for row,cmd in zip(receipt['commands'],plan['commands']):
  assert all(row[k]==v for k,v in cmd.items()) and row['exit']==0 and row['failure'] is None
  assert row['argv'][:3]==['/usr/bin/taskset','-c','5']
  assert read(d/'raw'/(row['label']+'.stderr.gz'))==b''
 entry=Path(plan['commands'][0]['argv'][4]);oracle=read(d/'expected.stdout.gz')
 assert sha(oracle)==plan['inputs'][str(Path(b['path']).parent/'expected.stdout')]
 assert transport.parse(oracle,entry)==expected and transport.render(expected,entry)==oracle
 if name=='js':
  assert receipt['status']=='DEVELOPMENT_JS_PASS' and [c['capSeconds'] for c in plan['commands']]==[30,5]
  actual=read(d/'raw/complete-run.stdout.gz');assert actual==oracle and transport.parse(actual,entry)==expected
  result[name]={'status':receipt['status'],'bytes':len(actual),'rawSha256':sha(actual)}
 else:
  assert name=='cEmit' and receipt['status']=='DEVELOPMENT_C_EMIT_PASS' and [c['capSeconds'] for c in plan['commands']]==[30]
  assert len(receipt['generated'])==1 and list(receipt['generated'])[0].endswith('/complete.c')
  result[name]={'status':receipt['status'],'generatedC':list(receipt['generated'].values())[0]}
print(json.dumps({'cohorts':result,'sourceAliases':len(joins),'NativeRuntimeQualification':False,'full46Closure':False},indent=2))
