"""Read-only finite source diagnostics archive; no child checks or proof credit."""
import pathlib,json,hashlib,tarfile,io,sys
sys.dont_write_bytecode=True
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def sha(b):return hashlib.sha256(b).hexdigest()
def build():
 out=HERE/'portable-static-v1';out.mkdir(exist_ok=False)
 origins=[ROOT/'.artifacts/inspect54-component-authority-positive-dev01',ROOT/'.artifacts/inspect54-component-authority-negatives-1791441058668205363/cohort1',ROOT/'.artifacts/inspect54-component-authority-negatives-1791441058668205363/cohort2']
 files={HERE/'package-static.py',HERE/'authority-controls-v1/CLASSIFICATION-v1.json'};exclusions={}
 for folder in origins:
  p=json.loads((folder/'plan.json').read_text())
  for n,d in p.get('files',p.get('inputs',{})).items():
   q=pathlib.Path(n);b=q.read_bytes();assert sha(b)==d
   if '.private.' in q.name or b.startswith(b'\x7fELF'):exclusions[n]={'sha256':d,'reason':'private environment' if '.private.' in q.name else 'installed executable binary'}
   else:files.add(q)
  files.update(q for q in folder.rglob('*') if q.is_file() and '.private.' not in q.name and '__pycache__' not in q.parts)
 for folder in [HERE/'authority-development-history-v1',HERE/'authority-execution-history-v1',HERE/'authority-controls-v1/proposal-history-v1']:
  files.update(q for q in folder.rglob('*') if q.is_file() and '.private.' not in q.name and '__pycache__' not in q.parts)
 records={};objects={}
 for q in sorted(files):
  b=q.read_bytes();d=sha(b);n='objects/'+d;objects[n]=b;records[str(q)]={'sha256':d,'bytes':len(b),'object':n}
 archive=out/'objects.tar.gz'
 with tarfile.open(archive,'w:gz') as t:
  for n,b in sorted(objects.items()):
   i=tarfile.TarInfo(n);i.size=len(b);i.mtime=0;i.mode=0o644;t.addfile(i,io.BytesIO(b))
 index={'scope':'Finite matched positive and six independently classified source refusals only; original UNCLASSIFIED receipts preserved. No proof/runtime/mutation/Native/adoption/full54 or universal constructor truth.','origins':list(map(str,origins)),'classification':str(HERE/'authority-controls-v1/CLASSIFICATION-v1.json'),'records':records,'hashOnlyExclusions':exclusions,'archiveSHA256':sha(archive.read_bytes())}
 (out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(records),len(objects))
if __name__=='__main__':build()
