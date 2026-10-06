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
  if s['kind'] in ['positive','mutant']:assert r['candidateClosureSHA256']=='a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55';assert len(s['cases'])==4
assert e['counts']=={'positive':12,'mutant':9,'physical':5,'history':1}
print('Decoded SHA receipts and finite cohort verified; no execution or acceptance inference.')
