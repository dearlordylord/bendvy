"""No-child packaging of independently classified matched authority diagnostics."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent
R=next(p for p in H.parents if (p/'scripts/task_runner.py').exists())
sha=lambda b:hashlib.sha256(b).hexdigest()
a=R/'.artifacts/check-relation55-authority-source-1791458636152273698'
files={};excluded={}
def name(p):
 p=str(p);prefix=str(R)+'/'
 return 'worktree/'+p[len(prefix):] if p.startswith(prefix) else 'external/'+p.lstrip('/')
def add(p):
 p=Path(p);b=p.read_bytes();n=name(p);assert n not in files or files[n]==b;files[n]=b
p=json.loads((a/'plan.json').read_text());r=json.loads((a/'receipt.json').read_text())
assert sha((a/'plan.json').read_bytes())=='4b0a1767e031031be1750610706e41a86da807853195cbd21725f05a8efee43d'
assert sha((a/'receipt.json').read_bytes())=='fe853365a796765e1298e392e857f74a9e517d112eac88dee1d2249b1526ae3b'
assert sha((a/'classification.json').read_bytes())=='4024267bc53aa9d654096040e1aa9189345f69354252b08906ba1b255bf9a7ff'
for n in ('plan.json','receipt.json','classification.json'):add(a/n)
for n,d in p['pins'].items():
 b=Path(n).read_bytes();assert sha(b)==d
 if 'private-environment' in Path(n).name:excluded[n]={'SHA256':d,'reason':'private environment metadata only'}
 elif Path(n).name=='.npmrc':excluded[n]={'SHA256':d,'reason':'private participating configuration identity only'}
 elif b.startswith(b'\x7fELF'):excluded[n]={'SHA256':d,'reason':'installed ELF identity only'}
 else:add(n)
excluded[p['privateEnvironment']]={'SHA256':p['environmentSHA256'],'reason':'private environment metadata only'}
for n,d in r['logs'].items():assert sha((a/n).read_bytes())==d;add(a/n)
index={'scope':'FINITE_MATCHED_SOURCE_AUTHORITY_NOT_RUNTIME_PROOF','actual':name(a),'excluded':excluded,'records':[{'name':n,'SHA256':sha(b),'bytes':len(b)} for n,b in sorted(files.items())]}
b=(json.dumps(index,indent=2)+'\n').encode();(H/'index.json').write_bytes(b)
with tarfile.open(H/'evidence.tar.gz','w:gz') as t:
 for n,b in sorted({'index.json':b,**{'objects/'+sha(b):b for b in files.values()}}.items()):
  m=tarfile.TarInfo(n);m.size=len(b);m.mode=0o644;m.mtime=0;t.addfile(m,io.BytesIO(b))
print('packaged',len(files),'records')
