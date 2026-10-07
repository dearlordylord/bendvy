"""No-child complete normal-current source/receipt/raw/probe reconciliation."""
from pathlib import Path
import hashlib,json,tarfile
here=Path(__file__).resolve().parent;i=json.loads((here/'index.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();a=here/'objects.tar.gz';assert sha(a.read_bytes())==i['archiveSHA256'];objects={}
with tarfile.open(a) as t:
 for m in t.getmembers():
  assert m.isfile() and m.name not in objects;b=t.extractfile(m).read();assert m.name=='objects/'+sha(b);objects[m.name]=b
assert set(objects)=={'objects/'+r['sha256'] for r in i['records'].values()}
def raw(p):
 r=i['records'][p];b=objects['objects/'+r['sha256']];assert len(b)==r['bytes'] and not b.startswith(b'\x7fELF') and 'private-environment' not in p and '__pycache__' not in p;return b
def load(p):return json.loads(raw(p))
def pin(f,h):assert (sha(raw(f)) if f in i['records'] else i['excludedHashOnly'][f])==h
for p in i['records']:raw(p)
cheap,native=i['cohorts'];oracle=load('/workspace/formal-proofs/bendvy/experiments/public-relations/promotion-stage/current-normal-controls-oracles.json')['outputs'];assert {k:len(v.splitlines()) for k,v in oracle.items()}=={'lifetime':78,'cleanup':50,'large':8}
for folder,status in [(cheap,'CURRENT_NORMAL_LIFETIME_CLEANUP_LARGE_FULL_JS_ORACLE_PASS'),(native,'CURRENT_NORMAL_LIFETIME_CLEANUP_LARGE_FULL_NATIVE_ORACLE_PASS')]:
 p=load(folder+'/plan.json');r=load(folder+'/receipt.json');assert r['status']==status and r['planSHA256']==sha(raw(folder+'/plan.json'));assert len(r['commands'])==9 and all(c['exit']==0 and c['failure'] is None for c in r['commands']);assert [x['label'] for x in r['commands']]==[x['label'] for x in p['commands']]
 for f,h in p.get('pins',p.get('inputs',{})).items():
  if isinstance(h,dict):
   for n,d in h.items():pin(f+'/'+n,d)
  else:pin(f,h)
 for n,h in r['logs'].items():assert sha(raw(folder+'/'+n))==h
 for f,h in r['generated'].items():pin(f,h)
 for c in p['commands']:
  if 'oracle' in c:assert raw(folder+'/'+c['label']+'.stdout').decode()==oracle[c['oracle']] and c['seconds']==5
 for n,h in p.get('inventory',{}).items():pin(p['stage']+'/'+n,h)
p=load(native+'/plan.json');r=load(native+'/receipt.json');assert r['probeCommandsExecuted']==95==len(p['executionProbeLabels']);assert p['cheapReceiptSHA256']==sha(raw(cheap+'/receipt.json'))
for label in p['executionProbeLabels']:
 c=load(native+'/execution-probes/'+label+'.json');assert c['exit']==0 and c['failure'] is None and c['seconds']==5
for name in ['bend','node','python','taskset','clang']:
 c=load(native+'/prepare-probes/prepare-ldd-'+name+'.json');assert c['exit']==0 and c['failure'] is None and c['seconds']==5
assert i['acceptance'] is False and i['completeIssue42'] is False and i['privateEnvironmentExcluded'] is True
print('PASS: exact current normal lifetime66shapes/retained snapshots, cleanup36checkpoints/bound219 and131072large carrier on JS/Native;100 owned probes; development only')
