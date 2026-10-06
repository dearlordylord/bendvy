#!/usr/bin/env python3
from pathlib import Path
import tarfile,json,hashlib
H=Path(__file__).resolve().parent;entries={};add=lambda p,n:entries.update({n:p}) if p.is_file() else None
core=Path('/tmp/bendvy-packed-paired-journal-both-v3');m=json.loads((core/'overlay.json').read_text())
for n in [*m['sources'],'overlay.json','cache-specialization.json']:add(core/n,'source/'+n)
for lane in ['motion','health']:
 b=Path('/tmp/bendvy-packed-paired-'+lane+'-build-v3')
 for n in ['batch.bend','measurement-bend.bend','batch.c','batch.js','build.json']:add(b/n,'build/'+lane+'/'+n)
 for kind in ['js','native']:
  d=Path('/tmp/bendvy-packed-paired-'+lane+'-'+kind+'-full65-v3');assert json.loads((d/'evidence.json').read_text())['status']=='PASS_FULL65'
  for p in d.iterdir():add(p,'full65/'+lane+'/'+kind+'/'+p.name)
 for label in ['pairs','rollback']:
  d=Path('/tmp/bendvy-packed-paired-'+lane+'-'+label+'-controls-v1');assert json.loads((d/'evidence.json').read_text())['status']=='FINITE_AUTHORED_LITERAL_FULL_FIELDS_BOTH_BACKENDS_PASS'
  for p in d.iterdir():add(p,'controls/'+lane+'/'+label+'/'+p.name)
  for backend in ['JS','Native']:
   for n in ['fixture.bend','subject.js','subject.c']:add(d/backend/n,'controls/'+lane+'/'+label+'/'+backend+'/'+n)
d=Path('/tmp/bendvy-packed-paired-motion-row-controls-v1')
for p in d.iterdir():add(p,'controls/motion/repeated-main/'+p.name)
for label in ['negative-controls','mutants']:
 d=Path('/tmp/bendvy-packed-paired-'+label+'-v1');assert json.loads((d/'evidence.json').read_text())['status'].endswith('PASS') or label=='mutants'
 for p in d.rglob('*'):
  if p.is_file() and (p.suffix in ['.json','.stdout','.stderr'] or p.name in ['runner.py','fixture.bend'] or (label=='mutants' and p.name=='held-adapter.bend')):add(p,'controls/'+label+'/'+str(p.relative_to(d)))
for v in [1,2]:add(Path('/tmp/bendvy-packed-paired-motion-build-v'+str(v))/'build.json','retained-rejection/motion-build-v'+str(v)+'.json')
out=H/'evidence/packed-paired.tar.gz'
with tarfile.open(out,'w:gz') as t:
 for n,p in sorted(entries.items()):t.add(p,arcname=n,recursive=False)
pins={n:hashlib.sha256(p.read_bytes()).hexdigest() for n,p in entries.items()}
with tarfile.open(out,'r:gz') as t:assert {x.name:hashlib.sha256(t.extractfile(x).read()).hexdigest() for x in t.getmembers()}==pins
(H/'evidence/packed-paired-manifest.json').write_text(json.dumps({'scope':'Exact source/build/finite fresh controls, no Tx576 or performance acceptance','archiveSHA256':hashlib.sha256(out.read_bytes()).hexdigest(),'decodedSHA256Verified':True,'members':pins},indent=2)+'\n');print(len(pins),out.stat().st_size)
