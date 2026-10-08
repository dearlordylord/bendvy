"""No-child packaging of complete two-schema Native Check consumer."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent
R=next(p for p in H.parents if (p/'scripts/task_runner.py').exists())
sha=lambda b:hashlib.sha256(b).hexdigest()
a=R/'.artifacts/check-relation55-schema-native-1791459621302187378'
files={};excluded={}
def name(p):
 p=str(p);prefix=str(R)+'/'
 return 'worktree/'+p[len(prefix):] if p.startswith(prefix) else 'external/'+p.lstrip('/')
def add(p):
 p=Path(p);b=p.read_bytes();n=name(p);assert n not in files or files[n]==b;files[n]=b
p=json.loads((a/'plan.json').read_text());r=json.loads((a/'receipt.json').read_text())
assert sha((a/'plan.json').read_bytes())=='48c07a77a03b4b0522fa14056055c28271e0b6d1b18e6c520c70cd6532cc8822'
assert sha((a/'receipt.json').read_bytes())=='ef172eec439253dfbe447001c0a45e5f191e7fc4f2704efb90cd36849a722e46'
for n in ('plan.json','receipt.json','prepare-receipt.json'):add(a/n)
for n,d in p['pins'].items():
 b=Path(n).read_bytes();assert sha(b)==d
 if 'private-environment' in Path(n).name:excluded[n]={'SHA256':d,'reason':'private environment metadata only'}
 elif Path(n).name=='.npmrc':excluded[n]={'SHA256':d,'reason':'private participating configuration identity only'}
 elif b.startswith(b'\x7fELF'):excluded[n]={'SHA256':d,'reason':'installed ELF identity only'}
 else:add(n)
excluded[p['privateEnvironment']]={'SHA256':p['environmentSHA256'],'reason':'private environment metadata only'}
for rec in (r,json.loads((a/'prepare-receipt.json').read_text())):
 for n,d in rec['probePins'].items():assert sha(Path(n).read_bytes())==d;add(n)
for n,d in r['logs'].items():assert sha((a/n).read_bytes())==d;add(a/n)
for n,d in r['generated'].items():
 b=Path(n).read_bytes();assert sha(b)==d
 if n.endswith('.c'):add(n)
 else:excluded[n]={'SHA256':d,'reason':'actual Native executable identity only'}
for n,d in p['inventory'].items():assert sha((Path(p['stage'])/n).read_bytes())==d;add(Path(p['stage'])/n)
index={'scope':'FINITE_NATIVE_CHECK320_PLUS192_DIAGNOSTICS_NOT_FULL55','actual':name(a),'excluded':excluded,'records':[{'name':n,'SHA256':sha(b),'bytes':len(b)} for n,b in sorted(files.items())]}
b=(json.dumps(index,indent=2)+'\n').encode();(H/'index.json').write_bytes(b)
with tarfile.open(H/'evidence.tar.gz','w:gz') as t:
 for n,b in sorted({'index.json':b,**{'objects/'+sha(b):b for b in files.values()}}.items()):
  m=tarfile.TarInfo(n);m.size=len(b);m.mode=0o644;m.mtime=0;t.addfile(m,io.BytesIO(b))
print('packaged',len(files),'records')
