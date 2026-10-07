"""Retain population timeout and independent Native128 continuation; no children."""
from pathlib import Path
import gzip,hashlib,io,json,tarfile
H=Path(__file__).resolve().parent;R=H.parents[5];O=H/'normal-residual-evidence-v1';O.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();files={};objects={}
def add(key,p):
 assert p.name!='private-environment.json';b=p.read_bytes();s=sha(b);files[key]=s;objects[s]=b
for group,d in [('population',R/'.artifacts/relations-normal-first-1791416550923842697'),('native128',H/'native128-prepared-v1')]:
 p=json.loads((d/'plan.json').read_text());r=json.loads((d/'receipt.json').read_text());assert r['planSHA256']==sha((d/'plan.json').read_bytes())
 for q in d.rglob('*'):
  if q.is_file() and q.name!='private-environment.json' and q.suffix in ['.json','.stdout','.stderr']:add(group+'/'+str(q.relative_to(d)),q)
 for c in p['commands']:add('oracle/'+Path(c['oracle']).name,Path(c['oracle']))
 for name,s in p['pins'].items():
  q=Path(name)
  if q.suffix in ['.bend','.mjs','.ts','.py']:assert sha(q.read_bytes())==s;add('qualified-source/'+name,q)
add('oracle/manifest.json',H/'expected/manifest.json')
with (O/'objects.tar.gz').open('wb') as raw:
 with gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0) as g:
  with tarfile.open(fileobj=g,mode='w') as t:
   for s,b in sorted(objects.items()):
    i=tarfile.TarInfo(s);i.size=len(b);i.mtime=0;i.mode=0o644;t.addfile(i,io.BytesIO(b))
(O/'index.json').write_text(json.dumps({'files':files,'objects':{s:len(b) for s,b in objects.items()},'archiveSHA256':sha((O/'objects.tar.gz').read_bytes()),'scope':'PopulationN1024seed0TScomplete30/JSBegin-onlytimeout5/othercommandsunexecuted, originalNative128separatecomplete30; no wholepopulation/wholedepth/speedacceptance','excluded':'Private environments/generatedartifacts/installedtools/libraries/caches; prior depth evidence is a required immutable dependency for Native128 comparator/history/toolprep joins'},indent=2)+'\n');print(len(files),len(objects),(O/'objects.tar.gz').stat().st_size)
