#!/usr/bin/env python3
"""Retain descriptive joined-source observations; never qualify noisy clocks."""
import gzip,hashlib,io,json,statistics,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent
OUT=HERE/'evidence'; OUT.mkdir(exist_ok=False)
sha=lambda b:hashlib.sha256(b).hexdigest()
files=set(); summary={}
for schema in ['motion','health']:
 rows=[]
 for rotation in range(7):
  root=Path('/tmp/bendvy-fourhour-joined-ledger-'+schema+'-r'+str(rotation))
  r=json.loads((root/'evidence.json').read_text())
  assert r['status']=='ROTATED_DIAGNOSTIC_ALL_FULL65_WORLDS_PASS'
  rows.append(r)
  files.update(p for p in root.rglob('*') if p.is_file())
 summary[schema]={'receipts':[str(Path('/tmp/bendvy-fourhour-joined-ledger-'+schema+'-r'+str(i))/'evidence.json') for i in range(7)],'phaseMS':[r['phaseMS'] for r in rows]}
 for root in [Path('/tmp/bendvy-flat-journal-'+schema+'-v4'),Path('/tmp/bendvy-joined-flatjournal-ledger-'+schema+'-build-v1')]:
  files.update(root/name for name in ['batch.js','batch.bend','build.json'])
archive=OUT/'exact-observations.tar.gz'; index={}
with archive.open('wb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',mtime=0) as z,tarfile.open(fileobj=z,mode='w') as tar:
 for p in sorted(files):
  assert not p.is_symlink(); b=p.read_bytes(); index[str(p)]={'sha256':sha(b),'bytes':len(b)}
  info=tarfile.TarInfo(str(p).lstrip('/'));info.size=len(b);info.mtime=0;info.mode=0o644;tar.addfile(info,io.BytesIO(b))
with tarfile.open(archive,'r:gz') as t:
 for member in t:
  b=t.extractfile(member).read(); expected=index['/'+member.name];assert len(b)==expected['bytes'] and sha(b)==expected['sha256']
(OUT/'index.json').write_text(json.dumps({'scope':'Unqualified raw observations; unrelated host load and source-identical Motion build variation remain','archiveSHA256':sha(archive.read_bytes()),'decodedPinsVerified':len(index),'files':index},indent=2)+'\n')
(HERE/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({'files':len(index),'compressedBytes':archive.stat().st_size}))
