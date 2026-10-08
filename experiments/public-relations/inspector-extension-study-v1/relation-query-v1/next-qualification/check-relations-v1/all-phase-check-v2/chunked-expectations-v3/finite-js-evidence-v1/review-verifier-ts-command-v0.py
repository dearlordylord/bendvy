"""Portable no-child verification of complete Check320 and192 diagnostic JS consumer."""
from pathlib import Path
import hashlib,json,tarfile,runpy,tempfile
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
i=json.loads(raw['index.json']);rows={r['name']:r for r in i['records']};assert len(rows)==len(i['records']) and set(raw)=={'index.json'}|{'objects/'+r['SHA256'] for r in rows.values()}
f={}
for n,r in rows.items():
 b=raw['objects/'+r['SHA256']];assert sha(b)==r['SHA256'] and len(b)==r['bytes'];f[n]=b
prefix='/workspace/formal-proofs/bendvy-worktrees/parity-42-relations/'
def path(n):return 'worktree/'+n[len(prefix):] if n.startswith(prefix) else 'external/'+n.lstrip('/')
def obj(n):return json.loads(f[n])
a=i['actual'];p=obj(a+'/plan.json');r=obj(a+'/receipt.json');q=obj(a+'/prepare-receipt.json')
assert sha(f[a+'/plan.json'])=='49647d8cbb7a4d4f979b808c464aca3b88b67e74aa000141abeac0058925997e'==r['planSHA256']
assert sha(f[a+'/receipt.json'])=='d76961ef23f206b031968eff9f4f4c0cebe1b6050c40ec4faf761bbc3a4c9e79'
assert r['status']=='DEVELOPMENT_STANDALONE_JS_CHECK320_PLUS192_DIAGNOSTICS_PASS_NOT_FULL55' and r.get('guardFailures',[])==[]
for n,h in p['pins'].items():
 if path(n) in f:assert sha(f[path(n)])==h
 else:assert i['excluded'][n]['SHA256']==h
assert i['excluded'][p['privateEnvironment']]['SHA256']==p['environmentSHA256']
assert q['status']=='OWNED_JS_PREPARATION_PASS' and q['probeCommandsExecuted']==4 and r['probeCommandsExecuted']==20
for record,folder,labels in ((q,'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset')]),(r,'execution-probes',p['executionProbeLabels'])):
 expected={a+'/'+folder+'/'+label+suffix for label in labels for suffix in ('.json','.stdout','.stderr')}
 assert set(map(path,record['probePins']))==expected=={n for n in f if n.startswith(a+'/'+folder+'/')}
 for n,h in record['probePins'].items():assert sha(f[path(n)])==h
 for label in labels:
  m=obj(a+'/'+folder+'/'+label+'.json');tool=label.rsplit('-',1)[-1]
  assert m['argv']==[p['tools']['taskset'],'-c','5',p['tools']['ldd'],p['tools']['tools'][tool]] and m['seconds']==5 and m['exit']==0 and m['failure'] is None and m.get('exception') is None and m['runnerSHA256']==p['pins'][prefix+'scripts/task_runner.py']
assert len(p['commands'])==len(r['commands'])==2
assert set(r['logs'])=={c['label']+s for c in p['commands'] for s in ('.stdout','.stderr')}
for n,h in r['logs'].items():assert sha(f[a+'/'+n])==h
notice=f[path(prefix+'experiments/public-relations/inspector-extension-study-v1/pinned-bend-notice.bytes')];assert len(notice)==42 and sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
for pc,rc in zip(p['commands'],r['commands']):
 assert all(pc[k]==rc[k] for k in ('label','argv','seconds')) and rc['exit']==0 and rc['failure'] is None and rc['status']=='QUALIFIED'
 if 'artifact' in pc:
  assert rc['seconds']==30 and f[a+'/'+rc['label']+'.stdout']==b''
  # Exact compiler notice is independently selected from pinned notice.bytes below.
  stderr=f[a+'/'+rc['label']+'.stderr'];assert stderr in (b'',notice)
 else:
  assert rc['seconds']==5 and f[a+'/'+rc['label']+'.stderr']==b''
  b=f[a+'/'+rc['label']+'.stdout'];text=b.decode();actual,end=json.JSONDecoder().raw_decode(text);assert text[end:].encode()==b'\n'
  assert strict(actual)==strict(obj(path(rc['oracle']))) and sha(f[path(rc['oracle'])])==rc['oracleSHA256'] and rc['fullOracleMatched'] is True
  assert sum(len(phase['queries']) for schema in actual['schemas'] for phase in schema['phases'])==192
  assert all(schema['gate']['bodyMarkers']==1 and schema['gate']['allowed']==[{'ran':1}] and schema['gate']['skipped']==[{'skipped':1}] for schema in actual['schemas'])
