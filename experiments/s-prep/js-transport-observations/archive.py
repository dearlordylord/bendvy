#!/usr/bin/env python3
"""Archive exact descriptive observations and actual transform provenance."""
import hashlib,io,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest();files={};cases=[]
patterns=['bendvy-js-direct-tuple-*-observation*','bendvy-js-packed-paired-*-observation*','bendvy-js-cursor-*-observation*','bendvy-js-cursor-*-joined*']
for root in sorted({p for pattern in patterns for p in Path('/tmp').glob(pattern) if p.is_dir()}):
 r=json.loads((root/'evidence.json').read_text());case={k:r.get(k) for k in ['status','schema','rotation','phaseMS','error','recipeSHA256']};case['directory']=root.name
 case['measurementLimit']=json.loads((root/'measurement-limit.json').read_text()) if (root/'measurement-limit.json').exists() else None;cases.append(case)
 for p in root.rglob('*'):
  if p.is_file():files[str(p)]=p
 for n,h in r.get('inputs',{}).get('producerPins',{}).items():
  p=Path(n);assert sha(p.read_bytes())==h;files[str(p)]=p
 for n,h in r.get('inputs',{}).get('sourcePins',{}).items():
  for source in ['bendvy-identity-handle-query-v3','bendvy-packed-paired-journal-both-v3','bendvy-private-id-query-v4','bendvy-private-id-query-descending-v1']:
   p=Path('/tmp')/source/n
   if p.exists() and sha(p.read_bytes())==h:files[str(p)]=p;break
  else:raise AssertionError(n)
for pattern in ['bendvy-direct-tuple-*-final.js*','bendvy-direct-tuple-*-nested.js*','bendvy-cursor-generated-*-nested.js*','bendvy-js-identity-query-*-pool-v3.js*','bendvy-descending-generated-*-nested.js*','bendvy-unused-row-*.js*','bendvy-cursor-state-*.js*','bendvy-u32-sum-*.js*']:
 for p in Path('/tmp').glob(pattern):
  if p.is_file():files[str(p)]=p
for root in [Path('/tmp/bendvy-packed-paired-generated-frozen-v1'),Path('/tmp/bendvy-constant-swap-controls-frozen'),Path('/tmp/bendvy-descending-generated-frozen-v1')]:
 for p in root.rglob('*'):
  if p.is_file():files[str(p)]=p
for p in (H.parent/'js-constant-swap').glob('*.json'):files[str(p)]=p
for p in (H.parent/'js-constant-swap').glob('*.cjs'):files[str(p)]=p
files={str(p.resolve()):p.resolve() for p in files.values()}
archive=E/'exact-observations.tar.gz';manifest={n:{'SHA256':sha(p.read_bytes()),'bytes':p.stat().st_size} for n,p in sorted(files.items())}
with tarfile.open(archive,'w:gz') as t:
 for n,p in sorted(files.items()):t.add(p,arcname=n.lstrip('/'),recursive=False)
with tarfile.open(archive,'r:gz') as t:
 assert set('/'+m.name for m in t.getmembers())==set(manifest)
 for m in t:assert m.isfile() and sha(t.extractfile(m).read())==manifest['/'+m.name]['SHA256']
(E/'manifest.json').write_text(json.dumps({'status':'ALL_DECODED_SHA256_VERIFIED','archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'members':manifest},indent=2)+'\n')
(H/'summary.json').write_text(json.dumps({'scope':'Raw full65 descriptive comparisons; no qualification or product acceptance','cases':cases},indent=2)+'\n');print(len(manifest),archive.stat().st_size)
