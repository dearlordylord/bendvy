"""Portable existing Native evidence only; no children/tool/backend execution."""
from pathlib import Path
import gzip,hashlib,io,json,tarfile
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[5]
sha=lambda data:hashlib.sha256(data).hexdigest()
def main():
 directory=ROOT/'.artifacts/relations-phase2-native-anchor-1791409945667291493';out=HERE/'native-evidence-v1';out.mkdir(exist_ok=True);assert not (out/'index.json').exists();files={};objects={}
 def add(key,path):
  assert path.name!='private-environment.json';data=path.read_bytes();digest=sha(data);files[key]=digest;objects[digest]=data
 receipt=json.loads((directory/'receipt.json').read_text());assert receipt['status']=='THREE_RUNTIME_INPUT_COMPLETE30_NATIVE_CONSUMERS_PASS_NO_TIMING_VERDICT' and receipt['planSHA256']==sha((directory/'plan.json').read_bytes())
 for name in ['receipt.json','plan.json','prepare-receipt.json']:add('native/'+name,directory/name)
 for name,digest in receipt['logs'].items():assert sha((directory/name).read_bytes())==digest;add('native/'+name,directory/name)
 for group in ['prepare-probes','execution-probes']:
  for source in sorted((directory/group).iterdir()):
   assert source.suffix in ['.json','.stdout','.stderr'];add('native/'+group+'/'+source.name,source)
 for source in sorted((HERE.parent/'expected').glob('*.json')):add('oracle/'+source.name,source)
 with (out/'objects.tar.gz').open('wb') as raw:
  with gzip.GzipFile(filename='',fileobj=raw,mode='wb',mtime=0) as compressed:
   with tarfile.open(fileobj=compressed,mode='w') as archive:
    for digest,data in sorted(objects.items()):
     info=tarfile.TarInfo(digest);info.size=len(data);info.mtime=0;info.mode=0o644;archive.addfile(info,io.BytesIO(data))
 index={'scope':'Finite same Native binary three runtime input complete30 results, five subjects and60owned probes. Portable evidence reconciliation only; no timing/scaling/full-parity acceptance.','files':files,'objects':{digest:len(data) for digest,data in objects.items()},'archiveSHA256':sha((out/'objects.tar.gz').read_bytes()),'excluded':'Private child environment, source stage, generated C, Native binary, installed tool/library bytes and caches. Generated targets are retained by original receipt hashes only.'};(out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(files),len(objects),(out/'objects.tar.gz').stat().st_size)
if __name__=='__main__':main()
