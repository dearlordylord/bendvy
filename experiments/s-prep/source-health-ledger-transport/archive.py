#!/usr/bin/env python3
"""Archive executed source-bound receipts, including unsuccessful attempts."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent;out=HERE/'evidence';out.mkdir(exist_ok=True)
roots=[Path('/tmp/bendvy-health-ledger-flat-'+x) for x in ['v3', 'reproduced-v3', 'health-build-v1', 'health-build-v2', 'health-build-v3', 'motion-build-v3', 'health-full65-v3', 'motion-full65-v3', 'health-counts-v3', 'tx-v3', 'lost-mark-v3', 'inverse-order-v3', 'boundary-v3', 'retained-cached-v3', 'retained-raw-v3', 'returned-negative-v3', 'returned-ledger-negative-v3', 'static-v3', 'ledger-witness-v3', 'ledger-witness-v4', 'ledger-witness-v5', 'ledger-witness-v6']]
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
