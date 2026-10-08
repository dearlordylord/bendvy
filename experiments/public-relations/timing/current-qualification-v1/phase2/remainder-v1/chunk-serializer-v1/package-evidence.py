"""Package retained finite chunk serializer evidence; no child execution."""
from pathlib import Path
import gzip,hashlib,io,json,tarfile
H=Path(__file__).resolve().parent;R=H.parents[6];O=H/'evidence-v1';O.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest();files={};objects={}
def add(key,p):
 assert p.name!='private-environment.json';b=p.read_bytes();s=sha(b);files[key]=s;objects[s]=b
runs={'pure':'relations-chunk-controls-cheap-1791418038147161644','first':'relations-phase2-standalone-js-1791418616178805603','extension':'relations-chunk-extension-1791419118574552727','source':'relations-chunk-source-1791417409534649775','exhaustion-source':'relations-chunk-exhaustion-source-1791418394127767485','failed-preparation':'relations-chunk-extension-1791419012594996252','historical-depth':'relations-normal-first-1791415751785839164'}
for role,name in runs.items():
 d=R/'.artifacts'/name
 for p in sorted(d.rglob('*')):
  if p.is_file() and p.name!='private-environment.json' and ('stage' not in p.relative_to(d).parts) and (p.suffix in ['.json','.stdout','.stderr','.raw'] or p.parent.name=='sources' or p.name=='failed-wrapper.py'):add(role+'/'+str(p.relative_to(d)),p)
for role in ['first','extension']:
 p=json.loads((R/'.artifacts'/runs[role]/'plan.json').read_text())
 for n,s in p['pins'].items():
  q=Path(n)
  if q.name=='private-environment.json':continue
  if q.is_relative_to(R) and q.suffix in ['.bend','.mjs','.py','.c','.js'] and '.artifacts' not in q.relative_to(R).parts:
   assert sha(q.read_bytes())==s;add('qualified-source/'+str(q.relative_to(R)),q)
  elif '/.references/bevy-ts/packages/core/src/' in n or n.endswith('/.references/bend2/bend2/main.ts') or n.endswith('/.references/bend2/bend2/bend.ts'):
   assert sha(q.read_bytes())==s;add('reference-source/'+n,q)
 for c in p['commands']:
  for field in ['oracle','forcedOracle']:
   if field in c:add('oracle/'+Path(c[field]).name,Path(c[field]))
for n in ['expected-controls.json','expected-controls.stdout','pinned-notice.stderr','source-files.json','cheap-source-plan.json','exhaustion-source-plan.json','controls-cheap-preparation.json','candidate-first-js-preparation.json','candidate-extension-proposal.json','candidate-extension-preparation.json']:add('authored/'+n,H/n)
for q in (H/'review-history').rglob('*'):
 if q.is_file():add('review-history/'+str(q.relative_to(H/'review-history')),q)
add('oracle/remainder-manifest.json',H.parent/'expected/manifest.json');add('oracle/initial-manifest.json',H.parents[1]/'expected/manifest.json')
for p in [H.parents[1]/'source-closure.json',H.parents[1]/'evidence-v1/objects.tar.gz']:add('historical-join/'+p.name,p)
with (O/'objects.tar.gz').open('wb') as raw:
 with gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0) as g:
  with tarfile.open(fileobj=g,mode='w') as t:
   for s,b in sorted(objects.items()):
    i=tarfile.TarInfo(s);i.size=len(b);i.mtime=0;i.mode=0o644;t.addfile(i,io.BytesIO(b))
(O/'index.json').write_text(json.dumps({'files':files,'objects':{s:len(b) for s,b in objects.items()},'archiveSHA256':sha((O/'objects.tar.gz').read_bytes()),'scope':'Finite pure five controls + candidate depth128/depth1/depth16/64max full30 + actual TS64max/input/postforce-exhaustion refusals only. Historical originaldepth128 JS timeout retained; no Native/N1024/allfamily/performance/proof qualification.','excluded':'Private environments, generated JS/C/native binaries, installedtool/library bytes, caches. Plans retain hashes; generated effect-order is local hash-bound review only, not capsule recomputation.'},indent=2)+'\n');print(len(files),len(objects),(O/'objects.tar.gz').stat().st_size)
