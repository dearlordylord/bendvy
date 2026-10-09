"""No-child entire retained Node-only cohort and bothbackend fullprojection verifier."""
from pathlib import Path
import gzip,hashlib,json,types
HERE=Path(__file__).parent
m=json.loads((HERE/'evidence-v1/MANIFEST.json').read_bytes());members={r['original']:r for r in m['members']};out=HERE/'evidence-v1'
assert {f.name for f in out.iterdir()}=={'MANIFEST.json'}|{r['archive'] for r in members.values()}
def raw(name):return gzip.decompress((out/members[name]['archive']).read_bytes())
for r in members.values():
 b=(out/r['archive']).read_bytes();assert hashlib.sha256(b).hexdigest()==r['gzipSHA256'];b=gzip.decompress(b);assert len(b)==r['bytes'] and hashlib.sha256(b).hexdigest()==r['sha256']
p=json.loads(raw('plan.json'));r=json.loads(raw('receipt.json'));index=json.loads((HERE/'BACKEND-PREPARED-v1.json').read_bytes());assert members['plan.json']['sha256']==m['executedPlanSHA256']==index['planSHA256']==r['planSHA256'];assert r['status']=='DEVELOPMENT_PASS';assert len(r['commands'])==len(p['commands'])==1
for actual,expected in zip(r['commands'],p['commands']):
 assert all(actual[k]==v for k,v in expected.items());assert actual['exit']==0 and actual['failure'] is None
 for key in ['stdout','stderr']:
  v=actual[key];member=members[Path(v['path']).name];assert member['sha256']==v['sha256'] and member['bytes']==v['bytes']
 assert actual['stderr']['bytes']==0
assert len(r['guards'])==4
for entry in r['guards']:
 name=Path(entry['path']).name;assert members[name]['sha256']==entry['sha256'];g=json.loads(raw(name));assert g['unchanged'];assert all(g['actualPins'][k]==v for k,v in p['pins'].items())
assert r['wholeOracleSHA256']==p['expectedSHA256'];assert raw('consumer.stdout')==(HERE/'oracle-v1/expected.stdout').read_bytes();assert json.loads((HERE/'oracle-v1/expected.json').read_bytes())==raw('consumer.stdout').decode()
result=json.loads((HERE/'ACTUAL-PUBLIC-JOIN.json').read_bytes());f=HERE.parent/'shared-public-join.py';assert hashlib.sha256(f.read_bytes()).hexdigest()==result['joinSourceSHA256'];j=types.ModuleType('join');j.__file__=str(f);exec(compile(f.read_bytes(),str(f),'exec'),j.__dict__)
for kind in ['JS','Native']:
 o=HERE.parent/'registered-lifecycle-v1/evidence-v1'/kind.lower();manifest=json.loads((o/'MANIFEST.json').read_bytes());item=next(v for v in manifest['members'] if v['original']=='consumer.stdout');actual=gzip.decompress((o/item['archive']).read_bytes()).decode();assert j.compare(actual,raw('consumer.stdout').decode())==result['outputs'][kind]
print('Full8member Node cohort + bothentire Bend gates + all20actualpublicprojections PASS; no child')
