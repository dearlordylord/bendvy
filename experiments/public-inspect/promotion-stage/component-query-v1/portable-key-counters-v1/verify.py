"""No-child byte/association verifier; no execution qualification."""
import pathlib,json,hashlib,tarfile
H=pathlib.Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
i=json.loads((H/'index.json').read_text());assert sha((H/'objects.tar.gz').read_bytes())==i['objectsSHA256']
with tarfile.open(H/'objects.tar.gz','r:gz') as t:
 members=t.getmembers();assert all(m.isfile() and m.name=='objects/'+m.name.split('/')[-1] and len(m.name.split('/')[-1])==64 for m in members)
 objects={m.name.removeprefix('objects/'):t.extractfile(m).read() for m in members}
 assert len(objects)==len(members) and set(objects)=={r['object'] for r in i['records'].values() if r['kind']=='archived'}
 for digest,b in objects.items():assert sha(b)==digest
for r in i['records'].values():
 if r['kind']=='archived':assert r['object']==r['sha256'] and len(objects[r['object']])==r['bytes']
 else:assert r['kind']=='hash-only' and r['reason'] in ['private environment bytes excluded','binary/tool bytes excluded']

EXCLUDED = {'/workspace/formal-proofs/bendvy-worktrees/parity-54-inspector/.artifacts/inspect54-component-js-1791444260730828728/environment.private.json': 'private environment bytes excluded', '/workspace/formal-proofs/bendvy-worktrees/parity-54-inspector/.artifacts/inspect54-component-js-1791444260730828728/git-environment.private.json': 'private environment bytes excluded', '/home/node/.bend/bin/bend': 'binary/tool bytes excluded', '/home/node/.local/share/mise/installs/node/24.20.0/bin/node': 'binary/tool bytes excluded', '/usr/bin/python3.11': 'binary/tool bytes excluded', '/usr/bin/taskset': 'binary/tool bytes excluded', '/tmp/bendvy-clang19-diagnostic/root/usr/lib/llvm-19/bin/clang': 'binary/tool bytes excluded', '/usr/bin/git': 'binary/tool bytes excluded', '/home/node/.local/opt/dnd-clang14/usr/lib/aarch64-linux-gnu/libz3.so.4': 'binary/tool bytes excluded', '/tmp/bendvy-clang19-diagnostic/root/usr/lib/aarch64-linux-gnu/libLLVM.so.19.1': 'binary/tool bytes excluded', '/tmp/bendvy-clang19-diagnostic/root/usr/lib/aarch64-linux-gnu/libclang-cpp.so.19.1': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libbsd.so.0.11.7': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libc.so.6': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libdl.so.2': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libedit.so.2.0.70': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libexpat.so.1.8.10': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libffi.so.8.1.2': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libgcc_s.so.1': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libicudata.so.72.1': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libicuuc.so.72.1': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/liblzma.so.5.4.1': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libm.so.6': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libmd.so.0.0.5': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libpthread.so.0': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libstdc++.so.6.0.30': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libtinfo.so.6.4': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libxml2.so.2.9.14': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libz.so.1.2.13': 'binary/tool bytes excluded', '/usr/lib/aarch64-linux-gnu/libzstd.so.1.5.4': 'binary/tool bytes excluded', '/workspace/formal-proofs/bendvy-worktrees/parity-54-inspector/.artifacts/inspect54-runtime-projection-source01/environment.private.json': 'private environment bytes excluded', '/usr/bin/dash': 'binary/tool bytes excluded', '/usr/bin/timeout': 'binary/tool bytes excluded', '/workspace/formal-proofs/bendvy-worktrees/parity-54-inspector/.artifacts/inspect54-cpu-profile01/environment.private.json': 'private environment bytes excluded', '/workspace/formal-proofs/bendvy-worktrees/parity-54-inspector/.artifacts/inspect54-key-counters02/environment.private.json': 'private environment bytes excluded', '/workspace/formal-proofs/bendvy-worktrees/parity-54-inspector/.artifacts/inspect54-term-identity01/environment.private.json': 'private environment bytes excluded'}
assert {n:r['reason'] for n,r in i['records'].items() if r['kind']=='hash-only'}==EXCLUDED
def data(n):
 r=i['records'][n];assert r['kind']=='archived';return objects[r['object']]
selection=json.loads((H/'SELECTED-DELIVERY-FILES.json').read_text())
assert set(selection['files'])=={str(H.relative_to(H.parents[4])/n) for n in ['build.py','verify.py','README.md','index.json','objects.tar.gz']}
assert selection['self']==str(H.relative_to(H.parents[4])/'SELECTED-DELIVERY-FILES.json')
for path,digest in selection['files'].items():assert sha((H.parents[4]/path).read_bytes())==digest
plans={n:json.loads(data(n)) for n,r in i['records'].items() if n.endswith('/plan.json') and r['kind']=='archived'}
private={p['environment'] for p in plans.values() if 'environment' in p and p['environment'] in i['records']}
for p in plans.values():
 if 'environment' in p and p['environment'] in i['records']:assert i['records'][p['environment']]['sha256']==p['environmentSHA256']
snapshotNames=[n for n in i['records'] if n.endswith('/inspect54-component-js-1791444260730828728/tool-snapshot.json')]
assert len(snapshotNames)==1
snapshot=json.loads(data(snapshotNames[0])); snapshotRoot=str(pathlib.PurePosixPath(snapshotNames[0]).parent)
private.update([snapshotRoot+'/environment.private.json',snapshotRoot+'/git-environment.private.json'])
for n in [snapshotRoot+'/environment.private.json',snapshotRoot+'/git-environment.private.json']:
 assert any(p.get('inputs',{}).get(n)==i['records'][n]['sha256'] for p in plans.values())
assert {n for n,reason in EXCLUDED.items() if reason=='private environment bytes excluded'}==private
for n,reason in EXCLUDED.items():
 if reason=='binary/tool bytes excluded' and n not in ['/usr/bin/git','/usr/bin/dash','/usr/bin/timeout']:
  assert snapshot['pins'][n]==i['records'][n]['sha256']
# These exact established command utilities are separately bound by the source history inputs.
for n in ['/usr/bin/git','/usr/bin/dash','/usr/bin/timeout']:
 assert any(p.get('inputs',{}).get(n)==i['records'][n]['sha256'] for p in plans.values())
expectedRoles={'counterDeadline':dict(plan='0c4fa2ddef2a67caf0a6b485df6f48d50d6c7c5779c58c541908a66b552f914d',receipt='619a90a3f86d4b2c26716a063ba58511a13e7339e9967d8338d21226c7a91e3c',final='selection:pair~20',calls=602010,units=153670197,completed=3303),'identityDeadline':dict(plan='eaf60b4ff44a19ad6588aa83d0b4e21aedcbdb3f60c60c8ccd9d3697d4be2034',receipt='8c45334228456bf6a9112792eb855d1a161262453218d1029e7484e2009bb35a',final='selection:map_project~2',calls=627013,units=159979313,completed=3482)}
assert set(i['roles'])==set(expectedRoles)
for role,expected in expectedRoles.items():
 z=i['roles'][role]
 p=json.loads(data(z['plan']));r=json.loads(data(z['receipt']))
 assert sha(data(z['plan']))==z['planSHA256']==expected['plan']
 assert sha(data(z['receipt']))==z['receiptSHA256']==expected['receipt']
 assert r['planSHA256']==z['planSHA256'] and r['status']=='INCOMPLETE' and r['failure']=='child deadline' and r.get('guardFailures',[])==[]
 out=str(pathlib.PurePosixPath(z['plan']).parent)
 assert p['command']==['/usr/bin/taskset','-c','5','/home/node/.local/share/mise/installs/node/24.20.0/bin/node',out+'/driver.mjs',p['target'],out+'/diagnostic.c'] and p['seconds']==30
 for n,d in p['inputs'].items():
  entries=d.items() if isinstance(d,dict) else [('',d)]
  for rel,digest in entries:
   path=str(pathlib.PurePosixPath(n)/rel) if rel else n
   assert i['records'][path]['sha256']==digest
   if i['records'][path]['kind']=='archived':assert sha(data(path))==digest
 assert i['records'][p['environment']]['sha256']==p['environmentSHA256']
 assert sha(data(p['target']))==p['targetSHA256']
 for name,digest in p['stageInventory'].items():assert sha(data(str(pathlib.PurePosixPath(p['stage'])/name)))==digest
 stageprefix=p['stage']+'/'
 assert {n[len(stageprefix):] for n in i['records'] if n.startswith(stageprefix)}==set(p['stageInventory'])
 for name,target in p['symlinks'].items():
  assert name.endswith('/compiler/base.bend') or name.endswith('/compiler/effs')
  assert target=='/home/node/.bend/bend2/'+pathlib.PurePosixPath(name).name
  if name.endswith('base.bend'):assert data(name)==data(target)
  else:
   members=p['inputs'][target]
   for rel,digest in members.items():assert i['records'][target+'/'+rel]['sha256']==digest
 assert set(r['captured'])=={'stdout.raw','stderr.raw'}
 assert {pathlib.PurePosixPath(n).name for n in i['records'] if str(pathlib.PurePosixPath(n).parent)==out and pathlib.PurePosixPath(n).suffix in ['.raw','.c']}==set(r['captured'])
 for name,digest in r['captured'].items():assert sha(data(out+'/'+name))==digest
 assert data(out+'/stdout.raw')==b''
 rows=[json.loads(x) for x in data(out+'/stderr.raw').splitlines()];counts=[x for x in rows if x['event'].startswith('key-counts-')]
 last=counts[-1];assert last['event']=='key-counts-definition-enter' and last['definition']==expected['final']
 assert last['calls']==expected['calls'] and last['keyUnits']==expected['units']
 assert sum(x['event']=='key-counts-definition-enter' for x in rows)==expected['completed']+1 and sum(x['event']=='key-counts-definition-exit' for x in rows)==expected['completed']
 for x in counts:
  assert x['calls']==x['hits']+x['misses']
  if role=='identityDeadline':assert x['calls']==x['identityFirst']+x['identityRepeat'] and x['keyUnits']==x['firstKeyUnits']+x['repeatKeyUnits']
 if role=='identityDeadline':assert last['identityFirst']==82656 and last['identityRepeat']==544357 and last['repeatKeyUnits']==149355015
print(json.dumps({'status':'PORTABLE_COUNTER_DIAGNOSTIC_BYTE_EVIDENCE_PASS','records':len(i['records']),'objects':len(objects)}))
