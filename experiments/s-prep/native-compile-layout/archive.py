#!/usr/bin/env python3
"""Archive same-C build/layout/full-field/raw observation receipts, excluding binaries."""
from pathlib import Path
import json,hashlib,tarfile
HERE=Path(__file__).resolve().parent;out=HERE/'evidence';out.mkdir(exist_ok=True)
roots=[Path('/tmp/bendvy-native-layout-'+schema+'-Os-v1') for schema in ('motion','health')]+[Path('/tmp/bendvy-native-layout-'+schema+'-Os-full65-v1') for schema in ('motion','health')]+[Path('/tmp/bendvy-native-layout-Os-tx-canary-v1')]+[Path('/tmp/bendvy-native-layout-Os-'+schema+'-rotation'+str(rotation)+'-v1') for rotation in range(3) for schema in ('motion','health')]
manifest={'scope':'Own same-C binary build/assembly, fullfields and descriptive raw observations; no qualification/adoption','roots':list(map(str,roots)),'files':{}}
archive=out/'same-c-layout-evidence.tar.gz'
with tarfile.open(archive,'w:gz') as tar:
 for root in roots:
  assert root.is_dir(),root
  for path in sorted(root.rglob('*')):
   if not path.is_file() or path.is_symlink() or path.suffix not in ('.json','.jsonl','.txt','.asm','.c','.mjs'):continue
   name=root.name+'/'+str(path.relative_to(root));manifest['files'][name]=hashlib.sha256(path.read_bytes()).hexdigest();tar.add(path,arcname=name,recursive=False)
manifest['archiveSHA256']=hashlib.sha256(archive.read_bytes()).hexdigest();(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(len(manifest['files']),archive.stat().st_size)
