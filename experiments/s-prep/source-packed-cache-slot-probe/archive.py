#!/usr/bin/env python3
import hashlib,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();files={}
for name in ['bendvy-packed-main-slot-motion-v4','bendvy-packed-main-slot-motion-native-full65-v6','bendvy-packed-main-slot-motion-js-full65-v6']:
 root=Path('/tmp')/name
 for p in root.rglob('*'):
  if p.is_file() and p.suffix in ['.bend','.json','.txt','.mjs']:files[name+'/'+str(p.relative_to(root))]=p
for version in range(1,7):
 root=Path('/tmp/bendvy-packed-main-slot-motion-build-v'+str(version))
 for name in ['build.json','check.txt','batch.bend']:
  p=root/name
  if p.exists():files[root.name+'/'+name]=p
root=Path('/tmp/bendvy-packed-main-slot-motion-build-v6')
for name in ['batch.c','batch.js','measurement-bend.bend']:files[root.name+'/'+name]=root/name
manifest={n:{'sourcePath':str(p),'SHA256':sha(p.read_bytes()),'bytes':p.stat().st_size} for n,p in sorted(files.items())};archive=E/'motion-feasibility.tar.gz'
with tarfile.open(archive,'w:gz') as t:
 for n,p in sorted(files.items()):t.add(p,arcname=n,recursive=False)
with tarfile.open(archive,'r:gz') as t:
 assert {m.name for m in t.getmembers()}==set(manifest)
 for m in t.getmembers():assert m.isfile() and sha(t.extractfile(m).read())==manifest[m.name]['SHA256']
(E/'manifest.json').write_text(json.dumps({'status':'ALL_DECODED_SHA256_VERIFIED','archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'members':manifest},indent=2)+'\n');print(len(manifest),archive.stat().st_size)
