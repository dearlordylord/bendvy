#!/usr/bin/env python3
import hashlib,io,json,tarfile
from pathlib import Path
P=Path(__file__).resolve().parent; E=P/'evidence';E.mkdir(exist_ok=True)
files={}
for catalog in [P/'input-pins.json',P/'direct-v1/input-pins.json']:
 for item in json.loads(catalog.read_text()):
  for name,expected in item['files'].items():
   path=Path(name)
   if path.name in ['batch-native','batch.js']:continue
   data=path.read_bytes();assert hashlib.sha256(data).hexdigest()==expected;files[str(path)]=data
  for name,expected in item['sources'].items():
   path=Path(item['sourceRoot'])/name;data=path.read_bytes();assert hashlib.sha256(data).hexdigest()==expected;files[str(path)]=data
for root in ['/tmp/bendvy-native1024-id-buffer-motion-v12','/tmp/bendvy-native1024-id-buffer-motion-direct-v1']:
 for path in Path(root).iterdir():
  if path.is_file() and path.name!='counted-native':files[str(path)]=path.read_bytes()
for path in [P.parent/'transport-count.py',P.parent/'analyze.py',P.parent/'parent-count.py',Path('/tmp/bendvy-native1024-id-buffer-motion-v12.log'),Path('/tmp/bendvy-native1024-id-buffer-motion-direct-v1.log')]:
 files[str(path)]=path.read_bytes()
for path in P.rglob('*'):
 if path.is_file() and E not in path.parents:files[str(path.relative_to(P))]=path.read_bytes()
objects={};index={}
for name,data in files.items():
 sha=hashlib.sha256(data).hexdigest();objects[sha]=data;index[name]={'sha256':sha,'bytes':len(data)}
with tarfile.open(E/'objects.tar.gz','w:gz',compresslevel=6) as tar:
 for sha,data in sorted(objects.items()):
  info=tarfile.TarInfo(sha);info.size=len(data);info.mtime=0;tar.addfile(info,io.BytesIO(data))
(E/'index.json').write_text(json.dumps({'files':index,'objects':len(objects),'archiveSHA256':hashlib.sha256((E/'objects.tar.gz').read_bytes()).hexdigest()},indent=2)+'\n')
print('ARCHIVED',len(files),'files',len(objects),'objects')
