"""Preserve existing evidence bytes; no consumer/backend/probe execution."""
from pathlib import Path
import gzip,hashlib,io,json,tarfile
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
sha=lambda data:hashlib.sha256(data).hexdigest()
DIAGNOSTICS=['1791404936537480876','1791405232836325098','1791405406398348049','1791405705168278010','1791405714972266569','1791405727495724004']
def main():
 out=HERE/'evidence-v1';out.mkdir(exist_ok=True);assert not (out/'index.json').exists();files={};objects={}
 def add(key,path):
  assert path.name!='private-environment.json';data=path.read_bytes();digest=sha(data);files[key]=digest;objects[digest]=data
 for number,stamp in enumerate(DIAGNOSTICS,1):
  directory=ROOT/'.artifacts'/('relations-phase2-source-'+stamp)
  for name in ['receipt.json','stdout.raw','stderr.raw']:add(f'diagnostics/{number}/{name}',directory/name)
  if (directory/'sources').exists():
   for source in sorted((directory/'sources').iterdir()):add(f'diagnostics/{number}/source-bytes/{source.name}',source)
 ambient=ROOT/'.artifacts/relations-phase2-cheap-1791405876464486928'
 for name in ['plan.json','preflight-failure.json','failed-runner-source.py']:add('ambient-guard/'+name,ambient/name)
 for label,stamp in [('cheap','1791406184079972997'),('js','1791406686044666027')]:
  directory=ROOT/'.artifacts'/('relations-phase2-'+('cheap-' if label=='cheap' else 'standalone-js-')+stamp);receipt=json.loads((directory/'receipt.json').read_text());assert receipt['planSHA256']==sha((directory/'plan.json').read_bytes())
  add(label+'/receipt.json',directory/'receipt.json');add(label+'/plan.json',directory/'plan.json')
  for name,digest in receipt['logs'].items():assert sha((directory/name).read_bytes())==digest;add(label+'/'+name,directory/name)
  if label=='js':
   add('js/prepare-receipt.json',directory/'prepare-receipt.json')
   for group in ['prepare-probes','execution-probes']:
    for source in sorted((directory/group).iterdir()):
     assert source.suffix in ['.json','.stdout','.stderr'];add('js/'+group+'/'+source.name,source)
 for source in sorted((HERE/'expected').glob('*.json')):add('oracle/'+source.name,source)
 with (out/'objects.tar.gz').open('wb') as raw:
  with gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0) as compressed:
   with tarfile.open(fileobj=compressed,mode='w') as archive:
    for digest,data in sorted(objects.items()):
     info=tarfile.TarInfo(digest);info.size=len(data);info.mtime=0;info.mode=0o644;archive.addfile(info,io.BytesIO(data))
 index={'scope':'Existing finite phase2 three full30 same-artifact JS cases plus actual cheap TS/BendIO seam and all failed source/ambient diagnostics. Evidence replay only, no fresh backend/proof/performance acceptance.','files':files,'objects':{key:len(value) for key,value in objects.items()},'archiveSHA256':sha((out/'objects.tar.gz').read_bytes()),'excluded':'private environments; generated JS; emitted/source stages; installed tool/library bytes and caches; binaries. Failed development source-byte archives are evidence, not a live source stage.','historicalDiagnosticSourceBytes':'First three source diagnostics retain raw errors and exact source hashes only. Last three also retain the complete local source byte closure. No missing earlier bytes are fabricated.'}
 (out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(files),len(objects),(out/'objects.tar.gz').stat().st_size)
if __name__=='__main__':main()
