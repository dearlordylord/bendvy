"""Retain exact source/oracle/log objects without launching child processes."""
from pathlib import Path
import hashlib,json,tarfile,io
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4];OUT=HERE/'evidence-v1';OUT.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest();records={};objects={};excluded={}
def add(path,h=None):
 p=Path(path);b=p.read_bytes();d=sha(b);key=str(p)
 if h is not None and d!=h:
  candidates=[q for q in HERE.glob('*.py') if sha(q.read_bytes())==h];assert len(candidates)==1,(str(p),h);b=candidates[0].read_bytes();d=sha(b);key=str(p)+'#'+h
 if h is not None:assert d==h,(str(p),d,h)
 if b.startswith(b'\x7fELF') or 'private-environment' in p.name or '__pycache__' in p.parts:excluded[str(p)]=d;return
 records[key]={'sha256':d,'bytes':len(b),'originalPath':str(p)};objects[d]=b
folders=['diagnostic-1791399028471698677','cheap-1791399100203438697','cheap-1791399144219083899','native-1791399197496013133']
for name in folders:
 folder=HERE/name
 for f in sorted(folder.rglob('*')):
  if f.is_file() and 'private-environment' not in f.name and '__pycache__' not in f.parts:add(f)
 plan=json.loads((folder/'plan.json').read_text())
 for f,h in plan.get('pins',{}).items():add(f,h)
 for f,h in plan.get('inputs',{}).items():
  if isinstance(h,dict):
   for n,d in h.items():add(Path(f)/n,d)
  else:add(f,h)
old=HERE.parent/'development/refusal-controls-1791393605594137174'
for n in ['plan.json','receipt.json','omit-set-refusal-baseline-check.stdout','omit-set-refusal-baseline-check.stderr']:add(old/n)
for f in [*HERE.glob('*.py'),*HERE.glob('*.md')]:add(f)
archive=OUT/'objects.tar.gz'
with tarfile.open(archive,'w:gz') as t:
 for h,b in sorted(objects.items()):m=tarfile.TarInfo('objects/'+h);m.size=len(b);m.mtime=0;t.addfile(m,io.BytesIO(b))
index={'records':records,'archiveSHA256':sha(archive.read_bytes()),'excludedHashOnly':excluded,'cohorts':folders,'root':str(HERE),'old':str(old),'acceptance':False,'completeIssue44':False};(OUT/'index.json').write_text(json.dumps(index,indent=2));print(len(records),archive.stat().st_size)
