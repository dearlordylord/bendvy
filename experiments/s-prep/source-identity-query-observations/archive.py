#!/usr/bin/env python3
"""Archive raw diagnostic receipts; never qualify noisy clocks."""
import hashlib,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();files={};cases=[]
patterns=['bendvy-fourhour-identity-query-*-v*-r0','bendvy-packed-slot-*-observation-v*-r*','bendvy-packed-paired-*-observation-v*-r*','bendvy-private-cursor-*-observation*']
roots=sorted({p for pattern in patterns for p in Path('/tmp').glob(pattern) if p.is_dir()})
for root in roots:
 r=json.loads((root/'evidence.json').read_text());case={k:r.get(k) for k in ['status','schema','rotation','phaseMS','error','recipeSHA256']};case['directory']=root.name;case['measurementLimit']=json.loads((root/'measurement-limit.json').read_text()) if (root/'measurement-limit.json').exists() else None;cases.append(case)
 for p in root.rglob('*'):
  if p.is_file():files['observations/'+root.name+'/'+str(p.relative_to(root))]=p
 for role,m in r.get('inputs',{}).items():
  for path in m['actualReceiptPins']:
   p=Path(path);files['build-receipts/'+root.name+'/'+role+'/'+p.name]=p
for rootname in ['bendvy-identity-handle-query-v2','bendvy-identity-handle-query-v3','bendvy-packed-main-slot-both-v3','bendvy-packed-paired-journal-both-v3','bendvy-private-id-query-v4','bendvy-private-id-query-descending-v1']:
 root=Path('/tmp')/rootname
 for p in root.rglob('*.bend'):files['sources/'+rootname+'/'+str(p.relative_to(root))]=p
 for n in ['overlay.json','cache-specialization.json']:files['sources/'+rootname+'/'+n]=root/n
for rootname in ['bendvy-packed-main-slot-both-motion-build-v3','bendvy-packed-main-slot-both-health-build-v3']:
 root=Path('/tmp')/rootname
 for p in root.glob('*.json'):files['packed-receipts/'+rootname+'/'+p.name]=p
manifest={n:{'sourcePath':str(p),'SHA256':sha(p.read_bytes()),'bytes':p.stat().st_size}for n,p in sorted(files.items())};archive=E/'raw-observations.tar.gz'
with tarfile.open(archive,'w:gz')as t:
 for n,p in sorted(files.items()):t.add(p,arcname=n,recursive=False)
with tarfile.open(archive,'r:gz')as t:
 assert {m.name for m in t.getmembers()}==set(manifest)
 for m in t.getmembers():assert m.isfile()and sha(t.extractfile(m).read())==manifest[m.name]['SHA256']
(E/'manifest.json').write_text(json.dumps({'status':'ALL_DECODED_SHA256_VERIFIED','archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'members':manifest},indent=2)+'\n')
(H/'summary.json').write_text(json.dumps({'scope':'Raw descriptive source-bound observations only; no keep/noise/product qualification','cases':cases},indent=2)+'\n');print(len(manifest),archive.stat().st_size)
