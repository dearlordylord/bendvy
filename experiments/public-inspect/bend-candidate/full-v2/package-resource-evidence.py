"""Archive retained optional-resource evidence; never launches a child process."""
from pathlib import Path
import hashlib,io,json,tarfile
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
DEST=HERE/'resource-evidence-v1';DEST.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
records={};objects={};excluded={}
def add(path,digest=None):
 p=Path(path);b=p.read_bytes();h=sha(b)
 if digest is not None:assert h==digest,(str(p),h,digest)
 if b.startswith(b'\x7fELF') or 'private-environment' in p.name or '__pycache__' in p.parts:
  excluded[str(p)]=h;return
 records[str(p)]={'sha256':h,'bytes':len(b)};objects[h]=b

def pins(value,parent=None):
 if isinstance(value,dict):
  for k,v in value.items():
   if isinstance(v,str) and len(v)==64 and all(c in '0123456789abcdef' for c in v):
    path=Path(k) if k.startswith('/') else (Path(parent)/k if parent else None)
    if path is not None and path.is_file():add(path,v)
   elif isinstance(v,dict):pins(v,k if k.startswith('/') else parent)
   elif isinstance(v,list):pins(v,parent)
 elif isinstance(value,list):
  for x in value:pins(x,parent)
folders=['inspect54-resource-cheap-1791395923155788024','inspect54-retained-backends-1791396257820314517','inspect54-resource-negatives-1791396382501039256']
for name in folders:
 folder=ROOT/'.artifacts'/name
 for p in sorted(folder.rglob('*')):
  if p.is_file() and 'private-environment' not in p.name and '__pycache__' not in p.parts:
   add(p)
   if p.suffix=='.json':
    obj=json.loads(p.read_text());pins(obj.get('inputs',{}));pins(obj.get('pins',{}));pins(obj.get('probePins',{}))
 # Plans bind full immutable stage inventories.
 for p in folder.glob('*plan.json'):
  if 'unexecuted' in p.name:continue
  plan=json.loads(p.read_text())
  if 'stage' in plan:
   for n,h in plan.get('inventory',{}).items():add(Path(plan['stage'])/n,h)
# Include source fixture and source oracle in their original namespace.
for p in HERE.glob('resource*'):
 if p.is_file():add(p)
for n in ['optional-resource.bend','optional-resource-grant.bend','check.bend']:add(HERE/n)
archive=DEST/'objects.tar.gz'
with tarfile.open(archive,'w:gz') as t:
 for h,b in sorted(objects.items()):
  m=tarfile.TarInfo('objects/'+h);m.size=len(b);m.mtime=0;t.addfile(m,io.BytesIO(b))
index={'format':1,'records':records,'archiveSHA256':sha(archive.read_bytes()),'excludedHashOnly':excluded,'cohorts':[str(ROOT/'.artifacts'/n) for n in folders],'acceptance':False,'completeIssue54':False,'privateEnvironmentExcluded':True}
(DEST/'index.json').write_text(json.dumps(index,indent=2)+'\n')
print(len(records),'records',archive.stat().st_size,'bytes')
