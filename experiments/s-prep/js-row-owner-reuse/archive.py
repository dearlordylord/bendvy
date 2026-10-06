#!/usr/bin/env python3
"""Archive exact owned diagnostic inputs/outputs; pins do not imply acceptance."""
import gzip,hashlib,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;OUT=HERE/'evidence';OUT.mkdir(exist_ok=False);sha=lambda b:hashlib.sha256(b).hexdigest()
roots=[Path('/tmp/bendvy-fourhour-row-reuse-controls-v4'),Path('/tmp/bendvy-fourhour-row-reuse-controls-v3'),Path('/tmp/bendvy-fourhour-row-reuse-controls'),Path('/tmp/bendvy-fourhour-row-reuse-guards'),Path('/tmp/bendvy-fourhour-row-counts-v2'),Path('/tmp/bendvy-fourhour-row-snapshots-v3'),Path('/tmp/bendvy-fourhour-row-reuse-health-full65'),Path('/tmp/bendvy-fourhour-row-reuse-motion-full65'),Path('/tmp/bendvy-fourhour-row-reuse-health-profile')]
files=set();catalog=json.loads((HERE/'input-pins.json').read_text())
for pin in catalog.values():
 root=Path(pin['sourceRoot']);files.update(root/n for n in pin['sourcePins'])
 if 'inputPath' in pin:files.add(Path(pin['inputPath']))
for r in roots:files.update(p for p in r.rglob('*') if p.is_file())
for s in ['motion','health']:
 files.update(Path('/tmp/'+n) for n in ['bendvy-fourhour-row-reuse-'+s+'-v2.js','bendvy-fourhour-row-reuse-'+s+'-v2.js.recipe.json','bendvy-fourhour-row-snapshot-'+s+'-original.js','bendvy-fourhour-row-snapshot-'+s+'-reused.js'] if Path('/tmp/'+n).exists())
archive=OUT/'exact-diagnostics.tar.gz';index={}
with archive.open('wb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',mtime=0) as z,tarfile.open(fileobj=z,mode='w') as tar:
 for p in sorted(files):
  assert not p.is_symlink();b=p.read_bytes();index[str(p)]={'sha256':sha(b),'bytes':len(b)};info=tarfile.TarInfo(str(p).lstrip('/'));info.size=len(b);info.mtime=0;info.mode=0o644
  import io
  tar.addfile(info,io.BytesIO(b))
(OUT/'index.json').write_text(json.dumps({'scope':'Exact private emitted diagnostics including failed scaffolds; not adoption, qualification or universal alias proof','archiveSHA256':sha(archive.read_bytes()),'files':index},indent=2)+'\n')
print(json.dumps({'files':len(index),'compressedBytes':archive.stat().st_size}))
