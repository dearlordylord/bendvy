#!/usr/bin/env python3
"""Archive exact inputs/receipts, deduplicated by bytes; no workload execution."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent; E=H/'evidence';E.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();files=set()
folders=['/tmp/bendvy-query-state-reuse-count-v1','/tmp/bendvy-query-state-reuse-full65-v1','/tmp/bendvy-query-state-reuse-witness-v1','/tmp/bendvy-query-state-reuse-witness-v2','/tmp/bendvy-query-state-reuse-mutants-v1','/tmp/bendvy-query-state-reuse-mutants-v2','/tmp/bendvy-query-state-reuse-guards-v1','/tmp/bendvy-query-state-reuse-controller-admission-v1']
for f in folders:files.update(p for p in Path(f).rglob('*') if p.is_file())
for pin in json.loads((H/'input-pins.json').read_text()).values():
 files.add(Path(pin['inputPath']));files.update(map(Path,pin['files']))
for p in ['/tmp/bendvy-query-state-reuse-motion-v1.js','/tmp/bendvy-query-state-reuse-health-v1.js']:
 files.add(Path(p));files.add(Path(p+'.recipe.json'))
objects={};mapping={}
for p in sorted(files):
 b=p.read_bytes();h=sha(b);mapping[str(p)]={'sha256':h,'bytes':len(b)};objects[h]=b
with tarfile.open(E/'objects.tar.gz','w:gz') as tar:
 for h,b in sorted(objects.items()):
  info=tarfile.TarInfo('objects/'+h);info.size=len(b);info.mtime=0;tar.addfile(info,io.BytesIO(b))
(E/'index.json').write_text(json.dumps({'files':mapping,'objects':len(objects),'archiveSHA256':sha((E/'objects.tar.gz').read_bytes())},indent=2)+'\n')
print(json.dumps({'objects':len(objects),'files':len(mapping),'archiveBytes':(E/'objects.tar.gz').stat().st_size}))
