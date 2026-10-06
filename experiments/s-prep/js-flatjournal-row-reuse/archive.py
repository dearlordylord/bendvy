#!/usr/bin/env python3
"""Archive finite diagnostic inputs/receipts and independently verify decoded member hashes."""
import hashlib,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;OUT=HERE/'evidence';OUT.mkdir(exist_ok=False);sha=lambda b:hashlib.sha256(b).hexdigest();files={}
roots=['bendvy-fourhour-flatrow-controls-v2','bendvy-fourhour-flatrow-guards-v2','bendvy-fourhour-flatrow-tokenpool-controls-v2','bendvy-fourhour-flatrow-tokenpool-scope-v2','bendvy-fourhour-flatrow-tokenpool-snapshots-v2','bendvy-fourhour-flatrow-tokenpool-controls-v3','bendvy-fourhour-flatrow-tokenpool-scope-v3','bendvy-fourhour-flatrow-tokenpool-counts-v3']
roots += ['bendvy-fourhour-flatrow-tokenpool-'+s+'-full65-v3-r'+str(r) for s in ['motion','health'] for r in range(3)]
for name in roots:
 root=Path('/tmp')/name;assert root.is_dir(),name
 for p in root.rglob('*'):
  if p.is_file() and p.suffix in ['.json','.txt']:files['receipts/'+name+'/'+str(p.relative_to(root))]=p
for name in ['bendvy-fourhour-flatjournal-health-profile','bendvy-fourhour-flatrow-tokenpool-health-profile-v3']:
 for filename in ['evidence.json','summary.json']:
  p=Path('/tmp')/name/filename;assert p.exists();files['profiles/'+name+'/'+filename]=p
for schema in ['motion','health']:
 for name in ['bendvy-flat-journal-'+schema+'-v4/batch.js','bendvy-fourhour-flatrow-'+schema+'-v2.js','bendvy-fourhour-flatrow-tokenpool-'+schema+'-v3.js']:
  p=Path('/tmp')/name;assert p.is_file(),p;files['inputs/'+name]=p
  rp=Path(str(p)+'.recipe.json')
  if rp.exists():files['inputs/'+name+'.recipe.json']=rp
for p in Path('/tmp/bendvy-flat-journal-v4').rglob('*.bend'):files['source29/'+str(p.relative_to('/tmp/bendvy-flat-journal-v4'))]=p
for name in ['overlay.json','cache-specialization.json']:files['source29/'+name]=Path('/tmp/bendvy-flat-journal-v4')/name
manifest={n:{'sourcePath':str(p),'SHA256':sha(p.read_bytes()),'bytes':p.stat().st_size} for n,p in sorted(files.items())};archive=OUT/'finite-evidence.tar.gz'
with tarfile.open(archive,'w:gz') as t:
 for name,p in sorted(files.items()):t.add(p,arcname=name,recursive=False)
with tarfile.open(archive,'r:gz') as t:
 members=t.getmembers();assert len(members)==len(manifest) and {m.name for m in members}==set(manifest)
 for member in members:assert member.isfile() and sha(t.extractfile(member).read())==manifest[member.name]['SHA256']
(OUT/'manifest.json').write_text(json.dumps({'status':'ALL_DECODED_MEMBER_SHA256_VERIFIED','archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'members':manifest},indent=2)+'\n');print(len(manifest),archive.stat().st_size)
