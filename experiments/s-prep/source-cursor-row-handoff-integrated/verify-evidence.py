#!/usr/bin/env python3
from pathlib import Path
import json,hashlib,tarfile
H=Path(__file__).resolve().parent/'evidence';sha=lambda b:hashlib.sha256(b).hexdigest();index=json.loads((H/'index.json').read_text());assert sha((H/'objects.tar.gz').read_bytes())==index['archiveSHA256'];found={}
with tarfile.open(H/'objects.tar.gz','r:gz') as tar:
 for m in tar.getmembers():
  assert m.isfile() and m.name.startswith('objects/') and len(m.name)==72;b=tar.extractfile(m).read();assert sha(b)==m.name.split('/')[1];found[sha(b)]=len(b)
assert len(found)==index['objects']
for p,v in index['files'].items():assert found[v['sha256']]==v['bytes']
print('EXACT_EVIDENCE_HASHES_PASS')
