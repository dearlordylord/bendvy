#!/usr/bin/env python3
"""Retain raw diagnosis and failed infrastructure attempts, decoded-byte pinned."""
from pathlib import Path
import json,hashlib,tarfile,gzip,io
H=Path(__file__).resolve().parent;sha=lambda b:hashlib.sha256(b).hexdigest();files={}
for directory in ['motion-trace','motion-trace-v2','health-trace','health-trace-v2']:
 for p in Path('/tmp/bendvy-composed-bridge-'+directory).rglob('*'):
  if p.is_file():files[str(p)]=p.read_bytes()
for p in H.iterdir():
 if p.is_file() and p.name not in ['evidence.tar.gz','manifest.json']:files[str(p)]=p.read_bytes()
raw=io.BytesIO();manifest={'scope':'Read-only diagnosis; retained failures are not passing source gates','members':[]};seen=set()
with tarfile.open(fileobj=raw,mode='w') as tar:
 for path,data in sorted(files.items()):
  digest=sha(data);name='bytes/'+digest
  if digest not in seen:
   info=tarfile.TarInfo(name);info.size=len(data);info.mtime=0;info.mode=0o644;tar.addfile(info,io.BytesIO(data));seen.add(digest)
  manifest['members'].append({'origin':path,'member':name,'sha256':digest,'decodedBytes':len(data)})
out=H/'evidence.tar.gz';out.write_bytes(gzip.compress(raw.getvalue(),mtime=0));manifest.update(archiveSHA256=sha(out.read_bytes()),archiveBytes=out.stat().st_size);(H/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({'archiveBytes':out.stat().st_size,'members':len(seen)}))
