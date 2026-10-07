"""Retain exact capture subjects and diagnostic outputs; tool binaries stay pinned."""
from pathlib import Path
import hashlib,io,json,tarfile
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
out=HERE/'evidence';out.mkdir(exist_ok=True);objects={};members={}
def add(p):
 b=p.read_bytes();h=hashlib.sha256(b).hexdigest();objects[h]=b;members[str(p.relative_to(ROOT)) if p.is_relative_to(ROOT) else str(p)]=h
for p in HERE.iterdir():
 if p.is_file():add(p)
plan=json.loads((HERE/'application-stage-plan.json').read_text())
for role in ['baseline','candidate']:
 stage=Path(plan[role]);add(stage/'stage.json')
 for p in (stage/'stage').rglob('*'):
  if p.is_file():add(p)
 results=HERE/'application-results';subject=next(p for p in results.iterdir() if p.name.startswith(role+'-'))
 for p in subject.iterdir():
  if p.is_file() and p.suffix!='.native':add(p)
 profile=ROOT/'.artifacts'/('capture-'+role+'-profiles-v1')
 for p in profile.iterdir():
  if p.is_file():add(p)
 receipt=json.loads((profile/'receipt.json').read_text())
 for name,value in receipt['inputs'].items():
  p=Path(name)
  if isinstance(value,dict) and p.is_relative_to(ROOT/'.references/bevy-ts/packages/core/src'):
   for relative,h in value.items():
    source=p/relative;assert hashlib.sha256(source.read_bytes()).hexdigest()==h;add(source)
  if isinstance(value,str) and '.git' not in p.parts and p.is_file() and (p.is_relative_to(ROOT) or p.suffix in ['.bend','.json','.md','.py']):
   assert hashlib.sha256(p.read_bytes()).hexdigest()==value;add(p)
(out/'index.json').write_text(json.dumps({'scope':'Exact application stages and complete semantic/profile receipts, raw logs, generated subjects, wrappers and consumed project/reference text. Installed executable/library binaries and generated Native binaries and reference Git metadata retained by receipt hashes only. No performance acceptance.', 'members':members,'objects':{h:len(b) for h,b in objects.items()}},indent=2)+'\n')
with tarfile.open(out/'objects.tar.gz','w:gz') as tar:
 for h,b in sorted(objects.items()):
  info=tarfile.TarInfo(h);info.size=len(b);info.mtime=0;tar.addfile(info,io.BytesIO(b))
with tarfile.open(out/'objects.tar.gz','r:gz') as tar:
 assert {m.name:hashlib.sha256(tar.extractfile(m).read()).hexdigest() for m in tar.getmembers()}=={h:h for h in objects}
print('PASS exact archive',len(members),'members',len(objects),'objects',(out/'objects.tar.gz').stat().st_size,'bytes')
