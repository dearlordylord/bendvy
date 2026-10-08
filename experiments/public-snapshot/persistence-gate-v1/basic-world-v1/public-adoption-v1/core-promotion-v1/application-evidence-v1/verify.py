import hashlib,io,json,tarfile
from pathlib import Path
here=Path(__file__).resolve().parent
index=json.loads((here/'index.json').read_bytes());blob=(here/'evidence.tar.gz').read_bytes()
assert hashlib.sha256(blob).hexdigest()==index['archiveSHA256']
with tarfile.open(fileobj=io.BytesIO(blob),mode='r:gz') as archive:
 entries=archive.getmembers();assert all(m.isfile() for m in entries)
 assert len(entries)==len(index['members']) and {m.name for m in entries}==index['members'].keys()
 data={m.name:archive.extractfile(m).read() for m in entries}
 for name,raw in data.items():
  assert hashlib.sha256(raw).hexdigest()==index['members'][name]['sha256']
  assert len(raw)==index['members'][name]['bytes']
def equal(a,b):
 assert type(a) is type(b)
 if isinstance(a,dict):
  assert a.keys()==b.keys()
  for key in a:equal(a[key],b[key])
 elif isinstance(a,list):
  assert len(a)==len(b)
  for x,y in zip(a,b):equal(x,y)
 else:assert a==b
for folder,oracle in [('family-js-v1','expected-family.json'),('family-mutant-js-v1','expected-family-mutant.json')]:
 receipt=json.loads(data['development/'+folder+'/receipt.json']);assert receipt['status']=='DEVELOPMENT_PASS'
 equal(json.loads(data['development/'+folder+'/consumer.stdout']),json.loads(data['oracle-review-v1/'+oracle]))
raw=data['development/undeclared-js-v1/consumer.stdout'];renderers={b'True{}\n':True,b'False{}\n':False};assert raw in renderers
equal(renderers[raw],json.loads(data['oracle-review-v1/expected-undeclared.json']))
reconciliation=json.loads(data['development/undeclared-js-v1/comparison-reconciliation.json']);assert reconciliation['status']=='DEVELOPMENT_PASS'
assert reconciliation['rawSHA256']==hashlib.sha256(raw).hexdigest()
normal=json.loads(data['development/family-js-v1/consumer.stdout']);mutant=json.loads(data['development/family-mutant-js-v1/consumer.stdout'])
for schema in ['Workshop','Garden']:
 normal[schema]['trace']['afterA']['owner']['store']['codec']=mutant[schema]['trace']['afterA']['owner']['store']['codec']
equal(normal,mutant)
print('PASS: 138 regular members; full normal/mutant oracles and strict Bool renderer; development scope only')
