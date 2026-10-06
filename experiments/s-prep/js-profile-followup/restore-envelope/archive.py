#!/usr/bin/env python3
"""Small immutable decoded-byte archive; no reference/compiler copies."""
from pathlib import Path
import json,hashlib,tarfile,gzip,io
H=Path(__file__).resolve().parent;D=H/'evidence';D.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();files={}
def add(p,kind):
 p=Path(p);assert p.is_file(),p;assert '/.references/' not in str(p);data=p.read_bytes();digest=sha(data);files.setdefault(digest,{'data':data,'origins':[],'kind':kind})['origins'].append(str(p))
for p in Path('/tmp/bendvy-restore-envelope-frozen-v1').rglob('*'):
 if p.is_file():add(p,'immutable-final-freeze')
for schema in ['motion','health']:
 for suffix in ['full65','count','guards']:
  for p in Path('/tmp/bendvy-restore-envelope-'+schema+'-'+suffix).rglob('*'):
   if p.is_file() and p.suffix in ['.json','.txt']:add(p,'finite-fields-count-refusals')
for suffix in ['controls','controls-v2','controls-final','witness','witness-final','witness-path-final','exceptions','exceptions-v2','exceptions-v3','exceptions-final','mutants','mutants-v2','mutants-final']:
 for p in Path('/tmp/bendvy-restore-envelope-'+suffix).rglob('*'):
  if p.is_file():add(p,'current-controls-and-retained-failures')
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
