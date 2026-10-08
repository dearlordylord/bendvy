"""Portable development full9 evidence packaging; no children."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent;OUT=H/'evidence-v1';OUT.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
files={};paths={};objects={};excluded={};unavailable={}
def add(p,key=None):
 raw=p.read_bytes();h=sha(raw)
 if p.name=='private-environment.json' or raw.startswith(b'\x7fELF'):
  excluded[str(p)]={'sha256':h,'bytes':len(raw),'reason':'Private environment or executable identity only'};return
 key=key or 'external/'+h+'/'+p.name;files[key]=h;paths[str(p)]=key;objects[h]=raw
for p in (H/'preflight').rglob('*'):
 if p.is_file():add(p,'preflight/'+str(p.relative_to(H/'preflight')))
for planfile in (H/'preflight').glob('*/plan.json'):
 for n,h in json.loads(planfile.read_text())['pins'].items():
  p=Path(n)
  if p.is_file() and sha(p.read_bytes())==h:add(p)
  else:unavailable[n+'@'+h]='Original mutable source identity replaced; exact historical frozen stage/source-history retained'
for n in ['metadata.bend','index.bend','lints.bend','render-fixture.bend','main.bend','reference.ts','ORACLE.json','EXPECTED.stdout','development-runner.py','remaining-runner.py','remaining-v2-runner.py','package.py','verify.py','RESULT.md']:
 add(H/n,'delivery/'+n)
for p in (H/'source-history').rglob('*'):
 if p.is_file():add(p,'history/'+str(p.relative_to(H/'source-history')))
for p in (H/'development-1791441692225989030').iterdir():
 if p.is_file():add(p,'development-final-lf/'+p.name)
with tarfile.open(OUT/'objects.tar.gz','w:gz') as tar:
 for h,b in sorted(objects.items()):
  info=tarfile.TarInfo(h);info.size=len(b);info.mtime=0;tar.addfile(info,io.BytesIO(b))
index={'scope':'Development scoped full9 access indexes/all five lint algorithms: actual TS9 and candidateJS9; no ordinary loader qualification/Native/proof/full56/fullDescription format publication','archiveSHA256':sha((OUT/'objects.tar.gz').read_bytes()),'files':files,'pathKeys':paths,'objects':{h:len(b) for h,b in objects.items()},'excluded':excluded,'historicalUnavailable':unavailable}
(OUT/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(files),len(objects),len(excluded),len(unavailable))
