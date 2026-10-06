#!/usr/bin/env python3
import hashlib,json,tarfile
from pathlib import Path
P=Path(__file__).resolve().parent/'evidence';index=json.loads((P/'index.json').read_text());assert hashlib.sha256((P/'objects.tar.gz').read_bytes()).hexdigest()==index['archiveSHA256']
with tarfile.open(P/'objects.tar.gz') as t:
 assert len(t.getmembers())==index['objects']
 for record in index['files'].values():
  data=t.extractfile(record['sha256']).read();assert len(data)==record['bytes'] and hashlib.sha256(data).hexdigest()==record['sha256']
print('EXACT_COUNT_EVIDENCE_ARCHIVE_PASS')
