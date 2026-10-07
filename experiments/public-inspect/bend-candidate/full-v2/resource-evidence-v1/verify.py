"""No-child reconciliation of retained full optional-resource observations."""
from pathlib import Path
import hashlib,json,tarfile
here=Path(__file__).resolve().parent;i=json.loads((here/'index.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();a=here/'objects.tar.gz';assert sha(a.read_bytes())==i['archiveSHA256'];objects={}
with tarfile.open(a) as t:
 for m in t.getmembers():
  assert m.isfile() and m.name.startswith('objects/') and m.name not in objects
  b=t.extractfile(m).read();assert m.name=='objects/'+sha(b);objects[m.name]=b
assert set(objects)=={'objects/'+r['sha256'] for r in i['records'].values()}
def raw(p):
 r=i['records'][p];b=objects['objects/'+r['sha256']];assert len(b)==r['bytes'];return b
def load(p):return json.loads(raw(p))
for p in i['records']:raw(p);assert 'private-environment' not in p and '__pycache__' not in p and not raw(p).startswith(b'\x7fELF')
cheap,native,neg=i['cohorts'];oracle=load('/workspace/formal-proofs/bendvy/experiments/public-inspect/bend-candidate/full-v2/resource-oracle.json')
assert len(oracle['ts']['observations'])==24
for folder,planname in [(cheap,'plan.json'),(native,'resource-native-plan.json')]:
 r=load(folder+'/receipt.json');p=load(folder+'/'+planname);assert r['planSHA256']==sha(raw(folder+'/'+planname));assert all(c['exit']==0 and c['failure'] is None for c in r['commands'])
 assert [c['label'] for c in r['commands']]==[c['label'] for c in p['commands']]
 for n,h in r['logs'].items():assert sha(raw(folder+'/'+n))==h
 for f,h in p.get('pins',p.get('inputs',{})).items():
  if isinstance(h,dict):
   for n,digest in h.items():assert sha(raw(f+'/'+n))==digest
  else:assert (sha(raw(f)) if f in i['records'] else i['excludedHashOnly'][f])==h
 for n,h in p.get('inventory',{}).items():assert sha(raw(p['stage']+'/'+n))==h
assert load(cheap+'/resource-ts.stdout')==oracle['ts']
assert load(cheap+'/resource-js.stdout')==oracle['bendText']
assert load(native+'/run-native.stdout')==oracle['bendText']
r=load(native+'/receipt.json');p=load(native+'/resource-native-plan.json');assert r['probeCommandsExecuted']==35==len(p['executionProbeLabels'])
for label in p['executionProbeLabels']:
 c=load(native+'/execution-probes/'+label+'.json');assert c['exit']==0 and c['failure'] is None and c['seconds']==5
for name in ['bend','node','python','taskset','clang']:
 c=load(native+'/prepare-probes/prepare-ldd-'+name+'.json');assert c['exit']==0 and c['failure'] is None
r=load(neg+'/receipt.json');assert len(r['commands'])==7
for c in r['commands']:
 assert c['exit']==1 and c['failure'] is None
 b=raw(neg+'/'+c['label']+'.stderr');assert b'Location: bad' in b and b'- expected :' in b and b'- observed :' in b and b'^' in b
 if c['label']=='duplicate-resource-owner':assert b'consumed more than once' in b
 if c['label'].startswith('write-read'):assert b'Cap.ValueWrite<' in b
for n,h in r['logs'].items():assert sha(raw(neg+'/'+n))==h
assert i['acceptance'] is False and i['completeIssue54'] is False and i['privateEnvironmentExcluded'] is True
print('PASS: complete24 optional-resource TS/JS/Native snapshots; seven intended static refusals;40 owned installed probes; bounded development only')
