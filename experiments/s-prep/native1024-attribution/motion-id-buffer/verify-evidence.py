#!/usr/bin/env python3
import hashlib,json,tarfile
from pathlib import Path
P=Path(__file__).resolve().parent/'evidence';index=json.loads((P/'index.json').read_text());assert hashlib.sha256((P/'objects.tar.gz').read_bytes()).hexdigest()==index['archiveSHA256']
seen={}
with tarfile.open(P/'objects.tar.gz') as t:
 for member in t:
  data=t.extractfile(member).read();assert hashlib.sha256(data).hexdigest()==member.name;seen[member.name]=len(data)
assert len(seen)==index['objects']
for record in index['files'].values():assert seen[record['sha256']]==record['bytes']
print('EXACT_SPLIT_ID_COUNT_EVIDENCE_ARCHIVE_PASS')
