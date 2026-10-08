"""Package finite retained sampled diagnostics, without executing child processes."""
from pathlib import Path
import gzip,hashlib,io,json,tarfile
H=Path(__file__).resolve().parent;R=H.parents[6];O=H/'profile-evidence-v1';O.mkdir(exist_ok=True);sha=lambda b:hashlib.sha256(b).hexdigest();files={};objects={}
def add(key,p):
 assert p.name!='private-environment.json';b=p.read_bytes();s=sha(b);files[key]=s;objects[s]=b
runs={'original-partial':'relations-chunk-profiles-1791419733173894934','remaining-cpu':'relations-profile-candidate-cpu-1791420113261332944','coarse-allocation':'relations-chunk-coarse-profiles-1791420272919275021','failed-newline':'relations-chunk-profiles-1791419646410751243','wrapping-preflight':'relations-profile-wrapper-preflight-1791419713993196384'}
for role,name in runs.items():
 d=R/'.artifacts'/name
 for p in d.rglob('*'):
  if p.is_file() and p.name!='private-environment.json' and 'wrappers' not in p.relative_to(d).parts and (p.suffix in ['.json','.stdout','.stderr','.raw'] or p.name=='failed-wrapper.py'):add(role+'/'+str(p.relative_to(d)),p)
add('unexecuted-cpu/plan.json',R/'.artifacts/relations-profile-candidate-cpu-1791420011579287824/plan.json')
for n in ['profile.py','profile-preparation.json','profile-proposal.json','profile-candidate-cpu.py','profile-candidate-cpu-proposal.json','profile-candidate-cpu-preparation.json','profile-coarse-allocation.py','profile-coarse-allocation-proposal.json','profile-coarse-allocation-preparation.json','analyze-profiles.py','profile-analysis.json','cpu-original-analysis.json','cpu-candidate-analysis.json','allocation-coarse-analysis.json']:add('authored/'+n,H/n)
for p in [H/'review-history/profile-terminal-newline/profile.py',H/'review-history/profile-terminal-newline/profile-preparation.json',H/'review-history/cpu-3eb7/profile-candidate-cpu.py']:add('review-history/'+str(p.relative_to(H/'review-history')),p)
add('oracle/depth16.json',H.parent/'expected/depth-256-span-16-seed-0.json');add('oracle/manifest.json',H.parent/'expected/manifest.json');add('qualification/index.json',H/'evidence-v1/index.json');add('qualification/objects.tar.gz',H/'evidence-v1/objects.tar.gz')
with (O/'objects.tar.gz').open('wb') as raw:
 with gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0) as g:
  with tarfile.open(fileobj=g,mode='w') as t:
   for s,b in sorted(objects.items()):
    i=tarfile.TarInfo(s);i.size=len(b);i.mode=0o644;i.mtime=0;t.addfile(i,io.BytesIO(b))
(O/'index.json').write_text(json.dumps({'files':files,'objects':{s:len(b) for s,b in objects.items()},'archiveSHA256':sha((O/'objects.tar.gz').read_bytes()),'scope':'Matched singledepth16 original/candidate CPU100us andHeap1MiB complete30 diagnostic profiles only. Original16KiB allocation timeout retained. No Native/N1024/universal/performance/RSS/totalallocation/causal acceptance.','excluded':'Private environments, generatedruntime/profilewrapper/source/binaries, installedtool/library bytes andcaches. Local lexical source-location attribution is hash-bound; capsule doesnot regenerate orparse excludedgeneratedwrappers.'},indent=2)+'\n');print(len(files),len(objects),(O/'objects.tar.gz').stat().st_size)
