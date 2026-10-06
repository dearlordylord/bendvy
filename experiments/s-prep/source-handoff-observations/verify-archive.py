#!/usr/bin/env python3
"""Check every logical evidence member against archived decoded bytes."""
import argparse,hashlib,json,tarfile
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('archive',type=Path);a=p.parse_args();m=json.loads(a.archive.with_suffix(a.archive.suffix+'.manifest.json').read_text());sha=lambda b:hashlib.sha256(b).hexdigest()
assert m['format']=='sha256-deduplicated-evidence-v1' and m['archiveSHA256']==sha(a.archive.read_bytes())
with tarfile.open(a.archive,'r:*') as t:
 blobs={}
 for member in t.getmembers():
  assert member.isfile() and member.name.startswith('blobs/') and member.name.count('/')==1
  h=member.name.split('/')[1];assert len(h)==64 and h not in blobs;b=t.extractfile(member).read();assert sha(b)==h;blobs[h]=b
assert set(blobs)=={v['SHA256'] for v in m['files'].values()}
for path,v in m['files'].items():assert len(blobs[v['SHA256']])==v['bytes'],path
assert len(m['files'])==m['logicalFiles'] and len(blobs)==m['uniqueBlobs']
print(json.dumps({'status':'ALL_DECODED_SHA256_AND_LOGICAL_LENGTHS_PASS','logicalFiles':len(m['files']),'uniqueBlobs':len(blobs)}))
