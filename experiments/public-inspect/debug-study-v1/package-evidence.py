"""Archive development evidence; no tool processes, live replay or qualification."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy')
sha=lambda b:hashlib.sha256(b).hexdigest()
files={};objects={};excluded={};paths={}
def add(key,path):
 raw=path.read_bytes();digest=sha(raw)
 if path.name=='private-environment.json' or raw.startswith(b'\x7fELF'):
  excluded[str(path)]={'sha256':digest,'bytes':len(raw),'reason':'private environment or installed/generated executable bytes'};return
 objects[digest]=raw;files[key]=digest;paths[str(path)]=key
for p in H.rglob('*'):
 if p.is_file() and 'evidence-v1' not in p.parts and p.name not in ['FILES.json']:
  add('owned/'+str(p.relative_to(H)),p)
# External consumed sources/guards are captured when current bytes equal the pin.
# Historical installed binaries/private values stay excluded; stale originals
# remain hash identifiers, qualified historical stage copies are retained above.
unavailable={}
for planpath in (H/'preflight').glob('*/plan.json'):
 plan=json.loads(planpath.read_text())
 for name,digest in plan['pins'].items():
  p=Path(name)
  if p.is_file() and sha(p.read_bytes())==digest:add('external/'+digest+'/'+p.name,p)
  else:unavailable[name+'@'+digest]={'scope':'Original historical pin is not current; corresponding frozen stage/history remains separate'}
out=H/'evidence-v1';out.mkdir(exist_ok=True)
archive=out/'objects.tar.gz'
with tarfile.open(archive,'w:gz') as t:
 for digest,raw in sorted(objects.items()):
  m=tarfile.TarInfo(digest);m.size=len(raw);m.mtime=0;t.addfile(m,io.BytesIO(raw))
index={'scope':'Development source/actual TS16 reuse/JS16 and all failure history; no backend replay, proof, Native or full56','archiveSHA256':sha(archive.read_bytes()),'files':files,'objects':{h:len(b) for h,b in objects.items()},'pathKeys':paths,'excluded':excluded,'historicalOriginalPinsUnavailable':unavailable}
(out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(files),len(objects),archive.stat().st_size,len(excluded),len(unavailable))
