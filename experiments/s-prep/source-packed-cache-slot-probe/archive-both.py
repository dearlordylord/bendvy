#!/usr/bin/env python3
from pathlib import Path
import tarfile,hashlib,json
H=Path(__file__).resolve().parent;out=H/'evidence/both-feasibility.tar.gz';entries={}
def add(p,label):
 if p.is_file():entries[label]=p
root=Path('/tmp/bendvy-packed-main-slot-both-v3');m=json.loads((root/'overlay.json').read_text())
for n in [*m['sources'],'overlay.json','cache-specialization.json']:add(root/n,'source/'+n)
for lane in ['motion','health']:
 build=Path('/tmp/bendvy-packed-main-slot-both-'+lane+'-build-v3')
 for n in ['build.json','batch.bend','measurement-bend.bend','batch.c','batch.js']:add(build/n,'build/'+lane+'/'+n)
 for kind in ['native','js']:
  folder=Path('/tmp/bendvy-packed-main-slot-both-'+lane+'-'+kind+'-full65-v3')
  assert json.loads((folder/'evidence.json').read_text())['status']=='PASS_FULL65'
  for p in folder.iterdir():add(p,'full65/'+lane+'/'+kind+'/'+p.name)
for n in ['build.json','batch.bend']:add(Path('/tmp/bendvy-packed-main-slot-health-build-v1')/n,'retained-rejection/health-v1/'+n)
for label,path in [('motion-v4','/tmp/bendvy-packed-main-slot-motion-v4'),('both-v2','/tmp/bendvy-packed-main-slot-both-v2')]:
 for n in ['overlay.json','cache-specialization.json']:add(Path(path)/n,'retained-metadata/'+label+'/'+n)
with tarfile.open(out,'w:gz') as t:
 for n,p in sorted(entries.items()):t.add(p,arcname=n,recursive=False)
pins={n:hashlib.sha256(p.read_bytes()).hexdigest() for n,p in entries.items()}
with tarfile.open(out,'r:gz') as t:
 assert {x.name:hashlib.sha256(t.extractfile(x).read()).hexdigest() for x in t.getmembers()}==pins
(H/'evidence/both-archive-manifest.json').write_text(json.dumps({'scope':'Actual source/build/finite full65 records; no capability or performance acceptance','archiveSHA256':hashlib.sha256(out.read_bytes()).hexdigest(),'decodedSHA256Verified':True,'members':pins},indent=2)+'\n')
print(len(pins),out.stat().st_size)
