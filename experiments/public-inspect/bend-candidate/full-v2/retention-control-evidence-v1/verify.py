from pathlib import Path
import hashlib,json,tarfile
here=Path(__file__).resolve().parent;i=json.loads((here/'index.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest();a=here/'objects.tar.gz';assert sha(a.read_bytes())==i['archiveSHA256'];objects={}
with tarfile.open(a) as t:
 for m in t.getmembers():
  assert m.isfile() and m.name not in objects;b=t.extractfile(m).read();assert m.name=='objects/'+sha(b);objects[m.name]=b
assert set(objects)=={'objects/'+r['sha256'] for r in i['records'].values()}
def raw(p):
 r=i['records'][p];b=objects['objects/'+r['sha256']];assert len(b)==r['bytes'] and not b.startswith(b'\x7fELF');return b
def load(p):return json.loads(raw(p))
for p in i['records']:raw(p)
out=str(Path(i['receipt']).parent);r=load(i['receipt']);p=load(out+'/plan.json');assert r['planSHA256']==sha(raw(out+'/plan.json'));assert r['status']=='ACTUAL_SYSTEM_RETENTION_ADVANCEMENT_DISPOSAL_FULL_ORACLE_PASS';assert r['command']=={'exit':0,'failure':None};assert p['capSeconds']==5
for f,h in p['inputs'].items():
 if isinstance(h,dict):
  for n,d in h.items():assert sha(raw(f+'/'+n))==d
 else:assert (sha(raw(f)) if f in i['records'] else i['excludedHashOnly'][f])==h
for n,h in r['logs'].items():assert sha(raw(out+'/'+n))==h
expected=load('/workspace/formal-proofs/bendvy/experiments/public-inspect/bend-candidate/full-v2/retention-control-oracle.json');assert load(out+'/retention-control.stdout')==expected
assert len(expected.splitlines())==12 and expected.count('advanced-removed|counts=0/1|drops=2/0')==2 and expected.count('disposed|counts=0/0|drops=2/2')==2
assert i['acceptance'] is False and i['completeIssue54'] is False
print('PASS: two-schema actual system retainer advancement and disposal, complete12-line interpreted development oracle')
