#!/usr/bin/env python3
import hashlib,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();files={}
roots=['bendvy-js-joined-journalledger-'+x for x in ['row-controls-v3','pool-controls-v3','scope-v3','guards-v3','snapshots-v3','counts-v2','counts-v3','counts-v4','motion-full65-v3','health-full65-v3']]
for name in roots:
 root=Path('/tmp')/name;assert root.is_dir()
 for p in root.rglob('*'):
  if p.is_file() and p.suffix in ['.json','.txt']:files['receipts/'+name+'/'+str(p.relative_to(root))]=p
for schema in ['motion','health']:
 for name in ['bendvy-joined-flatjournal-ledger-'+schema+'-build-v1/batch.js','bendvy-js-joined-journalledger-'+schema+'-row-v3.js','bendvy-js-joined-journalledger-'+schema+'-pool-v3.js']:
  p=Path('/tmp')/name;files['inputs/'+name]=p;rp=Path(str(p)+'.recipe.json')
  if rp.exists():files['inputs/'+name+'.recipe.json']=rp
 p=Path('/tmp/bendvy-joined-flatjournal-ledger-'+schema+'-build-v1/build.json');files['inputs/'+schema+'-build.json']=p
source=Path('/tmp/bendvy-joined-flatjournal-ledger-v1')
for p in source.rglob('*.bend'):files['source29/'+str(p.relative_to(source))]=p
for n in ['overlay.json','cache-specialization.json']:files['source29/'+n]=source/n
manifest={n:{'sourcePath':str(p),'SHA256':sha(p.read_bytes()),'bytes':p.stat().st_size} for n,p in sorted(files.items())};archive=E/'finite-evidence.tar.gz'
with tarfile.open(archive,'w:gz') as t:
 for n,p in sorted(files.items()):t.add(p,arcname=n,recursive=False)
with tarfile.open(archive,'r:gz') as t:
 assert {m.name for m in t.getmembers()}==set(manifest)
 for m in t.getmembers():assert m.isfile() and sha(t.extractfile(m).read())==manifest[m.name]['SHA256']
(E/'manifest.json').write_text(json.dumps({'status':'ALL_DECODED_SHA256_VERIFIED','archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'members':manifest},indent=2)+'\n');print(len(manifest),archive.stat().st_size)
