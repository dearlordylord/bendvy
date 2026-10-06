#!/usr/bin/env python3
import hashlib,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent;E=H/'evidence';E.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();files={}
roots=['bendvy-js-private-fold-'+x for x in ['controls-v1','controls-v2','controls-v3','witnesses-v1','witnesses-v3','returned-context-v3','guards-v3','counts-v1','counts-v3','motion-full65-v1','health-full65-v1','motion-full65-v3','health-full65-v3']]
for name in roots:
 root=Path('/tmp')/name;assert root.is_dir()
 for p in root.rglob('*'):
  if p.is_file() and p.suffix in ['.json','.txt']:files['receipts/'+name+'/'+str(p.relative_to(root))]=p
cat=json.loads((H/'input-pins.json').read_text())
for digest,pin in cat.items():
 source=Path(pin['inputPath']);files['inputs/'+digest+'/pool.js']=source;files['inputs/'+digest+'/pool.js.recipe.json']=Path(str(source)+'.recipe.json')
 for n,h in pin['sourcePins'].items():
  p=Path(pin['sourceRoot'])/n;assert sha(p.read_bytes())==h;files['source-inputs/'+digest+'/'+n]=p
for schema in ['motion','health']:
 p=Path('/tmp/bendvy-js-private-fold-'+schema+'-v3.js');files['final/'+schema+'.js']=p;files['final/'+schema+'.js.recipe.json']=Path(str(p)+'.recipe.json')
manifest={n:{'sourcePath':str(p),'SHA256':sha(p.read_bytes()),'bytes':p.stat().st_size} for n,p in sorted(files.items())};archive=E/'finite-evidence.tar.gz'
with tarfile.open(archive,'w:gz') as t:
 for n,p in sorted(files.items()):t.add(p,arcname=n,recursive=False)
with tarfile.open(archive,'r:gz') as t:
 assert {m.name for m in t.getmembers()}==set(manifest)
 for m in t.getmembers():assert m.isfile() and sha(t.extractfile(m).read())==manifest[m.name]['SHA256']
(E/'manifest.json').write_text(json.dumps({'status':'ALL_DECODED_MEMBER_SHA256_VERIFIED','archiveSHA256':sha(archive.read_bytes()),'archiveBytes':archive.stat().st_size,'members':manifest},indent=2)+'\n');print(len(manifest),archive.stat().st_size)
