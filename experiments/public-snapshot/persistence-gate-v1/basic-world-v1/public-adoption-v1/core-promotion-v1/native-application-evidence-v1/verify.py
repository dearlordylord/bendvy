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
for folder,js,oracle in [('family-native-v1','family-js-v1','expected-family.json'),('family-mutant-native-v1','family-mutant-js-v1','expected-family-mutant.json')]:
 receipt=json.loads(data['development/'+folder+'/receipt.json']);assert receipt['status']=='DEVELOPMENT_PASS' and receipt['exactFullJsOutputMatch'] is True
 raw=data['development/'+folder+'/consumer.stdout'];assert raw==data['development/'+js+'/consumer.stdout']
 equal(json.loads(raw),json.loads(data['oracle-review-v1/'+oracle]))
 assert data['development/'+folder+'/consumer.stderr']==b''
print('PASS: Native whole normal/mutant oracle and byte-exact JS reports; development scope only')
