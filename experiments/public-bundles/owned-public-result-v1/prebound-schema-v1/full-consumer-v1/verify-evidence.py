"""No-child lossless archive/plan/receipt/guard verifier, no giant model parsing."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
index=json.loads((HERE/'SEMANTIC-PREPARED-v1.json').read_text())
for label,item in index['plans'].items():
 out=HERE/'evidence-v1'/label
 assert out.is_dir(),"Both full backends mandatory"
 manifest=json.loads((out/'MANIFEST.json').read_text());members={m['original']:m for m in manifest['members']}
 assert {p.name for p in out.iterdir()}=={'MANIFEST.json'}|{m['archive'] for m in members.values()}
 def raw(name):return gzip.decompress((out/members[name]['archive']).read_bytes())
 for m in members.values():
  p=out/m['archive'];assert hashlib.sha256(p.read_bytes()).hexdigest()==m['gzipSHA256'];h=hashlib.sha256();size=0
  with gzip.open(p,'rb')as stream:
   while chunk:=stream.read(1<<20):h.update(chunk);size+=len(chunk)
  assert h.hexdigest()==m['sha256'] and size==m['bytes']
 plan=json.loads(raw('plan.json'));assert members['plan.json']['sha256']==item['sha256']==manifest['executedPlanSHA256']
 receipt=json.loads(raw('receipt.json'));assert receipt['planSHA256']==item['sha256'];assert receipt['status']=='DEVELOPMENT_PASS'
 assert len(receipt['commands'])==len(plan['commands'])
 for actual,expected in zip(receipt['commands'],plan['commands']):
  assert all(actual[k]==v for k,v in expected.items());assert actual['exit']==0 and actual['failure'] is None
  for field in ['stdout','stderr']:
   actualfile=actual[field];member=members[Path(actualfile['path']).name];assert member['sha256']==actualfile['sha256'] and member['bytes']==actualfile['bytes']
  assert actual['stderr']['bytes']==0
 for row in receipt['guards']:
  name=Path(row['path']).name;assert members[name]['sha256']==row['sha256'];guard=json.loads(raw(name));assert guard['unchanged']
  assert all(guard['actualPins'][k]==v for k,v in plan['pins'].items())
  if 'resourceInventory'in plan:assert guard['actualResources']==plan['resourceInventory']
 assert len(receipt['guards'])==1+3*len(plan['commands'])
 assert receipt['wholeOracleSHA256']==plan['expectedSHA256']
 expected=json.loads(raw('independent-expected.json')).encode('utf8')
 assert raw('consumer.stdout')==expected
 assert hashlib.sha256(raw('independent-expected.json')).hexdigest()==plan['expectedSHA256']
 for path,digest in plan['pins'].items():
  source='source:'+path
  if source in members:assert members[source]['sha256']==digest
 print(label,'complete archive/plan/raw/guard joins PASS')
