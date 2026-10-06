#!/usr/bin/env python3
"""Small immutable decoded-byte archive; no reference/compiler copies."""
from pathlib import Path
import json,hashlib,tarfile,gzip,io
H=Path(__file__).resolve().parent;D=H/'evidence';D.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();files={}
def add(p,kind):
 p=Path(p);assert p.is_file(),p;assert '/.references/' not in str(p);data=p.read_bytes();digest=sha(data);files.setdefault(digest,{'data':data,'origins':[],'kind':kind})['origins'].append(str(p))
for schema in ['motion','health']:
 for p in [Path('/tmp/bendvy-followup-frozen-v2')/(schema+'.js'),Path('/tmp/bendvy-followup-frozen-v2')/(schema+'.js.recipe.json'),Path('/tmp/bendvy-descending-generated-frozen-v1')/(schema+'-tuple.js')]:add(p,'program-and-receipt')
 for suffix in ['full65','count','guards']:
  root=Path('/tmp/bendvy-followup-'+schema+'-'+suffix)
  for p in root.rglob('*'):
   if p.is_file() and (p.suffix in ['.json','.txt']):add(p,'finite-evidence')
 for suffix in ['profile','candidate-profile']:
  root=Path('/tmp/bendvy-followup-'+schema+'-'+suffix)
  for name in ['evidence.json','sampling-evidence.json','heap-summary.json','allocation.heapprofile','JS.cpuprofile','sampled.cjs.recipe.json','bend.js','sampled.cjs']:
   p=root/name
   if p.exists():add(p,'profile-diagnostic')
for suffix in ['controls-final','witness','mutants']:
 for p in Path('/tmp/bendvy-followup-'+suffix).rglob('*'):
  if p.is_file():add(p,'current-controls')
cat=json.loads((H/'input-pins.json').read_text())
for pin in cat.values():
 add(pin['inputPath'],'exact-parent-program')
 for p,h in pin['files'].items():
  assert sha(Path(p).read_bytes())==h,p;add(p,'pinned-provenance')
for p in H.glob('*'):
 if p.is_file() and p.name not in ['archive-manifest.json']:add(p,'owned-recipe-and-report')
manifest={'scope':'Decoded bytes retained; deduplicated by SHA; no acceptance transfer','members':[]}
raw=io.BytesIO()
with tarfile.open(fileobj=raw,mode='w') as tar:
 for digest,v in sorted(files.items()):
  name='bytes/'+digest;info=tarfile.TarInfo(name);info.size=len(v['data']);info.mtime=0;info.mode=0o644;tar.addfile(info,io.BytesIO(v['data']));manifest['members'].append({'member':name,'sha256':digest,'decodedBytes':len(v['data']),'kind':v['kind'],'origins':sorted(set(v['origins']))})
out=D/'evidence.tar.gz';out.write_bytes(gzip.compress(raw.getvalue(),mtime=0));manifest.update(archiveSHA256=sha(out.read_bytes()),archiveBytes=out.stat().st_size);(D/'archive-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({'members':len(files),'archiveBytes':out.stat().st_size,'archiveSHA256':manifest['archiveSHA256']}))
