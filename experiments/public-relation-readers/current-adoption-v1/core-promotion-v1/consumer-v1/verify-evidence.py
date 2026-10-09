"""No-child lossless archive/plan/receipt/guard verifier, no giant model parsing."""
import gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
index=json.loads((HERE/'BACKEND-PREPARED-v3.json').read_text())
for item in index['plans']:
 label=item['subject'].replace('/','-')+'-'+item['backend'];out=HERE/'evidence-v1'/label
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
 if item['subject'].startswith('mutants/'):assert receipt['wholeBaselineRejected'] and plan['baselineSHA256']=='1cf4ba67ea13928f6772a42e41c00d5e610cf3e890b1b36906e62b8b0e033e99'
 synthetic=HERE/'capacity-v1/transport-v1/PREPARATION.json' if item['subject']=='capacity-v1' else None
 if synthetic:
  expected=json.loads(synthetic.read_text());assert members['consumer.stdout']['sha256']==expected['rawSHA256'] and members['consumer.stdout']['bytes']==expected['rawBytes']
 print(label,'complete archive/plan/raw/guard joins PASS')
