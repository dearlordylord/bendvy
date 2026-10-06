#!/usr/bin/env python3
"""Archive exact rotated observations and phase diagnostics, including raw fields."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;OUT=HERE/'evidence';OUT.mkdir(exist_ok=False)
sha=lambda b:hashlib.sha256(b).hexdigest();files=set()
for schema in ['motion','health']:
 for rotation in range(7):
  root=Path('/tmp/bendvy-fourhour-flatjournal-'+schema+'-r'+str(rotation));receipt=json.loads((root/'evidence.json').read_text());assert receipt['status']=='ROTATED_DIAGNOSTIC_ALL_FULL65_WORLDS_PASS';files.update(p for p in root.rglob('*') if p.is_file())
 for root in [Path('/tmp/bendvy-fourhour-flatjournal-'+schema+'-profile')]:files.update(p for p in root.rglob('*') if p.is_file())
 for role in ['baseline','candidate']:
  root=Path('/tmp/bendvy-threehour-fold-noaux-'+schema+'-build') if role=='baseline' else Path('/tmp/bendvy-flat-journal-'+schema+'-v4')
  files.update(root/name for name in ['batch.js','batch.bend','build.json'])
files.update(p for p in Path('/tmp/bendvy-fourhour-flatjournal-health-counts-v2').rglob('*') if p.is_file())
files.update([Path('/tmp/bendvy-fourhour-flatjournal-host-load.txt'),Path('/tmp/bendvy-fourhour-root-flatjournal-source-verification.json')]);archive=OUT/'exact-observations.tar.gz';index={}
with archive.open('wb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',mtime=0) as z,tarfile.open(fileobj=z,mode='w') as tar:
 for p in sorted(files):
  assert not p.is_symlink();b=p.read_bytes();index[str(p)]={'sha256':sha(b),'bytes':len(b)};info=tarfile.TarInfo(str(p).lstrip('/'));info.size=len(b);info.mtime=0;info.mode=0o644;tar.addfile(info,io.BytesIO(b))
(OUT/'index.json').write_text(json.dumps({'scope':'Raw diagnostics under changing unrelated host load; no qualified keep or product acceptance','archiveSHA256':sha(archive.read_bytes()),'files':index},indent=2)+'\n')
print(json.dumps({'files':len(index),'compressedBytes':archive.stat().st_size}))
