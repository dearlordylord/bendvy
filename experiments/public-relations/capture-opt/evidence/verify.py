"""Validate portable bytes and complete diagnostic artifact bindings; no speed verdict."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent;index=json.loads((HERE/'index.json').read_text())
with tarfile.open(HERE/'objects.tar.gz','r:gz') as tar:
 entries=tar.getmembers();assert all(m.isfile() for m in entries);assert len({m.name for m in entries})==len(entries)
 objects={m.name:tar.extractfile(m).read() for m in entries}
assert set(objects)==set(index['objects'])
for h,b in objects.items():assert hashlib.sha256(b).hexdigest()==h and len(b)==index['objects'][h]
members=index['members'];assert all(h in objects for h in members.values())
receipts=0
for name,h in members.items():
 if not name.endswith('/receipt.json'):continue
 r=json.loads(objects[h]);parent=str(Path(name).parent)
 if r.get('status')=='COMPLETE_CAPTURE_APPLICATION_SEMANTICS_PASS':
  assert len(r['commands'])==10 and all(c['status']=='PASS' and c['exit']==0 and c['failure'] is None for c in r['commands'])
  for group in ['logs','targets']:
   for n,digest in r[group].items():
    if n.endswith('.native'):continue
    assert members[parent+'/'+n]==digest
  receipts+=1
 elif r.get('status')=='COMPLETE_CPU_ALLOCATION_DIAGNOSTICS_PASS_NO_VERDICT':
  assert len(r['runs'])==4 and all(v['validated_records']==600 for v in r['runs'].values())
  for n,digest in r['raw_logs'].items():assert members[parent+'/'+n]==digest
  for role,v in r['runs'].items():assert members[parent+'/'+role+'.profile.json']==v['profile_sha256'] and members[parent+'/'+role+'.mjs']==v['wrapper_sha256']
  receipts+=1
assert receipts==4
print('PASS: four complete semantic/profile receipts, all packaged logs/profiles/wrappers and exact object bytes; excluded binaries retain hashes only')
