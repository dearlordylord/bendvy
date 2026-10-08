"""Portable no-child finite two-schema Native192 evidence verifier."""
import hashlib,json,tarfile,runpy
from pathlib import Path
H=Path(__file__).resolve().parent;J=H.parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def strict(x):
 if isinstance(x,dict):return ('dict',tuple((k,strict(v)) for k,v in sorted(x.items())))
 if isinstance(x,list):return ('list',tuple(map(strict,x)))
 return (type(x).__name__,x)
with tarfile.open(H/'evidence.tar.gz') as t:
 members=t.getmembers();assert len({m.name for m in members})==len(members) and all(m.isfile() for m in members)
 raw={m.name:t.extractfile(m).read() for m in members}
assert raw['index.json']==(H/'index.json').read_bytes()
i=json.loads(raw['index.json']);rows={r['name']:r for r in i['records']};assert len(rows)==len(i['records'])
assert set(raw)=={'index.json'}|{'objects/'+r['SHA256'] for r in rows.values()}
files={}
for n,r in rows.items():
 b=raw['objects/'+r['SHA256']];assert sha(b)==r['SHA256'] and len(b)==r['bytes'];files[n]=b
for folder,key in (('finite-evidence-v1','normalArchiveSHA256'),('controls-evidence-v1','controlsArchiveSHA256')):
 assert sha((J/folder/'evidence.tar.gz').read_bytes())==i[key]
 runpy.run_path(str(J/folder/'verify.py'),run_name='prerequisite_evidence_only')
prefix='/workspace/formal-proofs/bendvy-worktrees/parity-42-relations/'
def path(n):return 'worktree/'+n[len(prefix):] if n.startswith(prefix) else 'external/'+n.lstrip('/')
def obj(n):return json.loads(files[n])
a=i['actual'];p=obj(a+'/plan.json');r=obj(a+'/receipt.json');q=obj(a+'/prepare-receipt.json')
assert sha(files[a+'/plan.json'])=='b75e52d39b78f6b2dd8699d7698027cc144f361687c125528dad1ff48c0afb9a'
assert sha(files[a+'/receipt.json'])=='3502aa3cc241c698b5908c76e6a3bbdf513158ee72fe31ddc8a88a72016eef4a'
assert r['planSHA256']==sha(files[a+'/plan.json']) and r['status']=='DEVELOPMENT_TWO_SCHEMA_NATIVE_COMPLETE192_JOIN_PASS_NOT_FULL55' and r.get('guardFailures',[])==[] and r['full192JoinMatched'] is True
for n,h in p['pins'].items():
 if path(n) in files:assert sha(files[path(n)])==h
 else:assert i['excluded'][n]['SHA256']==h
assert i['excluded'][p['privateEnvironment']]['SHA256']==p['environmentSHA256']
assert q['status']=='OWNED_NATIVE_PREPARATION_PASS' and q['probeCommandsExecuted']==5 and r['probeCommandsExecuted']==65
for rec,folder,labels in ((q,'prepare-probes',['prepare-'+x for x in ('bend','node','python','taskset','clang')]),(r,'execution-probes',p['executionProbeLabels'])):
 assert set(rec['probePins'])=={str(Path(prefix)/a.removeprefix('worktree/')/folder/(label+suffix)) for label in labels for suffix in ('.json','.stdout','.stderr')}
 for n,h in rec['probePins'].items():assert sha(files[path(n)])==h
 for label in labels:
  m=obj(a+'/'+folder+'/'+label+'.json');tool=label.rsplit('-',1)[-1]
  assert m['argv']==[p['tools']['taskset'],'-c','5',p['tools']['ldd'],p['tools']['tools'][tool]] and m['seconds']==5 and m['exit']==0 and m['failure'] is None
  assert m['runnerSHA256']==p['pins'][prefix+'scripts/task_runner.py'] and m.get('exception') is None
 assert {n for n in files if n.startswith(a+'/'+folder+'/')}=={a+'/'+folder+'/'+label+suffix for label in labels for suffix in ('.json','.stdout','.stderr')}
assert len(r['commands'])==len(p['commands'])==6
assert set(r['logs'])=={c['label']+s for c in p['commands'] for s in ('.stdout','.stderr')}
for n,h in r['logs'].items():assert sha(files[a+'/'+n])==h
for pc,rc in zip(p['commands'],r['commands']):
 assert all(pc[k]==rc[k] for k in ('label','argv','seconds')) and rc['exit']==0 and rc['failure'] is None
 assert rc['seconds']==(30 if rc['label'].startswith('emit-') else 120 if rc['label'].startswith('compile-') else 5)
 for s in ('.stdout','.stderr'):
  if not rc['label'].startswith('run-') or s=='.stderr':assert files[a+'/'+rc['label']+s]==b''
for n,h in r['generated'].items():
 if n.endswith('.c'):assert sha(files[path(n)])==h
 else:assert i['excluded'][n]['SHA256']==h
schemas=[]
for family in ('workshop','garden'):
 rc=next(c for c in r['commands'] if c['label']=='run-'+family);b=files[a+'/run-'+family+'.stdout'];assert b.endswith(b'\n')
 expected=obj(path(rc['oracle']));actual=json.loads(b);assert strict(actual)==strict(expected) and rc['fullOracleMatched'] is True and sha(files[path(rc['oracle'])])==rc['oracleSHA256']
 assert sum(len(phase['queries']) for phase in actual['phases'])==96
 schemas.append(b[:-1])
expected=obj(i['fixture']+'/expected-relations-v2.json')
assert strict({'schemas':[json.loads(b) for b in schemas],'scope':expected['scope']})==strict(expected)
# Exact framing is copied from the qualified source wrapper, never an output shortcut.
combined=b'{"schemas":['+schemas[0]+b','+schemas[1]+b'],"scope":"finite relation Inspector development fixture; no full55 qualification"}\n'
assert sha(combined)==r['combinedFull192RawSHA256']
historical='worktree/.artifacts/inspector-relation55-boundary-io-1791441401493444111/boundary-io.stdout'
assert combined==files[historical]
assert r['combinedFull192RawSHA256']=='1f77fc287558d50259815ad59992c6c085d03c9174fbf8cb8d74adf78d8a7b15'
for n,h in p['inventory'].items():assert sha(files[path(str(Path(p['stage'])/n))])==h
for row in p['stageImportJoins']:
 assert sha(files[path(row['originalTarget'])])==sha(files[path(row['actualTarget'])])==row['SHA256']
 assert files[path(row['source'])]==files[path(row['copy'])]
print('PASS finite two-schema Native192 evidence; no backend/full55/performance claim')
