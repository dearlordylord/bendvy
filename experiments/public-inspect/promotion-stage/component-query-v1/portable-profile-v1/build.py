"""Read/hash/archive diagnostic byte evidence; no child execution."""
import pathlib,json,hashlib,tarfile,io
ROOT=pathlib.Path(__file__).resolve().parents[5];HERE=pathlib.Path(__file__).resolve().parent
ROLES={'source':('inspect54-runtime-projection-source01','f94d0a3d2eb88d0c71041bbc8689ac9afe964752958c3f25a5aaa87d08eb14f3','SOURCE_FEASIBILITY_PASS',5),'cpuOriginal':('inspect54-cpu-profile01','ef944dd0b61a0ff7423c05be9d316dc5bda1527d7e652e5c0672b4a04c332024','CPU_PROFILE_DIAGNOSTIC_RETAINED',30),'cacheDeadline':('inspect54-layout-cache-diagnostic01','39f9e2c8a30ce9602cdf8a644f8e3f8b682b053f60099ff750c725bea7a474fd','INCOMPLETE',30),'cpuCached':('inspect54-cached-cpu-profile01','db7ce319ae1fe914348968eccb64a634b6caa2ad5816cd5508e7c96da21fb5a4','CPU_PROFILE_DIAGNOSTIC_RETAINED',30),'heapDeadline':('inspect54-heap-sampling01','f455db55cb5ebf740ebc69753f5849e3b9eb24eb71cbebd5a6ecbae712c5e181','INCOMPLETE',30),'gcDeadline':('inspect54-gc-trace01','d7d4cff722d577aa5bcbc4b67fcfb8e1a8567ae561d84c9df356246c18ae65af','INCOMPLETE',30),'orderedControls':('inspect54-ordered-layout-controls01','77f5d34193d8fd56fdd5ce1c4baf02e070b9d6d405981a4b4553054d01871238','FINITE24_LITERAL_ORIGINALJSON_CONTROLS_PASS',5),'orderedDeadline':('inspect54-ordered-layout-diagnostic01','6a5fe5f50045e3fe4092f8d1b1bcc4447486647b9f166a69f3be2d0bf69d0904','INCOMPLETE',30)}
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
for name in ['OBSERVATION.json','CACHE-COMPARISON.json','LAYOUT-INVESTIGATION.json','heap-sampling-v1/OBSERVATION.json','gc-trace-v1/PROPOSAL.json','gc-trace-v1/PROPOSAL-original-f6b884d6.json','gc-trace-v1/OBSERVATION.json','ordered-layout-v1/SOURCE-MAPPING.json']:
 add(HERE.parent/'cpu-profile-v1'/name)
with tarfile.open(HERE/'objects.tar.gz','w:gz') as archive:
 for digest,q in sorted(objects.items()):
  data=q.read_bytes();info=tarfile.TarInfo('objects/'+digest);info.size=len(data);info.mtime=0;info.mode=0o644;archive.addfile(info,io.BytesIO(data))
index={'scope':'Diagnostic source evidence only; original receipts immutable. Profiles censored/deliberateownedtermination; four C/heap/GC deadlines INCOMPLETE. Finite24 controls no generalJSONproof. No installedELF/Native/perf/adoption/full54 credit.','roles':roles,'records':records,'objectsSHA256':sha(HERE/'objects.tar.gz'),'privateAndBinaryBoundary':'Hash-only explicit exclusions preserve frozen input SHA/size association, not portable execution/tool/environment qualification. No private bytes/binaries shipped.'}
(HERE/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(len(records),len(objects))
