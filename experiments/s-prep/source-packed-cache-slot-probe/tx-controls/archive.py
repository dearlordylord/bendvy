#!/usr/bin/env python3
from pathlib import Path
import tarfile,json,hashlib
H=Path(__file__).resolve().parent;entries={};add=lambda p,n:entries.update({n:p}) if p.is_file() else None
root=Path('/tmp/bendvy-packed-paired-tx-controls-v3');e=json.loads((root/'evidence.json').read_text());assert e['status']=='FRESH_ACTUAL_PACKED_PAIRED_TX_AND_SUPPRESSED_576_PER_BACKEND_PASS';add(root/'evidence.json','tx/evidence.json')
for p in root.glob('*.stdout'):add(p,'tx/'+p.name)
base=Path('/tmp/bendvy-packed-paired-journal-both-v3');m=json.loads((base/'overlay.json').read_text())
for n in [*m['sources'],'overlay.json','cache-specialization.json']:add(base/n,'source/'+n)
for rec in e['programs']:
 core=Path(rec['sourceRoot']);label=rec['label']
 for n in rec['extraPins']:add(core/n,'tx/'+label+'/core/'+n)
 if rec['suppressed']:add(core/'held-adapter.bend','tx/'+label+'/core/held-adapter.bend')
 for n in ['subject.js','subject.c']:add(core.parent/n,'tx/'+label+'/'+n)
for label,root in [('first-positive','/tmp/bendvy-packed-paired-tx-first-v2'),('fallback','/tmp/bendvy-packed-paired-fallback-controls-v1'),('fallback-discard-mutant','/tmp/bendvy-packed-paired-fallback-discard-mutant-v1')]:
 d=Path(root);add(d/'evidence.json',label+'/evidence.json')
 for lane in ['motion','health']:
  for p in (d/lane).glob('*'):add(p,label+'/'+lane+'/'+p.name) if p.name!='native' and p.suffix!='' else None
 if label=='fallback-discard-mutant':add(d/'mutant/experiments/s-integrate/held-adapter.bend',label+'/mutant-held-adapter.bend')
add(H/'decoded-validation-v3.json','decoded-validation-v3.json');out=H/'controls.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,p in sorted(entries.items()):t.add(p,arcname=n,recursive=False)
pins={n:hashlib.sha256(p.read_bytes()).hexdigest() for n,p in entries.items()}
with tarfile.open(out,'r:gz') as t:assert {x.name:hashlib.sha256(t.extractfile(x).read()).hexdigest() for x in t.getmembers()}==pins
(H/'manifest.json').write_text(json.dumps({'scope':'Actual source-bound protected matrix and separate fallback; finite only','archiveSHA256':hashlib.sha256(out.read_bytes()).hexdigest(),'decodedSHA256Verified':True,'members':pins},indent=2)+'\n');print(len(pins),out.stat().st_size)
