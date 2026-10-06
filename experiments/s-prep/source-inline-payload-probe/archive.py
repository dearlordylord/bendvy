#!/usr/bin/env python3
from pathlib import Path
import hashlib,json,tarfile
H=Path(__file__).resolve().parent;out=H/'evidence';out.mkdir(exist_ok=True);roots=[Path('/tmp/bendvy-inline-payload-'+x) for x in ['v1','v2','v3','v4','v5','final-reproduced','motion-build','motion-build-v3','motion-build-v4','motion-build-v5','health-build-v5','motion-full65','health-full65']];m={'scope':'Source-only representation feasibility; failed receipts retained; no full-gate or speed claim','roots':list(map(str,roots)),'files':{}}
with tarfile.open(out/'source-evidence.tar.gz','w:gz') as tar:
 for root in roots:
  if not root.exists():m.setdefault('missing',[]).append(str(root));continue
  for f in sorted(root.rglob('*')):
   if f.is_file() and f.suffix in ('.bend','.json','.txt','.mjs','.c','.js'):
    key=root.name+'/'+str(f.relative_to(root));m['files'][key]=hashlib.sha256(f.read_bytes()).hexdigest();tar.add(f,arcname=key,recursive=False)
m['archiveSHA256']=hashlib.sha256((out/'source-evidence.tar.gz').read_bytes()).hexdigest();(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(len(m['files']))
