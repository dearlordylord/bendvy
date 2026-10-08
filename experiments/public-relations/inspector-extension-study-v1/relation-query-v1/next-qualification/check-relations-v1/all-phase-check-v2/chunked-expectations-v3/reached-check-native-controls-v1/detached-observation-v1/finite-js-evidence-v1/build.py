"""No-child packaging of detached normal JS and preserved histories."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent
R=next(p for p in H.parents if (p/'scripts/task_runner.py').exists())
A=R/'.artifacts/check55-detached-normal-js-1791466387127562283'
sha=lambda b:hashlib.sha256(b).hexdigest()
name=lambda p:'worktree/'+str(Path(p).relative_to(R)) if Path(p).is_relative_to(R) else 'external/'+str(p).lstrip('/')
files={};excluded={}
def add(p):
 p=Path(p);b=p.read_bytes();files[name(p)]=b
p=json.loads((A/'plan.json').read_text());r=json.loads((A/'receipt.json').read_text());q=json.loads((A/'prepare-receipt.json').read_text())
assert sha((A/'plan.json').read_bytes())=='51d894c63fa397fac500ec5722ab34596889af03c7d38ec235d738a32a37cd88'
assert sha((A/'receipt.json').read_bytes())=='15eed3b0646b538df4c16057daae6e2ff1187fd42ce711d43f2b16bbecae8eb4'
for n in ('plan.json','receipt.json','prepare-receipt.json'):add(A/n)
for n,d in p['pins'].items():
 f=Path(n);b=f.read_bytes();assert sha(b)==d
 if 'private-environment' in f.name:excluded[n]={'SHA256':d,'reason':'private environment identity only'}
 elif f.name=='.npmrc':excluded[n]={'SHA256':d,'reason':'private configuration identity only'}
 elif b.startswith(b'\x7fELF'):excluded[n]={'SHA256':d,'reason':'installed executable identity only'}
 else:add(f)
for record in (r,q):
 for n,d in record['probePins'].items():assert sha(Path(n).read_bytes())==d;add(n)
for n,d in r['logs'].items():assert sha((A/n).read_bytes())==d;add(A/n)
for n,d in r['generated'].items():assert sha(Path(n).read_bytes())==d;add(n)
for n,d in p['inventory'].items():f=Path(p['stage'])/n;assert sha(f.read_bytes())==d;add(f)
for f in H.parent.rglob('*'):
 if f.is_file() and not f.is_relative_to(H) and f.suffix=='.bend':add(f)
index={'scope':'DETACHED_NORMAL_JS_ONLY','actual':name(A),'historicalRoot':str(R),'excluded':excluded,'records':[{'name':n,'SHA256':sha(b),'bytes':len(b)} for n,b in sorted(files.items())]}
b=(json.dumps(index,indent=2)+'\n').encode();(H/'index.json').write_bytes(b)
with tarfile.open(H/'evidence.tar.gz','w:gz') as t:
 for n,b in sorted({'index.json':b,**{'objects/'+sha(b):b for b in files.values()}}.items()):
  z=tarfile.TarInfo(n);z.size=len(b);z.mode=0o644;z.mtime=0;t.addfile(z,io.BytesIO(b))
print(len(files))
