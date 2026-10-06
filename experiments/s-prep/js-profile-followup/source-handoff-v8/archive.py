#!/usr/bin/env python3
"""Archive task-owned sources/receipts; external tool and reference bytes remain pins only."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent;dest=H/'evidence';dest.mkdir(exist_ok=True);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();files=set()
for p in H.rglob('*'):
 if p.is_file() and 'evidence' not in p.relative_to(H).parts and '__pycache__' not in p.parts:files.add(p)
S=Path('/tmp/bendvy-slot-host-handoff-v8-coherent');files.update(p for p in S.rglob('*') if p.is_file())
roots=[]
for schema in ['motion','health']:
 roots += [f'/tmp/bendvy-source-handoff-{schema}-build-v8',f'/tmp/bendvy-source-handoff-{schema}-js65-v8',f'/tmp/bendvy-source-handoff-{schema}-native65-v8',f'/tmp/bendvy-source-handoff-{schema}-transformed65-v8',f'/tmp/bendvy-source-handoff-{schema}-route65-v8',f'/tmp/bendvy-source-handoff-{schema}-count-v8']
 roots += [f'/tmp/bendvy-source-handoff-{schema}-route-v8.js',f'/tmp/bendvy-source-handoff-{schema}-route-v8.js.route.json']
roots += ['/tmp/bendvy-source-handoff-generated-v8','/tmp/bendvy-source-handoff-fixture-generated-v8','/tmp/bendvy-source-handoff-packed-witness-v8','/tmp/bendvy-source-handoff-fixture-route-v8','/tmp/bendvy-source-handoff-fixture-mutants-v8','/tmp/bendvy-source-handoff-row-guards-v8.json','/tmp/bendvy-source-handoff-tuple-guards-v8.json','/tmp/bendvy-source-handoff-normal-verify-v8.json']
cat=json.loads((H/'fixtures-pipeline/row-input-pins.json').read_text())
for pin in cat.values():roots += [pin['inputPath'],pin['storedOutput'],*pin['provenancePins'].keys()]
for root in roots:
 p=Path(root)
 if p.is_file():files.add(p)
 elif p.is_dir():files.update(q for q in p.rglob('*') if q.is_file() and q.name not in ['batch-native','fallback-native'])
 else:raise FileNotFoundError(p)
records=[]
with tarfile.open(dest/'evidence.tar.gz','w:gz') as t:
 for p in sorted(files):
  data=p.read_bytes();name=str(p).lstrip('/');info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o644;info.mtime=0;t.addfile(info,io.BytesIO(data));records.append({'path':str(p),'member':name,'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)})
with tarfile.open(dest/'evidence.tar.gz','r:gz') as t:
 for r in records:assert hashlib.sha256(t.extractfile(r['member']).read()).hexdigest()==r['sha256']
(dest/'manifest.json').write_text(json.dumps({'scope':'Task source/build/layer/output evidence only; installed tools, reference trees and Native binaries are not copied','archiveSHA256':sha(dest/'evidence.tar.gz'),'decodedMembers':len(records),'decodedSHA256Verified':True,'files':records},indent=2)+'\n');print(json.dumps({'members':len(records),'archiveBytes':(dest/'evidence.tar.gz').stat().st_size,'decodedSHA256Verified':True}))
