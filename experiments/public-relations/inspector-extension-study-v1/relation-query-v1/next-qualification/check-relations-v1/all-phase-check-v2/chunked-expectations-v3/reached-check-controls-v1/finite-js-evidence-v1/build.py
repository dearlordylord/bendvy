"""No-child packaging of already-qualified Check diagnostic controls."""
from pathlib import Path
import hashlib,json,tarfile,io
H=Path(__file__).resolve().parent
R=next(p for p in H.parents if (p/'scripts/task_runner.py').exists())
sha=lambda b:hashlib.sha256(b).hexdigest()
a=R/'.artifacts/check-relation55-reached-controls-js-1791462194945874132'
files={};excluded={}
def name(p):
 p=str(p);prefix=str(R)+'/'
 return 'worktree/'+p[len(prefix):] if p.startswith(prefix) else 'external/'+p.lstrip('/')
def add(p):
 p=Path(p);b=p.read_bytes();n=name(p);assert n not in files or files[n]==b;files[n]=b
p=json.loads((a/'plan.json').read_text());r=json.loads((a/'receipt.json').read_text());q=json.loads((a/'prepare-receipt.json').read_text())
assert sha((a/'plan.json').read_bytes())=='69ffb7f1a432d152b6b47d5829b7092ce9a7538355eb2c4ee2ae6755f11d9f76'
assert sha((a/'receipt.json').read_bytes())=='c6e0baada28d82ab35635874f26c2782b277316fc66db24a8c3bf07e53b79fbd'
assert r['status']=='DEVELOPMENT_FOUR_REACHED_CHECK_CONTROLS_FULL192_DIAGNOSTICS_JS_PASS_NOT_FULL55'
for f in (a/'plan.json',a/'receipt.json',a/'prepare-receipt.json'):add(f)
for n,d in p['pins'].items():
 path=Path(n);b=path.read_bytes();assert sha(b)==d
 if 'private-environment' in path.name:excluded[n]={'SHA256':d,'reason':'private environment identity only'}
 elif path.name=='.npmrc':excluded[n]={'SHA256':d,'reason':'private participating configuration identity only'}
 elif b.startswith(b'\x7fELF'):assert p['tools']['pins'][n]==d;excluded[n]={'SHA256':d,'reason':'installed ELF identity only'}
 else:add(path)
for record in (r,q):
 for n,d in record['probePins'].items():assert sha(Path(n).read_bytes())==d;add(n)
for n,d in r['logs'].items():assert sha((a/n).read_bytes())==d;add(a/n)
for n,d in r['generated'].items():assert n.endswith('.js') and sha(Path(n).read_bytes())==d;add(n)
for n,d in p['inventory'].items():assert sha((Path(p['stage'])/n).read_bytes())==d;add(Path(p['stage'])/n)
# Qualified source collector raw/receipt and the retained failed source attempt
# are already scalar-pinned by the actual JS plan; retain every named raw file.
for record in list(files.values()):
 try:value=json.loads(record)
 except (ValueError,UnicodeDecodeError):continue
 if isinstance(value,dict) and 'privateEnvironment' in value:
  n=value['privateEnvironment'];d=value['environmentSHA256']
  if n in excluded:assert excluded[n]['SHA256']==d
  else:excluded[n]={'SHA256':d,'reason':'private environment identity only'}
for source in sorted(H.parent.rglob('*')):
 if source.is_file() and not source.is_relative_to(H):add(source)
index={'scope':'FOUR_COMPLETE_REACHED_CHECK_CONTROLS_JS_NOT_FULL55','actual':name(a),'excluded':excluded,'records':[{'name':n,'SHA256':sha(b),'bytes':len(b)} for n,b in sorted(files.items())]}
b=(json.dumps(index,indent=2)+'\n').encode();(H/'index.json').write_bytes(b)
with tarfile.open(H/'evidence.tar.gz','w:gz') as t:
 for n,b in sorted({'index.json':b,**{'objects/'+sha(b):b for b in files.values()}}.items()):
  m=tarfile.TarInfo(n);m.size=len(b);m.mode=0o644;m.mtime=0;t.addfile(m,io.BytesIO(b))
print('packaged',len(files),'records')
