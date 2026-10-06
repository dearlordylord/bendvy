#!/usr/bin/env python3
"""Retain exact full65 CPU profiles and current source/transform provenance."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;OUT=HERE/'evidence';OUT.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest();files=set()
for name in ['bendvy-js-direct-tuple-health-phase-profile','bendvy-js-direct-tuple-health-baseline-phase-profile','bendvy-js-cursor-health-phase-profile','bendvy-js-cursor-health-cpu-profile','bendvy-js-cursor-health-gc-separated-profile','bendvy-js-cursor-health-inlining-profile','bendvy-js-descending-motion-firststage-profile']:
 root=Path('/tmp')/name;r=json.loads((root/'evidence.json').read_text());assert r['status']=='PROFILE_AND_FULL65_WORLDS_PASS' or (name=='bendvy-js-cursor-health-phase-profile' and r['status']=='FAILED');files.update(p for p in root.iterdir() if p.is_file())
candidate=Path('/tmp/bendvy-direct-tuple-health-final.js');m=json.loads(Path(str(candidate)+'.recipe.json').read_text());files.update([candidate,Path(str(candidate)+'.recipe.json'),Path('/tmp/bendvy-js-identity-query-health-pool-v3.js')])
files.update(Path(p) for p in m['provenancePins'])
files.update(Path(m['sourceRoot'])/name for name in m['sourcePins'])
files.update(Path(m['sourceRoot'])/name for name in ['overlay.json','cache-specialization.json'])
candidate2=Path('/tmp/bendvy-cursor-generated-health-nested.js');m2=json.loads(Path(str(candidate2)+'.recipe.json').read_text());files.update([candidate2,Path(str(candidate2)+'.recipe.json')]);files.update(Path(p) for p in m2['provenancePins']);files.update(Path(m2['sourceRoot'])/name for name in m2['sourcePins'])
candidate3=Path('/tmp/bendvy-descending-generated-frozen-v1/motion-tuple.js');m3=json.loads(Path(str(candidate3)+'.recipe.json').read_text());files.update([candidate3,Path(str(candidate3)+'.recipe.json')]);files.update(Path(p) for p in m3['provenancePins']);files.update(Path(m3['sourceRoot'])/name for name in m3['sourcePins'])
arc=OUT/'exact-profiles.tar.gz';index={}
with arc.open('wb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',mtime=0) as z,tarfile.open(fileobj=z,mode='w') as t:
 for p in sorted(files):
  assert not p.is_symlink();b=p.read_bytes();index[str(p)]={'sha256':sha(b),'bytes':len(b)};info=tarfile.TarInfo(str(p).lstrip('/'));info.size=len(b);info.mtime=0;info.mode=0o644;t.addfile(info,io.BytesIO(b))
with tarfile.open(arc,'r:gz') as t:
 for m in t:
  b=t.extractfile(m).read();x=index['/'+m.name];assert sha(b)==x['sha256'] and len(b)==x['bytes']
(OUT/'index.json').write_text(json.dumps({'scope':'Instrumented full65 profiles; not elapsed acceptance. Both roles validate current directTuple source and producer chain. GC trace sums are approximate churn, not live heap or peak RSS.','archiveSHA256':sha(arc.read_bytes()),'decodedPinsVerified':len(index),'files':index},indent=2)+'\n');print(len(index),arc.stat().st_size)
