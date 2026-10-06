#!/usr/bin/env python3
"""Small immutable decoded-byte archive; no reference/compiler copies."""
from pathlib import Path
import json,hashlib,tarfile,gzip,io
H=Path(__file__).resolve().parent;D=H/'evidence';D.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();files={}
def add(p,kind):
 p=Path(p);assert p.is_file(),p;assert '/.references/' not in str(p);data=p.read_bytes();digest=sha(data);files.setdefault(digest,{'data':data,'origins':[],'kind':kind})['origins'].append(str(p))
for p in Path('/tmp/bendvy-swap-selective-frozen-v1').rglob('*'):
 if p.is_file():add(p,'immutable-selective-positioned-composition-freeze')
for schema in ['motion','health']:
 for suffix in ['full65','count']:
  for p in Path('/tmp/bendvy-swap-selective-'+schema+'-'+suffix).rglob('*'):
   if p.is_file() and p.suffix in ['.json','.txt']:add(p,'fresh65-and-isolated-nine-counts')
for suffix in ['controls','witness','exceptions','live-mutants','scope','bridge-mutants']:
 for p in Path('/tmp/bendvy-swap-selective-'+suffix).rglob('*'):
  if p.is_file():add(p,'actual-controls-refusals-and-retained-failures')
for name in ['evidence','parent-review','independent-route','count-provenance']:
 add(Path('/tmp/bendvy-swap-selective-independent-v1')/(name+'.json'),'independent-fresh-review-receipt')
cat=json.loads((H/'input-pins.json').read_text())
for pin in cat.values():
 add(pin['inputPath'],'exact-parent-program')
 for rel,digest in pin['runtimeSourcePins'].items():
  source=Path(pin['sourceRoot'])/rel;assert sha(source.read_bytes())==digest,source;add(source,'actual-source-closure')
 for p,h in pin['provenancePins'].items():
  assert sha(Path(p).read_bytes())==h,p;add(p,'pinned-provenance')
for p in H.rglob('*'):
 if p.is_file() and '/evidence/' not in str(p):add(p,'owned-recipe-and-report')
manifest={'scope':'Decoded bytes retained; deduplicated by SHA; no acceptance transfer','members':[]}
raw=io.BytesIO()
with tarfile.open(fileobj=raw,mode='w') as tar:
 for digest,v in sorted(files.items()):
  name='bytes/'+digest;info=tarfile.TarInfo(name);info.size=len(v['data']);info.mtime=0;info.mode=0o644;tar.addfile(info,io.BytesIO(v['data']));manifest['members'].append({'member':name,'sha256':digest,'decodedBytes':len(v['data']),'kind':v['kind'],'origins':sorted(set(v['origins']))})
out=D/'evidence.tar.gz';out.write_bytes(gzip.compress(raw.getvalue(),mtime=0));manifest.update(archiveSHA256=sha(out.read_bytes()),archiveBytes=out.stat().st_size);(D/'archive-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({'members':len(files),'archiveBytes':out.stat().st_size,'archiveSHA256':manifest['archiveSHA256']}))
