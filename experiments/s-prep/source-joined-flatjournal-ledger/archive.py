#!/usr/bin/env python3
"""Archive executed source-bound receipts, including unsuccessful attempts."""
from pathlib import Path
import hashlib,json,tarfile
HERE=Path(__file__).resolve().parent;out=HERE/'evidence';out.mkdir(exist_ok=True)
roots=[Path('/tmp/bendvy-joined-flatjournal-ledger-'+x) for x in ['v1', 'reproduced-v1', 'health-build-v1', 'motion-build-v1', 'health-full65-v1', 'motion-full65-v1', 'health-counts-v1', 'tx-v1', 'lost-mark-v1', 'inverse-order-v1', 'boundary-v1', 'public-provider-v1', 'retained-cached-v1', 'retained-cached-v2', 'retained-raw-v2', 'returned-main-negative-v2', 'returned-ledger-negative-v2', 'static-v2', 'ledger-witness-v1', 'fallback-v1', 'fallback-mutant-v1']]
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
