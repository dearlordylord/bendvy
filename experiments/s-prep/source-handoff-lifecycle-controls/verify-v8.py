#!/usr/bin/env python3
import hashlib,json,tarfile
from pathlib import Path
p=Path(__file__).resolve().parent;e=json.loads((p/'v8-evidence-index.json').read_text());a=p/'v8-evidence.tar.gz';assert hashlib.sha256(a.read_bytes()).hexdigest()==e['archiveSHA256']
with tarfile.open(a) as t:
 objects={}
 for m in t.getmembers():
  assert m.isfile() and m.name.startswith('objects/') and len(m.name)==72
  b=t.extractfile(m).read();h=hashlib.sha256(b).hexdigest();assert m.name=='objects/'+h;objects[h]=b
 for f in e['files']:assert len(objects[f['SHA256']])==f['bytes']
 for s in e['subjects']:
  r=json.loads(objects[s['receiptSHA256']]);assert r['status']==s['status']
  if s['kind'] in ['positive','mutant']:assert r['candidateClosureSHA256']=='4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235';assert len(s['cases'])==4
assert e['counts']=={'positive':9,'mutant':5,'physical':3,'history':1}
print('Decoded SHA receipts and finite cohort verified; no execution or acceptance inference.')
