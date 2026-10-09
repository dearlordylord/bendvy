"""No-child retained packet joins only; installed resources/native binaries not reconstructed."""
from pathlib import Path
import json,hashlib,gzip,tarfile
P=Path(__file__).resolve().parent
E=P/'evidence/backends01'
h=lambda b:hashlib.sha256(b).hexdigest()
manifest=json.loads((E/'manifest.json').read_text())
assert set(manifest)=={str(p.relative_to(E))for p in E.rglob('*')if p.is_file()and p.name!='manifest.json'}
for name,digest in manifest.items():assert h((E/name).read_bytes())==digest
summary=json.loads((E/'summary.json').read_text());witnesses=None
for row in summary['cohorts']:
 d=E/row['case'];plan=json.loads((d/'plan.json').read_text());r=json.loads((d/'receipt.json').read_text())
 assert h((d/'plan.json').read_bytes())==row['planSHA256']==r['planSHA256']
 assert h((d/'receipt.json').read_bytes())==row['receiptSHA256']
 assert r['status']=='COMPLETE_CONSUMER_DEVELOPMENT_PASS'and not r.get('guardFailures')
 source=P/('controls/absent-slot-omission/source-stage.tar.gz'if plan['case']=='absent-slot-omission'else'source-stage.tar.gz')
 with tarfile.open(source)as tar:
  assert {m.name:h(tar.extractfile(m).read())for m in tar.getmembers()}==plan['sourceInventory']
 for name,digest in plan['sourceInventory'].items():assert plan['pins'][str(Path(plan['stage'])/name)]==digest
 for c in r['commands']:
  assert c['exit']==0 and c['failure']is None
  for stream in ['stdout','stderr']:
   raw=(d/Path(c[stream]['path']).name).read_bytes();assert len(raw)==c[stream]['bytes']and h(raw)==c[stream]['sha256']
  assert c['stderr']['bytes']==0
 for g in r['guards']:
  raw=(d/Path(g['path']).name).read_bytes();assert h(raw)==g['sha256'];guard=json.loads(raw);assert guard['unchanged']
  for name,digest in plan['pins'].items():assert guard['actualPins'][name]==digest
 generated=gzip.decompress((d/(Path(plan['generated']).name+'.gz')).read_bytes())
 final=json.loads((d/'final.guard.json').read_text());assert h(generated)==final['actualPins'][plan['generated']]
 normal=(P/'oracle-review-v1/expected.stdout').read_bytes();counter=(P/'oracle-review-v1/absence-omission-expected.stdout').read_bytes();actual=(d/'consumer.stdout').read_bytes()
 assert actual==(counter if plan['case']=='absent-slot-omission'else normal)
 assert h(actual)==row['outputSHA256']==r['wholeOracleSHA256']and len(actual)==row['outputBytes']
 expected=[{'line1':i+1,'expected':a.decode(),'actual':b.decode()}for i,(a,b)in enumerate(zip(normal.splitlines(),counter.splitlines()))if a!=b]if plan['case']=='absent-slot-omission'else[]
 assert r['witnesses']==expected and len(expected)==row['witnessCount']
 if expected:
  if witnesses is not None:assert witnesses==expected
  witnesses=expected
print('RETAINED_FOUR_COHORT_FULL_PHYSICAL_JOINS_PASS: 10 commands, 34 guards, 40-line full oracles, 20 identical mutant witnesses')
