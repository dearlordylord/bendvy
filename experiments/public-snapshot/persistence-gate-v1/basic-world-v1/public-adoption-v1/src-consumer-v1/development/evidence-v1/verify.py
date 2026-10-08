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
for label,oracle in [('snapshot','expected.json'),('family','expected-family.json'),('family-mutant','expected-family-mutant.json')]:
 js=data[label+'-js-v1/consumer.stdout'];native=data[label+'-native-v1/consumer.stdout'];assert js==native
 for backend in ['js','native']:
  folder=label+'-'+backend+'-v1';receipt=json.loads(data[folder+'/receipt.json']);assert receipt['status']=='DEVELOPMENT_PASS'
  equal(json.loads(data[folder+'/consumer.stdout']),json.loads(data['oracles/'+oracle]))
  assert data[folder+'/consumer.stderr']==b''
  if backend=='native':assert receipt['exactFullJsOutputMatch'] is True
normal=json.loads(data['family-js-v1/consumer.stdout']);mutant=json.loads(data['family-mutant-js-v1/consumer.stdout'])
for schema in ['Workshop','Garden']:
 normal[schema]['trace']['afterA']['owner']['store']['codec']=mutant[schema]['trace']['afterA']['owner']['store']['codec']
equal(normal,mutant)
delta=json.loads(data['inputs/family-mutant-source-delta.json']);changed=[]
for name,raw in data.items():
 if name.startswith('family-js-v1/sources/'):
  leaf=name.split('/')[-1];other=data['family-mutant-source-v1/'+leaf]
  if raw!=other:
   assert raw.decode().replace(delta['mutation']['old'],delta['mutation']['new'])==other.decode();changed.append(leaf)
assert len(changed)==1
print('PASS: whole actualsrc snapshot/Family/mutant JSNative reports, exact JSNative bytes and sole approved source-copy delta; development only')
