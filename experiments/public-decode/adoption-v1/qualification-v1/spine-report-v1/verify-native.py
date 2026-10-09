"""No-child exact Native result join from previously emitted spine C."""
import gzip,hashlib,json
from pathlib import Path
import transport
HERE=Path(__file__).resolve().parent;E=HERE/'evidence/native-v1'
sha=lambda x:hashlib.sha256(x).hexdigest()
read=lambda x:gzip.decompress(x.read_bytes())
plan_raw=(E/'plan.json').read_bytes();assert sha(plan_raw)=='1dd7c780947cd55b00d04fec0248c1b29767880b9550f413927b090df25f4611'
plan=json.loads(plan_raw);receipt=json.loads((E/'receipt.json').read_text());joins=json.loads((E/'source-joins.json').read_text())
for alias,row in joins.items():
 p=E/'source-objects'/row['object'];assert p.is_file() and not p.is_symlink() and sha(read(p))==row['sha256']==plan['inputs'][alias]
assert receipt['preparedPlanSha256']==sha(plan_raw) and receipt.get('guardFailures',[])==[] and 'error' not in receipt
assert receipt['status']=='DEVELOPMENT_NATIVE_PASS' and len(receipt['commands'])==2
assert [x['capSeconds'] for x in plan['commands']]==[120,5]
for row,cmd in zip(receipt['commands'],plan['commands']):
 assert all(row[k]==v for k,v in cmd.items()) and row['exit']==0 and row['failure'] is None
 assert row['argv'][:3]==['/usr/bin/taskset','-c','5']
 assert read(E/'raw'/(row['label']+'.stderr.gz'))==b''
assert plan['commands'][1]['argv'][-4:]==['--threads','1','--gpu','off']
assert {p.name for p in (E/'raw').iterdir()}=={k+'.gz' for k in receipt['logs']}
for k,v in receipt['logs'].items():assert sha(read(E/'raw'/(k+'.gz')))==v
assert {p.name for p in (E/'generated').iterdir()}=={Path(k).name+'.gz' for k in receipt['generated']}
for k,v in receipt['generated'].items():assert sha(read(E/'generated'/(Path(k).name+'.gz')))==v
c=read(E/'input.c.gz');assert sha(c)=='2425399baea9e3461b5b281c1ae77c1b5a250dbb02ce60878ad644a1dec7dc7d'==plan['inputs'][plan['commands'][0]['argv'][5]]
def source(suffix):
 rows=[v for k,v in joins.items() if k.endswith(suffix)];assert len(rows)==1
 return read(E/'source-objects'/rows[0]['object'])
expected=json.loads(source('/oracle-v1/spine-report-v1/expected.json'));assert sha(source('/oracle-v1/spine-report-v1/expected.json'))=='26e965901c73e89804b69c1d3d13d10e512478955cb0541f6ccbe8e49693766d'
baseline=source('/oracle-v1/normal-expected.json');assert sha(baseline)=='ca88bdec56290ba3b5460463f59c4ddda389d2dcc7ecfa58d6d633c35016e075'
for p in (HERE/'transport.py',HERE.parent/'transport.py',transport.BASE.PARSER):assert joins[str(p.resolve())]['sha256']==sha(p.read_bytes())
entries=[k for k in joins if k.endswith('/spine-report-v1/main.bend')];assert len(entries)==1
raw=read(E/'raw/complete-run.stdout.gz');oracle=read(E/'expected.stdout.gz')
assert sha(oracle)==plan['inputs']['/tmp/bendvy-decode46-spine-native-v1/expected.stdout']
assert raw==oracle and transport.parse(raw,Path(entries[0]))==expected and transport.whole(expected)==json.loads(baseline)
print(json.dumps({'scope':__doc__,'bytes':len(raw),'rawSha256':sha(raw),'status':receipt['status'],'full46Closure':False,'performanceQualification':False},indent=2))
