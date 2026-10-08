"""No-child packaging of the already-qualified complete Check JS consumer."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent
R=next(p for p in H.parents if (p/'scripts/task_runner.py').exists())
sha=lambda b:hashlib.sha256(b).hexdigest()
a=R/'.artifacts/check-relation55-chunk-standalone-js-1791457454442741470'
files={};excluded={}
def name(p):
 p=str(p);prefix=str(R)+'/'
 return 'worktree/'+p[len(prefix):] if p.startswith(prefix) else 'external/'+p.lstrip('/')
def add(p):
 p=Path(p);b=p.read_bytes();n=name(p);assert n not in files or files[n]==b;files[n]=b
p=json.loads((a/'plan.json').read_text());r=json.loads((a/'receipt.json').read_text());q=json.loads((a/'prepare-receipt.json').read_text())
assert sha((a/'plan.json').read_bytes())=='49647d8cbb7a4d4f979b808c464aca3b88b67e74aa000141abeac0058925997e'
assert sha((a/'receipt.json').read_bytes())=='d76961ef23f206b031968eff9f4f4c0cebe1b6050c40ec4faf761bbc3a4c9e79'
assert r['status']=='DEVELOPMENT_STANDALONE_JS_CHECK320_PLUS192_DIAGNOSTICS_PASS_NOT_FULL55'
for x in (a/'plan.json',a/'receipt.json',a/'prepare-receipt.json'):add(x)
for x,h in p['pins'].items():
 path=Path(x);b=path.read_bytes();assert sha(b)==h
 if 'private-environment' in path.name:excluded[x]={'SHA256':h,'reason':'private environment metadata only'}
 elif path.name=='.npmrc':excluded[x]={'SHA256':h,'reason':'private participating configuration identity only'}
 elif path.suffix in ('.py','.bend','.json','.mjs','.js','.ts','.md','.bytes','.stdout','.stderr','.c','.lean','.raw') or path.name=='exit' or path.name in ('base.bend','bend-check'):add(path)
 else:excluded[x]={'SHA256':h,'reason':'installed executable/library/resource identity only'}
for record in (r,q):
 for x,h in record['probePins'].items():assert sha(Path(x).read_bytes())==h;add(x)
for x,h in r['logs'].items():assert sha((a/x).read_bytes())==h;add(a/x)
for x,h in r['generated'].items():assert x.endswith('.js') and sha(Path(x).read_bytes())==h;add(x)
for x,h in p['inventory'].items():assert sha((Path(p['stage'])/x).read_bytes())==h;add(Path(p['stage'])/x)
index={'scope':'FINITE_CHECK320_PLUS192_DIAGNOSTICS_NOT_FULL55','actual':name(a),'excluded':excluded,'records':[{'name':n,'SHA256':sha(b),'bytes':len(b)} for n,b in sorted(files.items())]}
b=(json.dumps(index,indent=2)+'\n').encode();(H/'index.json').write_bytes(b)
with tarfile.open(H/'evidence.tar.gz','w:gz') as t:
 for n,b in sorted({'index.json':b,**{'objects/'+sha(b):b for b in files.values()}}.items()):
  m=tarfile.TarInfo(n);m.size=len(b);m.mode=0o644;m.mtime=0;t.addfile(m,io.BytesIO(b))
print('packaged',len(files),'records')
