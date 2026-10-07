"""Retained first normal-family evidence only; no child execution."""
from pathlib import Path
import gzip,hashlib,io,json,tarfile
H=Path(__file__).resolve().parent;R=H.parents[5];D=R/'.artifacts/relations-normal-first-1791415751785839164';O=H/'normal-depth-evidence-v1';O.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest();files={};objects={}
def add(key,p):
 assert p.name!='private-environment.json';b=p.read_bytes();s=sha(b);files[key]=s;objects[s]=b
p=json.loads((D/'plan.json').read_text());r=json.loads((D/'receipt.json').read_text());assert r['planSHA256']==sha((D/'plan.json').read_bytes());assert r['status']=='INCOMPLETE' and r['error']=='child deadline' and len(r['commands'])==7
for q in D.rglob('*'):
 if q.is_file() and q.name!='private-environment.json' and q.suffix in ['.json','.stdout','.stderr']:add('current/'+str(q.relative_to(D)),q)
for command in p['commands']:add('oracle/'+Path(command['oracle']).name,Path(command['oracle']))
add('oracle/manifest.json',H/'expected/manifest.json')
for role in p['history']:
 d=Path(role['plan']).parent
 for name in ['plan.json','receipt.json']:add('history/'+role['role']+'/'+name,d/name)
 old=json.loads((d/'receipt.json').read_text())
 for name,s in old['logs'].items():assert sha((d/name).read_bytes())==s;add('history/'+role['role']+'/'+name,d/name)
for name,s in p['pins'].items():
 q=Path(name)
 if q.suffix in ['.bend','.mjs','.ts','.py'] and q.name!='private-environment.json':assert sha(q.read_bytes())==s;add('qualified-source/'+str(q),q)
for q in [H.parent/'source-closure.json',H.parent/'evidence-v1/objects.tar.gz']:add('historical-join/'+q.name,q)
with (O/'objects.tar.gz').open('wb') as raw:
 with gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0) as g:
  with tarfile.open(fileobj=g,mode='w') as t:
   for s,b in sorted(objects.items()):
    i=tarfile.TarInfo(s);i.size=len(b);i.mtime=0;i.mode=0o644;t.addfile(i,io.BytesIO(b))
(O/'index.json').write_text(json.dumps({'files':files,'objects':{s:len(b) for s,b in objects.items()},'archiveSHA256':sha((O/'objects.tar.gz').read_bytes()),'scope':'Depth256 spans1/16 all3roles andspan128TS full30; retainedJS128runtime5 timeout/noJSON, Native128unexecuted; no wholedepth/timingqualification','excluded':'Actual private environments, generatedJS/C/Nativebinary, installedtool/library bytes and caches; original plans retain their hashes, no fresh backend recomputation'},indent=2)+'\n');print(len(files),len(objects),(O/'objects.tar.gz').stat().st_size)