for n,h in r['generated'].items():assert n.endswith('.js') and sha(f[path(n)])==h
assert {n for n in f if n.startswith(path(p['stage'])+'/')}=={path(str(Path(p['stage'])/n)) for n in p['inventory']}
for n,h in p['inventory'].items():assert sha(f[path(str(Path(p['stage'])/n))])==h
for row in p['stageImportJoins']:
 assert sha(f[path(row['originalTarget'])])==sha(f[path(row['actualTarget'])])==row['SHA256']
 assert f[path(row['source'])]==f[path(row['copy'])]
assert len(r['generated'])==1
# Historical success and failures remain distinct immutable receipts.
def history(folder,digest):
 h='worktree/.artifacts/'+folder;hp=obj(h+'/plan.json');hr=obj(h+'/receipt.json')
 assert sha(f[h+'/receipt.json'])==digest and sha(f[h+'/plan.json'])==hr['planSHA256']
 for n,d in hp['pins'].items():
  if path(n) in f:assert sha(f[path(n)])==d
  else:assert i['excluded'][n]['SHA256']==d
 assert i['excluded'][hp['privateEnvironment']]['SHA256']==hp['environmentSHA256']
 for n,d in hr.get('logs',{}).items():assert sha(f[h+'/'+n])==d
 return h,hp,hr
ts,tp,tr=history('check-relation55-ts-1791455293147900891','338540d86c1097cefa9106e28eda985d04fa4829779a48ad1d76ed877bf779e8')
assert tr['status']=='DEVELOPMENT_ACTUAL_TS_CHECK192_PLUS128_PASS_NOT_FULL55' and tr.get('guardFailures',[])==[]
assert len(tr['commands'])==1 and set(tr['logs'])=={'ts-relations.stdout','ts-relations.stderr'}
tc=tr['commands'][0];assert tc['argv']==tp['command'] and tc['seconds']==5 and tc['exit']==0 and tc['failure'] is None and tc['fullOracleMatched'] is True
assert f[ts+'/ts-relations.stderr']==b''
assert strict(json.loads(f[ts+'/ts-relations.stdout']))==strict(obj(path(tp['oracle'])))
assert sha(f[path(tp['oracle'])])==tc['oracleSHA256']
io,ip,ir=history('check-relation55-boundary-io-1791455550381679103','2fd0c06cf9470d6a60df8a7cc603ad99f73b41932df4a04411599262e85f542c')
em,ep,er=history('check-relation55-standalone-js-1791456378843042105','4dbb74c6498522c3d211c1f64e089082a695863d0d2c20986ce3cca1769c097d')
fault=b'Error: the machine stack overflowed (a deep recursion, or a literal too large to expand)\n'
for h,hr,label,cap in ((io,ir,'check-io',5),(em,er,'emit-check',30)):
 assert hr['status']=='INCOMPLETE' and hr.get('guardFailures',[])==[] and len(hr['commands'])==1
 c=hr['commands'][0];assert c['label']==label and c['seconds']==cap and c['exit']==1 and c['failure'] is None
 assert set(hr['logs'])=={label+'.stdout',label+'.stderr'} and f[h+'/'+label+'.stdout']==b'' and f[h+'/'+label+'.stderr']==fault
assert er['generated']=={} and er['probeCommandsExecuted']==12
for rec,folder,labels in ((er,'execution-probes',ep['executionProbeLabels'][:12]),(obj(em+'/prepare-receipt.json'),'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset')])):
 assert len(labels)==rec['probeCommandsExecuted'];expected={em+'/'+folder+'/'+label+suffix for label in labels for suffix in ('.json','.stdout','.stderr')}
 assert set(map(path,rec['probePins']))==expected
 for n,d in rec['probePins'].items():assert sha(f[path(n)])==d
 for label in labels:
  m=obj(em+'/'+folder+'/'+label+'.json');tool=label.rsplit('-',1)[-1]
  assert m['argv']==[ep['tools']['taskset'],'-c','5',ep['tools']['ldd'],ep['tools']['tools'][tool]] and m['seconds']==5 and m['exit']==0 and m['failure'] is None and m.get('exception') is None and m['runnerSHA256']==ep['pins'][prefix+'scripts/task_runner.py']
initial,initialp,initialr=history('check-relation55-boundary-io-1791455297025118623','722f2f89d7b3d8b7055bedc13910d4f35c6fe399cc666861aba78ec545032c14')
assert initialr['status']=='INCOMPLETE' and initialr['commands']==[]
print('PASS: finite Check320 plus192 separate diagnostics/selected owners; no backend replay/full55/performance claim')
