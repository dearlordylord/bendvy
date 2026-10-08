"""No-child immutable packaging of already-qualified standalone JS192 consumers."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent;J=H.parent;R=J.parents[3]
sha=lambda b:hashlib.sha256(b).hexdigest()
a=R/'.artifacts/inspector-relation55-standalone-js-1791450316713400214'
files={};excluded={}
def name(p):
 p=str(p);prefix=str(R)+'/'
 return 'worktree/'+p[len(prefix):] if p.startswith(prefix) else 'external/'+p.lstrip('/')
def add(p):
 p=Path(p);n=name(p);b=p.read_bytes();assert n not in files or files[n]==b;files[n]=b
p=json.loads((a/'plan.json').read_text());r=json.loads((a/'receipt.json').read_text());q=json.loads((a/'prepare-receipt.json').read_text())
assert sha((a/'plan.json').read_bytes())=='fb5920b74f256282f79966995a319278607bf671d8b29ad97f9f97b388f07acd'
assert sha((a/'receipt.json').read_bytes())=='e029881f057af66dd66791e35725c050746d6d3acf2abb8877664ddcd957cc83'
assert r['status']=='DEVELOPMENT_STANDALONE_JS_NORMAL_AND_THREE_RELATION192_CONTROLS_NOT_FULL55'
for x in (a/'plan.json',a/'receipt.json',a/'prepare-receipt.json'):add(x)
for x,h in p['pins'].items():
 path=Path(x);b=path.read_bytes();assert sha(b)==h
 if 'private-environment' in path.name:excluded[x]={'SHA256':h,'reason':'private environment metadata only'}
 elif path.suffix in ('.py','.bend','.json','.mjs','.js','.ts','.md','.bytes','.stdout','.stderr','.c') or path.name in ('base.bend','bend-check'):add(path)
 else:excluded[x]={'SHA256':h,'reason':'installed executable/library/resource or historical ELF identity only'}
for rec in (r,q):
 for x,h in rec['probePins'].items():assert sha(Path(x).read_bytes())==h;add(x)
for x,h in r['logs'].items():assert sha((a/x).read_bytes())==h;add(a/x)
for x,h in r['generated'].items():assert x.endswith('.js') and sha(Path(x).read_bytes())==h;add(x)
for x,h in p['inventory'].items():assert sha((Path(p['stage'])/x).read_bytes())==h;add(Path(p['stage'])/x)
index={'scope':'FINITE_NORMAL_AND_THREE_REACHED_STANDALONE_JS192_NOT_FULL55','actual':name(a),'fixture':name(J),'excluded':excluded,'records':[{'name':n,'SHA256':sha(b),'bytes':len(b)} for n,b in sorted(files.items())]}
b=(json.dumps(index,indent=2)+'\n').encode();(H/'index.json').write_bytes(b)
with tarfile.open(H/'evidence.tar.gz','w:gz') as t:
 for n,b in sorted({'index.json':b,**{'objects/'+sha(b):b for b in files.values()}}.items()):
  m=tarfile.TarInfo(n);m.size=len(b);m.mode=0o644;m.mtime=0;t.addfile(m,io.BytesIO(b))
print('packaged',len(files),'records')
