"""Read/hash/archive diagnostic byte evidence; no child execution."""
import pathlib,json,hashlib,tarfile,io
ROOT=pathlib.Path(__file__).resolve().parents[5];HERE=pathlib.Path(__file__).resolve().parent
ROLES={'counterDeadline':('inspect54-key-counters02','0c4fa2ddef2a67caf0a6b485df6f48d50d6c7c5779c58c541908a66b552f914d','INCOMPLETE',30),'identityDeadline':('inspect54-term-identity01','eaf60b4ff44a19ad6588aa83d0b4e21aedcbdb3f60c60c8ccd9d3697d4be2034','INCOMPLETE',30)}
sha=lambda q:hashlib.sha256(q.read_bytes()).hexdigest()
records={};objects={};roles={}
def add(q,expected=None):
 q=pathlib.Path(q);data=q.read_bytes();digest=hashlib.sha256(data).hexdigest();assert expected is None or digest==expected,str(q)
 private='environment' in q.name.lower() or '.private.' in q.name.lower()
 binary=data.startswith(b'\x7fELF') or b'\0' in data[:4096]
 entry={'sha256':digest,'bytes':len(data)}
 if private or binary:entry.update(kind='hash-only',reason='private environment bytes excluded' if private else 'binary/tool bytes excluded')
 else:entry.update(kind='archived',object=digest);objects.setdefault(digest,q)
 if str(q) in records:assert records[str(q)]==entry
 records[str(q)]=entry
for role,(directory,digest,status,cap) in ROLES.items():
 path=ROOT/'.artifacts'/directory/'plan.json';add(path,digest);p=json.loads(path.read_text());receipt=path.parent/'receipt.json';add(receipt);r=json.loads(receipt.read_text());assert r['planSHA256']==digest and r['status']==status and r.get('guardFailures',[])==[]
 assert p['seconds']==cap and p['command'][:3]==['/usr/bin/taskset','-c','5']
 if status=='INCOMPLETE':assert r['failure']=='child deadline'
 else:assert r['exit']==0 and r['failure'] is None
 for name,d in r.get('captured',r.get('logs',{})).items():add(path.parent/name,d)
 for name,d in p['inputs'].items():
  if isinstance(d,dict):
   for rel,value in d.items():add(pathlib.Path(name)/rel,value)
  else:add(name,d)
 roles[role]={'plan':str(path),'planSHA256':digest,'receipt':str(receipt),'receiptSHA256':sha(receipt),'status':status,'seconds':cap}
add(HERE.parent/'cpu-profile-v1/key-counters-v1/OBSERVATION.json')
add(HERE.parent/'cpu-profile-v1/term-identity-v1/OBSERVATION.json')
with tarfile.open(HERE/'objects.tar.gz','w:gz') as archive:
 for digest,q in sorted(objects.items()):
  data=q.read_bytes();info=tarfile.TarInfo('objects/'+digest);info.size=len(data);info.mtime=0;info.mode=0o644;archive.addfile(info,io.BytesIO(data))
index={'scope':'Counter diagnostic byte evidence only, original deadline INCOMPLETE; counts presence-entry/UTF16 only, no retainedbytes/allocation/cost/Native/adoption credit.','roles':roles,'records':records,'objectsSHA256':sha(HERE/'objects.tar.gz'),'privateAndBinaryBoundary':'Hash-only explicit exclusions preserve frozen input SHA/size association, not portable execution/tool/environment qualification. No private bytes/binaries shipped.'}
(HERE/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(records),len(objects))
