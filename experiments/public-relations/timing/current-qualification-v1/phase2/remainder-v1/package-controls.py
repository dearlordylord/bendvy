"""Archive retained controls, no backend children or regenerated expectations."""
from pathlib import Path
import gzip,hashlib,io,json,tarfile
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[5]
sha=lambda data:hashlib.sha256(data).hexdigest()
files={};objects={}
def add(key,path):
 data=path.read_bytes();digest=sha(data);files[key]=digest;objects[digest]=data
out=HERE/'control-evidence-v1';out.mkdir(exist_ok=True)
for label,stamp in [('first','1791411592382226836'),('remaining','1791411629670043324'),('js','1791411647286832015')]:
 directory=ROOT/'.artifacts'/(( 'relations-phase2-standalone-js-' if label=='js' else 'relations-phase2-cheap-')+stamp)
 for p in directory.rglob('*'):
  if p.is_file() and p.name!='private-environment.json' and ('stage' not in p.relative_to(directory).parts) and p.suffix in ['.json','.stdout','.stderr']:add(label+'/'+str(p.relative_to(directory)),p)
 if label=='js':
  for p in (directory/'stage').rglob('*'):
   if p.is_file():add('qualified-source/'+str(p.relative_to(directory/'stage')),p)
for p in (HERE/'control-expected').glob('*.json'):add('oracle/'+p.name,p)
directory=ROOT/'.artifacts/relations-phase2-control-source-1791411018905440186'
for p in directory.rglob('*'):
 if p.is_file():add('source-diagnostic/'+str(p.relative_to(directory)),p)
with (out/'objects.tar.gz').open('wb') as raw:
 with gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0) as compressed:
  with tarfile.open(fileobj=compressed,mode='w') as archive:
   for digest,data in sorted(objects.items()):
    info=tarfile.TarInfo(digest);info.size=len(data);info.mtime=0;info.mode=0o644;archive.addfile(info,io.BytesIO(data))
(out/'index.json').write_text(json.dumps({'files':files,'objects':{k:len(v) for k,v in objects.items()},'archiveSHA256':sha((out/'objects.tar.gz').read_bytes()),'scope':'Full independent nonpower30/sparse30/empty2 TS and emitted JS controls; retained CLI5 timeout and foreign IO source diagnostics; no proof/Native/performance acceptance','excluded':'Private environments, generated JS, installed tools/libraries and binaries; generated artifact order is not recomputed by capsule'},indent=2)+'\n')
print(len(files),len(objects))
