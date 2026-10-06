#!/usr/bin/env python3
"""Archive finite source-bound receipts and fixture inputs; generated binaries reproducible by build.py."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent
out=HERE/'evidence';out.mkdir(exist_ok=False)
roots=[Path('/tmp/bendvy-row-owner-split-reproduced'),Path('/tmp/bendvy-held-flat-both-reproduced-v5')]
names=['motion-build','health-build','motion-counts','health-counts','tx','lost-mark','inverse-order','retained','boundary','static','returned-negative','motion-full65','health-full65']
roots += [Path('/tmp/bendvy-row-owner-split-'+name) for name in names]
manifest={'scope':'Exact current candidate finite receipts and source fixtures; binaries pinned in receipts and reconstructed by recipe','files':{},'roots':list(map(str,roots))}
archive=out/'finite-source-evidence.tar.gz'
with tarfile.open(archive,'w:gz') as tar:
 for root in roots:
  assert root.is_dir(),root
  for path in sorted(root.rglob('*')):
   if not path.is_file() or path.is_symlink():continue
   if path.suffix not in ('.bend','.json','.jsonl','.txt','.mjs'):continue
   if path.name.endswith('.cpuprofile'):continue
   name=root.name+'/'+str(path.relative_to(root));manifest['files'][name]=hashlib.sha256(path.read_bytes()).hexdigest();tar.add(path,arcname=name,recursive=False)
  if root.name.endswith('-build'):
   for name in ('batch.c','batch.js'):
    path=root/name;assert path.is_file();key=root.name+'/'+name;manifest['files'][key]=hashlib.sha256(path.read_bytes()).hexdigest();tar.add(path,arcname=key,recursive=False)
manifest['archiveSHA256']=hashlib.sha256(archive.read_bytes()).hexdigest()
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(len(manifest['files']),archive.stat().st_size,manifest['archiveSHA256'])
