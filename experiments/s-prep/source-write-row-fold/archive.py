#!/usr/bin/env python3
"""Archive executed source-bound receipts, including unsuccessful attempts."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent;out=HERE/'evidence';out.mkdir(exist_ok=True)
roots=[Path('/tmp/bendvy-write-row-fold-final-reproduced'),Path('/tmp/bendvy-write-row-fold-v2-reproduced'),Path('/tmp/bendvy-row-owner-split-reproduced')]
names=['motion-v1','motion-v2','health-v2']
roots += [Path('/tmp/bendvy-write-row-fold-'+x) for x in []]
roots += [Path('/tmp/bendvy-write-row-fold-'+x) for x in ['motion-full65-v2','health-full65-v2','motion-counts-v2','health-counts-v2','tx-v2','tx-local-registration-v2','lost-mark-v2','inverse-order-v2','boundary-v2','static-v2','returned-negative-v2','retained-v2','retained-v3','retained-v4','retained-sliced-v1']]
roots += [Path('/tmp/bendvy-write-row-fold-'+x) for x in ['motion-v1','motion-v2','health-v2']]
roots += [Path('/tmp/bendvy-fold-noaux-'+x+'-fresh') for x in ['tx','lost-mark','inverse-order','retained','retained-sliced','returned-negative','boundary']]
manifest={'scope':'Own exact-source finite receipts, including failed/partial gates; no gate transfer or speed acceptance','roots':list(map(str,roots)),'files':{}}
archive=out/'finite-source-evidence.tar.gz'
with tarfile.open(archive,'w:gz') as tar:
 for root in roots:
  if not root.is_dir():manifest.setdefault('missingRoots',[]).append(str(root));continue
  for path in sorted(root.rglob('*')):
   if not path.is_file() or path.is_symlink():continue
   if path.suffix not in ('.bend','.json','.jsonl','.txt','.mjs'):continue
   name=root.name+'/'+str(path.relative_to(root));manifest['files'][name]=hashlib.sha256(path.read_bytes()).hexdigest();tar.add(path,arcname=name,recursive=False)
  if (root/'build.json').exists():
   for name in ('batch.c','batch.js'):
    path=root/name
    if path.is_file():key=root.name+'/'+name;manifest['files'][key]=hashlib.sha256(path.read_bytes()).hexdigest();tar.add(path,arcname=key,recursive=False)
manifest['archiveSHA256']=hashlib.sha256(archive.read_bytes()).hexdigest();(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(len(manifest['files']),archive.stat().st_size)
