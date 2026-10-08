"""Build finite provider-leaf evidence only; never launches a compiler or consumer."""
import hashlib
import io
import json
from pathlib import Path
import tarfile

HERE=Path(__file__).resolve().parent
OWN=HERE.parents[3]
SOURCE=HERE.parent
ROOT=Path('/workspace/formal-proofs/bendvy')
ARTIFACTS=[
 'snapshot58-gate-development-1791472863831246095',
 'snapshot58-shared-leaf-development-1791474625211262054',
 'snapshot58-common-path-development-1791474816018016045',
 'snapshot58-combined-development-1791475275427070476',
 'snapshot58-consumer-development-1791475806491113714',
 'snapshot58-reference-cheap-1791476540315442878',
 'snapshot58-generated-js-1791477969057420368',
 'snapshot58-generated-js-1791478058783669172',
 'snapshot58-generated-js-1791478155693803437',
 'snapshot58-generated-js-1791478856688446160',
 'snapshot58-authority-source-1791478959216460698']

def digest(data):return hashlib.sha256(data).hexdigest()
def read(path):return Path(path).read_bytes()
def main():
 records={};objects={};alternatives={};plans={};private={};identities={}
 def add(path,data=None):
  path=str(path);data=read(path) if data is None else data
  assert not data.startswith(b'\x7fELF'),('ELF excluded',path)
  h=digest(data);records[path]={'sha256':h,'bytes':len(data),'object':'objects/'+h}
  objects[h]=data;alternatives[h]=data
 # Current and preserved experiment bodies: all are own files, excluding transient Python cache.
 for path in SOURCE.rglob('*'):
  if not path.is_file() or path.is_relative_to(HERE) or '__pycache__' in path.parts:continue
  add(path)
 for name in ARTIFACTS:
  directory=OWN/'.artifacts'/name
  assert directory.is_dir(),directory
  for path in directory.rglob('*'):
   if not path.is_file():continue
   if path.name=='private-environment.json':
    private[str(path)]={'sha256':digest(read(path)),'reason':'actual private environment values excluded'};continue
   add(path)
   if path.name=='plan.json':plans[str(path)]=json.loads(read(path))
   if path.name=='source-before.tar.gz':
    with tarfile.open(path,'r:gz') as archive:
     for member in archive.getmembers():
      if member.isfile():
       data=archive.extractfile(member).read();alternatives[digest(data)]=data
 # Identity exclusions must be members of recorded snapshots/resources/actual tool command identities.
 for name,plan in plans.items():
  if 'privateEnvironment' in plan:
   path=plan['privateEnvironment'];assert digest(read(path))==plan['environmentSHA256']
   private[path]={'sha256':plan['environmentSHA256'],'reason':'plan.privateEnvironment exact values excluded','plan':name}
  if 'snapshot' in plan:
   snap=plan['snapshot']
   for path,h in snap['pins'].items():
    identities[path]={'sha256':h,'reason':'recorded installed tool/library/resource identity','plan':name}
  for path,h in plan.get('resourceMembers',{}).items():
   identities[path]={'sha256':h,'reason':'recorded installed resource membership identity','plan':name}
  if isinstance(plan.get('command'),dict):
   command=plan['command']['argv']
   for path in (command[0],command[3]):
    if path in plan.get('pins',{}):identities[path]={'sha256':plan['pins'][path],'reason':'actual Node/taskset command executable identity','plan':name}
 dispositions={}
 for name,plan in plans.items():
  rows={}
  for path,h in (plan.get('pins') or plan.get('sourcePins') or {}).items():
   if path in private:
    assert private[path]['sha256']==h;rows[path]={'sha256':h,'disposition':'excluded-private-environment','association':private[path]}
   elif path in identities and identities[path]['sha256']==h:
    rows[path]={'sha256':h,'disposition':'excluded-installed-identity','association':identities[path]}
   else:
    data=alternatives.get(h)
    if data is None and Path(path).is_file() and digest(read(path))==h:data=read(path)
    assert data is not None,('unresolved consumed source/guard pin',name,path,h)
    add('pin:'+name+':'+path,data)
    rows[path]={'sha256':h,'disposition':'archived','record':'pin:'+name+':'+path}
  dispositions[name]=rows
 index={'scope':'Finite provider-leaf DEVELOPMENT; not Runtime.snapshot/staticGate/full58',
  'historicalOwnRoot':str(OWN),'historicalSourceRoot':str(SOURCE),'historicalRoot':str(ROOT),
  'artifactDirectories':ARTIFACTS,'records':records,'pinDispositions':dispositions,
  'excludedPrivate':private,'excludedInstalledIdentities':identities}
 (HERE/'index.json').write_text(json.dumps(index,indent=2)+'\n')
 with tarfile.open(HERE/'evidence.tar.gz','w:gz') as archive:
  for h,data in sorted(objects.items()):
   info=tarfile.TarInfo('objects/'+h);info.size=len(data);info.mtime=0;info.mode=0o644
   archive.addfile(info,io.BytesIO(data))
 print(json.dumps({'records':len(records),'objects':len(objects),'archiveSHA256':digest(read(HERE/'evidence.tar.gz')),'indexSHA256':digest(read(HERE/'index.json'))}))

if __name__=='__main__':main()
