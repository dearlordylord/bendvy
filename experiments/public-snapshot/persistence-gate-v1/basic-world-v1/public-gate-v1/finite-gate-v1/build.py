"""Freeze one executed candidate Gate cohort; no child execution."""
import hashlib
import io
import json
from pathlib import Path
import tarfile
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent
OWN=next(p for p in HERE.parents if (p/'AGENTS.md').is_file())
RUN=OWN/'.artifacts/snapshot58-world-public-gate-js-1791489594114846387'
def sha(data):return hashlib.sha256(data).hexdigest()
def main():
 plan=json.loads((RUN/'plan.json').read_bytes());records={};objects={};dispositions={}
 def add(path):
  path=Path(path);data=path.read_bytes();assert not data.startswith(b'\x7fELF')
  digest=sha(data);records[str(path)]={'sha256':digest,'bytes':len(data),'object':'objects/'+digest};objects[digest]=data
 identities=dict(plan['snapshot']['pins'])
 def resources(path,row):
  if row['kind']=='file':identities[path]=row['sha256']
  elif row['kind']=='directory':
   for name,child in row['inventory'].items():resources(path+'/'+name,child)
  elif row['kind']=='symlink':resources(row['resolvedPath'],row['resolved'])
 resources(plan['resourceRoots'][0],plan['installedMembership'])
 for path,digest in plan['pins'].items():
  if path==plan['privateEnvironment']:
   assert digest==plan['environmentSHA256'];dispositions[path]={'sha256':digest,'kind':'private-environment'}
  elif identities.get(path)==digest:dispositions[path]={'sha256':digest,'kind':'installed-identity'}
  else:
   add(path);assert records[path]['sha256']==digest;dispositions[path]={'sha256':digest,'kind':'archived'}
 for path in RUN.rglob('*'):
  if path.is_file() and path.name!='private-environment.json':add(path)
 for path in SOURCE.rglob('*'):
  if path.is_file() and not path.is_relative_to(HERE) and '__pycache__' not in path.parts:add(path)
 join=json.loads((SOURCE/'gate-source-join.json').read_bytes())
 for key in ['original','candidate','canonicalTyped']:add(join[key])
 data=io.BytesIO()
 with tarfile.open(fileobj=data,mode='w:gz') as archive:
  for digest,body in sorted(objects.items()):
   info=tarfile.TarInfo('objects/'+digest);info.size=len(body);info.mtime=0;archive.addfile(info,io.BytesIO(body))
 (HERE/'evidence.tar.gz').write_bytes(data.getvalue())
 (HERE/'index.json').write_text(json.dumps({'scope':'Actual candidate Gate complete BasicWorld finite JS cohort only','run':str(RUN),'candidateRoot':str(SOURCE),'records':records,'pinDispositions':dispositions},indent=2)+'\n')
 files={str(p.relative_to(OWN)):sha(p.read_bytes()) for p in SOURCE.rglob('*') if p.is_file() and p.name!='selection.json' and '__pycache__' not in p.parts}
 (HERE/'selection.json').write_text(json.dumps({'scope':'New public-gate-v1 files only; prior baseline immutable','manifestSelf':'selection.json excluded from recursive self hash','files':files},indent=2)+'\n')
 print('BUILD PASS',len(files),len(records),len(objects))
if __name__=='__main__':main()
