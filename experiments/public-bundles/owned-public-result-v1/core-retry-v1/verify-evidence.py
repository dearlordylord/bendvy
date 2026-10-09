"""No-child lossless archive/plan/receipt/guard verifier, no giant model parsing."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
index=json.loads((HERE/'BACKEND-PREPARED-v2.json').read_text())
for item in index['plans']:
 label=item['backend'];out=HERE/'evidence-v1'/label
 if not out.exists():continue
 manifest=json.loads((out/'MANIFEST.json').read_text());members={m['original']:m for m in manifest['members']}
 assert {p.name for p in out.iterdir()}=={'MANIFEST.json'}|{m['archive'] for m in members.values()}
 def raw(name):return gzip.decompress((out/members[name]['archive']).read_bytes())
 for m in members.values():
  p=out/m['archive'];assert hashlib.sha256(p.read_bytes()).hexdigest()==m['gzipSHA256'];h=hashlib.sha256();size=0
  with gzip.open(p,'rb')as stream:
   while chunk:=stream.read(1<<20):h.update(chunk);size+=len(chunk)
  assert h.hexdigest()==m['sha256'] and size==m['bytes']
 plan=json.loads(raw('plan.json'));assert members['plan.json']['sha256']==item['SHA256']==manifest['executedPlanSHA256']
 receipt=json.loads(raw('receipt.json'));assert receipt['planSHA256']==item['SHA256'];assert receipt['status']=='DEVELOPMENT_PASS'
 assert len(receipt['commands'])==len(plan['commands'])
 for actual,expected in zip(receipt['commands'],plan['commands']):
  assert all(actual[k]==v for k,v in expected.items());assert actual['exit']==0 and actual['failure'] is None
  for field in ['stdout','stderr']:
   actualfile=actual[field];member=members[Path(actualfile['path']).name];assert member['sha256']==actualfile['sha256'] and member['bytes']==actualfile['bytes']
  if actual['label']!='emit':assert actual['stderr']['bytes']==0
 for row in receipt['guards']:
  name=Path(row['path']).name;assert members[name]['sha256']==row['sha256'];guard=json.loads(raw(name));assert guard['unchanged']
  assert all(guard['actualPins'][k]==v for k,v in plan['pins'].items())
  if 'resourceInventory'in plan:assert guard['actualResources']==plan['resourceInventory']
 assert len(receipt['guards'])==1+3*len(plan['commands'])
 assert receipt['wholeOracleSHA256']==plan['expectedSHA256']
 expected=(HERE/'oracle-v1/expected.stdout').read_bytes()
 assert raw('consumer.stdout')==expected
 assert json.loads((HERE/'oracle-v1/expected.json').read_bytes())==expected.decode('utf8')
 print(label,'complete archive/plan/raw/guard joins PASS')
