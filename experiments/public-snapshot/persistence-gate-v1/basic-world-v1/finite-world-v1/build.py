"""Build whole named basicWorld fixture evidence only; never launches a compiler or consumer."""
import hashlib
import io
import json
from pathlib import Path
import tarfile

HERE=Path(__file__).resolve().parent
OWN=HERE.parents[4]
SOURCE=HERE.parent
ROOT=Path('/workspace/formal-proofs/bendvy')
ARTIFACTS=['snapshot58-basic-world-source-1791480955687464703', 'snapshot58-world-before-capacity-repair-1791485366831094864', 'snapshot58-world-capacity-consumer-source-1791485561777652085', 'snapshot58-world-capacity-js-1791485717075416264', 'snapshot58-world-capacity-proposal-history-1791485542732335611', 'snapshot58-world-capacity-source-1791485440601533680', 'snapshot58-world-fixture-source-1791481136503359248', 'snapshot58-world-fixture-source-1791481354563980995', 'snapshot58-world-fixture-source-1791481494830562538', 'snapshot58-world-fixture-source-1791481670239387297', 'snapshot58-world-fixture-source-1791481869961182121', 'snapshot58-world-fixture-source-1791481894404130174', 'snapshot58-world-fixture-source-1791481931426663859', 'snapshot58-world-fixture-source-1791481978895403828', 'snapshot58-world-fixture-source-1791482025372995682', 'snapshot58-world-fixture-source-1791482076401044380', 'snapshot58-world-fixture-source-1791482211001257198', 'snapshot58-world-fixture-source-1791482954716561025', 'snapshot58-world-generated-js-1791484947448693445', 'snapshot58-world-io-cheap-1791484637066871097', 'snapshot58-world-reference-cheap-1791483992999401767', 'snapshot58-world-reference-source-history']

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
  if 'installedMembership' in plan:
   root=plan.get('installedResource') or plan['resourceRoots'][0]
   def resource_files(path,value):
    if value.get('kind')=='file':
     identities[path]={'sha256':value['sha256'],'reason':'recorded installed resource membership identity','plan':name}
    elif value.get('kind')=='directory':
     for child,row in value['inventory'].items():resource_files(path+'/'+child,row)
    elif value.get('kind')=='symlink':resource_files(value['resolvedPath'],value['resolved'])
   resource_files(root,plan['installedMembership'])
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
  for path,h in (plan.get('pins') or plan.get('sourcePins') or plan.get('consumedClosure',{}).get('sourcePins') or {}).items():
   if path in private:
    assert private[path]['sha256']==h;rows[path]={'sha256':h,'disposition':'excluded-private-environment','association':private[path]}
   elif path in identities and identities[path]['sha256']==h:
    rows[path]={'sha256':h,'disposition':'excluded-installed-identity','association':identities[path]}
   else:
    data=alternatives.get(h)
    if data is None and Path(path).is_file() and digest(read(path))==h:data=read(path)
    if data is None and name.endswith('/snapshot58-basic-world-source-1791480955687464703/plan.json') and path.endswith('/basic-world-v1/source-positive.bend') and h=='004762759ead8ad84d361a06bef6485051f53ab7c1c987456cfffe0c1dd1aa83':
     rows[path]={'sha256':h,'disposition':'historical-unavailable-source','reason':'Initial generic export refused before actual fixture. Entry bytes were not archived; exact old plan hash metadata only, never current qualification authority.'}
     continue
    assert data is not None,('unresolved consumed source/guard pin',name,path,h)
    add('pin:'+name+':'+path,data)
    rows[path]={'sha256':h,'disposition':'archived','record':'pin:'+name+':'+path}
  dispositions[name]=rows
 index={'scope':'Whole two-schema basicWorld experimental DEVELOPMENT; no public save Gate/Native/full58 adoption',
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
