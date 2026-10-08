"""Package existing exact TS2 development evidence; no child execution."""
from pathlib import Path
import json,hashlib,tarfile,io
H=Path(__file__).resolve().parent;P=H/'preflight/1791445919387571114';O=H/'ts-evidence-v1';O.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
p=json.loads((P/'plan.json').read_text());r=json.loads((P/'receipt.json').read_text());assert sha((P/'plan.json').read_bytes())=='7281cc169cc84647fd8aace1e618971a7518dcaf5adbec09d39a05dd479aac8c';assert sha((P/'receipt.json').read_bytes())=='9efcb8e84369351f423814c9715607973a6ce3d0c0932cdc0dc334082481126f'
records={};objects={};excluded={}
def add(path):
 path=Path(path);b=path.read_bytes();digest=sha(b);records[str(path.resolve())]=digest;objects[digest]=b
for path,digest in p['pins'].items():
 f=Path(path);assert sha(f.read_bytes())==digest
 if path==p['environment'] or '/installs/node/' in path or path=='/usr/bin/taskset':excluded[path]={'sha256':digest,'reason':'private environment or installed executable; identity retained, bytes not redistributed'}
 else:add(f)
for f in (P/'stage').rglob('*'):
 if f.is_file():add(f)
for name in ['plan.json','receipt.json','reference.stdout','reference.stderr']:add(P/name)
assert set(r['logs'])=={'reference.stdout','reference.stderr'}
for name,digest in r['logs'].items():assert sha((P/name).read_bytes())==digest
with tarfile.open(O/'objects.tar.gz','w:gz') as tar:
 for digest,b in sorted(objects.items()):
  item=tarfile.TarInfo(digest);item.size=len(b);item.mtime=0;tar.addfile(item,io.BytesIO(b))
index={'scope':'Existing actual TS2 development only, no Bend/delivery/full56','records':records,'excluded':excluded,'planPath':str((P/'plan.json').resolve()),'receiptPath':str((P/'receipt.json').resolve()),'archiveSHA256':sha((O/'objects.tar.gz').read_bytes())};(O/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(records),len(objects),len(excluded))
