#!/usr/bin/env python3
import hashlib,json,tarfile
from pathlib import Path
p=Path(__file__).resolve().parent;e=json.loads((p/'evidence-index.json').read_text());a=p/'evidence.tar.gz';assert hashlib.sha256(a.read_bytes()).hexdigest()==e['archiveSHA256']
with tarfile.open(a) as t:
 objects={}
 for m in t.getmembers():
  assert m.isfile() and m.name.startswith('objects/') and len(m.name)==72
  b=t.extractfile(m).read();h=hashlib.sha256(b).hexdigest();assert m.name=='objects/'+h;objects[h]=b
 for f in e['files']:assert len(objects[f['SHA256']])==f['bytes']
 for s in e['subjects']:
  r=json.loads(objects[s['receiptSHA256']]);assert r['status']==s['status']
  if s['kind'] in ['positive','mutant']:assert r.get('candidateClosureSHA256',r.get('sourceClosureSHA256'))=='84b808cee2c1a657569888229241dd95ae59f314025512c20159d951f4a1db2c';assert len(s['cases'])==2
assert e['counts']=={'positive':20,'mutant':10,'physical':5,'history':15}
print('Decoded SHA receipts and finite cohort verified; no execution or acceptance inference.')
