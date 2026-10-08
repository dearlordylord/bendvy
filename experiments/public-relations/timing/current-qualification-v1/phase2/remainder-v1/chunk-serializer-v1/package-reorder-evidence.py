"""Archive current-root finite reorder qualification; no children or live acceptance."""
from pathlib import Path
import gzip, hashlib, io, json, tarfile
H=Path(__file__).resolve().parent
R=H.parents[6]
O=H/'reorder-evidence-v1'; O.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
files={};objects={};paths={};key_paths={}
def add(key,p):
 p=Path(p);assert p.name!='private-environment.json'
 b=p.read_bytes();s=sha(b);files[key]=s;objects[s]=b;paths[str(p)]=key;key_paths[key]=p
roles={'js':'relations-current-reorder-js-1791428028440599792','native':'relations-current-reorder-native-1791428954241351967','cheap-positive':'relations-current-reorder-cheap-1791426163063273743','cheap-negatives':'relations-current-reorder-cheap-1791426395165088782'}
allowed={'.json','.stdout','.stderr','.raw','.bend','.py','.md','.mjs','.gz'}
for role,name in roles.items():
 d=R/'.artifacts'/name
 for p in sorted(d.rglob('*')):
  if p.is_file() and p.name!='private-environment.json' and p.suffix in allowed:
   add(role+'/'+str(p.relative_to(d)),p)
 plan=json.loads((d/'plan.json').read_text())
 for name,s in plan['pins'].items():
  p=Path(name)
  if sha(p.read_bytes())!=s:
   assert role=='cheap-positive' and p.name=='reorder-cheap.py'
   retained=d/'failed-wrapper.py';assert sha(retained.read_bytes())==s
   add('historical-qualified/reorder-cheap-dc1391.py',retained)
   paths[name]='historical-qualified/reorder-cheap-dc1391.py'
   continue
  if p.name!='private-environment.json' and p.suffix in allowed:
   add('bound/'+str(p).lstrip('/'),p)
for name in ('ROOT-ADOPTION-READINESS.md','root-adoption-byte-joins.json','ADOPTION-JOIN-PLAN.md','adoption-negative-source-joins.json','REORDER-SOURCE-CHECKPOINT.md','reorder-current-root-closure.json','reorder-runtime-proposal.json','pinned-notice.stderr'):
 add('authored/'+name,H/name)
for directory in ('reorder-cheap-915b','reorder-cheap-a3','reorder-cheap-b04','reorder-js-9fd'):
 for p in sorted((H/'review-history'/directory).rglob('*')):
  if p.is_file():add('review-history/'+directory+'/'+str(p.relative_to(H/'review-history'/directory)),p)
# Every retained receipt raw/probe join must be present, not merely mentioned.
for key in list(files):
 if key.endswith('receipt.json'):
  receipt=json.loads(objects[files[key]])
  for name,s in receipt.get('probePins',{}).items():
   p=Path(name);assert sha(p.read_bytes())==s;add('bound/'+str(p).lstrip('/'),p)
  for name,s in receipt.get('logs',{}).items():
   p=key_paths[key].parent/name
   assert sha(p.read_bytes())==s;add('bound/'+str(p).lstrip('/'),p)
with (O/'objects.tar.gz').open('wb') as raw:
 with gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0) as zipped:
  with tarfile.open(fileobj=zipped,mode='w') as archive:
   for s,b in sorted(objects.items()):
    info=tarfile.TarInfo(s);info.size=len(b);info.mtime=0;info.mode=0o644;archive.addfile(info,io.BytesIO(b))
index={'files':files,'pathKeys':paths,'objects':{s:len(b) for s,b in objects.items()},'archiveSHA256':sha((O/'objects.tar.gz').read_bytes()),'scope':'Current-root finite normal plus three reached reorder mutants: JS and Native full52 checkpoints/exact original witness objects; three exact source negatives. Historical positive receipt remains INCOMPLETE, independently classified exact58+42 bytes. No proof/performance/adoption/full42.','excluded':'Private environments, generated JS/C/native executables, installed executable/library bytes and caches. Absolute paths are archive identifiers only; verifier opens no live source paths. Generated hashes retained in receipts do not reconstruct emitted bytes.'}
(O/'index.json').write_text(json.dumps(index,indent=2)+'\n')
print(len(files),len(objects),(O/'objects.tar.gz').stat().st_size)
