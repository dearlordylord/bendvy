#!/usr/bin/env python3
"""Retain exact full65 CPU profiles and current source/transform provenance."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;OUT=HERE/'evidence';OUT.mkdir(exist_ok=False)
sha=lambda b:hashlib.sha256(b).hexdigest();files=set()
for name in ['bendvy-fourhour-flatrowpool-health-full65-profile','bendvy-fourhour-flatrowpool-health-full65-profile-v2','bendvy-fourhour-joined-rowpool-health-full65-profile']:
 root=Path('/tmp')/name;r=json.loads((root/'evidence.json').read_text());assert r['status']=='PROFILE_AND_FULL65_WORLDS_PASS';files.update(p for p in root.iterdir() if p.is_file())
for pin in json.loads((HERE/'input-pins.json').read_text()).values():
 files.update(Path(pin[k]) for k in ['inputPath','poolReceiptPath','rowReceiptPath'])
 files.update(Path(pin['sourceRoot'])/name for name in pin['sourcePins'])
 files.update(Path(pin['sourceRoot'])/name for name in ['overlay.json','cache-specialization.json'])
arc=OUT/'exact-profiles.tar.gz';index={}
with arc.open('wb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',mtime=0) as z,tarfile.open(fileobj=z,mode='w') as t:
 for p in sorted(files):
  assert not p.is_symlink();b=p.read_bytes();index[str(p)]={'sha256':sha(b),'bytes':len(b)};info=tarfile.TarInfo(str(p).lstrip('/'));info.size=len(b);info.mtime=0;info.mode=0o644;t.addfile(info,io.BytesIO(b))
with tarfile.open(arc,'r:gz') as t:
 for m in t:
  b=t.extractfile(m).read();x=index['/'+m.name];assert sha(b)==x['sha256'] and len(b)==x['bytes']
(OUT/'index.json').write_text(json.dumps({'scope':'Instrumented full65 profiles; not elapsed acceptance. Initial flat run predates in-recipe provenance guard; v2 and joined have current guard.','archiveSHA256':sha(arc.read_bytes()),'decodedPinsVerified':len(index),'files':index},indent=2)+'\n');print(len(index),arc.stat().st_size)
