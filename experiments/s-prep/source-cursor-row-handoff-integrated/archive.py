#!/usr/bin/env python3
"""Archive exact author-owned sources/receipts; sibling runtime acceptance stays separate."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=True);files=set();sha=lambda b:hashlib.sha256(b).hexdigest()
for version in range(1,8):
 root=Path('/tmp/bendvy-slot-host-handoff-v'+str(version));files.update(f for f in root.rglob('*') if f.is_file())
 d=Path('/tmp/bendvy-slot-host-handoff-v'+str(version)+'-check');files.update(f for f in d.rglob('*') if f.is_file())
for d in ['/tmp/bendvy-handoff-access-v6-r1','/tmp/bendvy-handoff-access-v6-r2','/tmp/bendvy-handoff-access-v7-r1','/tmp/bendvy-handoff-access-v7-health-r1','/tmp/bendvy-slot-host-handoff-v7-recorded-checks']:
 files.update(f for f in Path(d).rglob('*') if f.is_file())
for f in ['/tmp/bendvy-slot-host-handoff-v2-source-audit.json','/tmp/bendvy-slot-host-handoff-v5-source-audit.json','/tmp/bendvy-slot-host-handoff-v7-source-audit.json','/tmp/bendvy-slot-host-handoff-v3-generation-failure.txt']:
 files.add(Path(f))
base=Path('/tmp/bendvy-slot-host-v1');files.update(f for f in base.rglob('*') if f.is_file());objects={};mapping={}
for f in sorted(files):
 b=f.read_bytes();digest=sha(b);objects[digest]=b;mapping[str(f)]={'sha256':digest,'bytes':len(b)}
with tarfile.open(E/'objects.tar.gz','w:gz') as tar:
 for digest,b in sorted(objects.items()):
  n=tarfile.TarInfo('objects/'+digest);n.size=len(b);n.mtime=0;tar.addfile(n,io.BytesIO(b))
(E/'index.json').write_text(json.dumps({'archiveSHA256':sha((E/'objects.tar.gz').read_bytes()),'objects':len(objects),'files':mapping},indent=2)+'\n');print(json.dumps({'objects':len(objects),'files':len(mapping),'archiveBytes':(E/'objects.tar.gz').stat().st_size}))
