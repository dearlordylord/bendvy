"""Portable no-child verification of complete standalone JS normal and three reached controls."""
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
assert sha(f[a+'/plan.json'])=='fb5920b74f256282f79966995a319278607bf671d8b29ad97f9f97b388f07acd'==r['planSHA256']
assert sha(f[a+'/receipt.json'])=='e029881f057af66dd66791e35725c050746d6d3acf2abb8877664ddcd957cc83'
assert r['status']=='DEVELOPMENT_STANDALONE_JS_NORMAL_AND_THREE_RELATION192_CONTROLS_NOT_FULL55' and r.get('guardFailures',[])==[]
for n,h in p['pins'].items():
 if path(n) in f:assert sha(f[path(n)])==h
 else:assert i['excluded'][n]['SHA256']==h
assert i['excluded'][p['privateEnvironment']]['SHA256']==p['environmentSHA256']
assert q['status']=='OWNED_JS_PREPARATION_PASS' and q['probeCommandsExecuted']==4 and r['probeCommandsExecuted']==68
for record,folder,labels in ((q,'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset')]),(r,'execution-probes',p['executionProbeLabels'])):
 expected={a+'/'+folder+'/'+label+suffix for label in labels for suffix in ('.json','.stdout','.stderr')}
 assert set(map(path,record['probePins']))==expected=={n for n in f if n.startswith(a+'/'+folder+'/')}
 for n,h in record['probePins'].items():assert sha(f[path(n)])==h
 for label in labels:
  m=obj(a+'/'+folder+'/'+label+'.json');tool=label.rsplit('-',1)[-1]
  assert m['argv']==[p['tools']['taskset'],'-c','5',p['tools']['ldd'],p['tools']['tools'][tool]] and m['seconds']==5 and m['exit']==0 and m['failure'] is None and m.get('exception') is None and m['runnerSHA256']==p['pins'][prefix+'scripts/task_runner.py']
assert len(p['commands'])==len(r['commands'])==8
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
  assert strict(actual)==strict(obj(path(rc['oracle']))) and sha(f[path(rc['oracle'])])==rc['oracleSHA256'] and rc['fullOracleMatched'] is True and rc['fullRawIOMatched'] is True
  assert sum(len(phase['queries']) for schema in actual['schemas'] for phase in schema['phases'])==192
  case=rc['case'];baseline='worktree/.artifacts/inspector-relation55-boundary-io-1791441401493444111/boundary-io.stdout' if case=='normal' else 'worktree/.artifacts/inspector-relation55-mutant-io-1791443937298190588/'+case+'.stdout'
  assert b==f[baseline]
  if case!='normal':
   def differences(a,b,p=''):
    if type(a)!=type(b):return [{'path':p,'normal':a,'mutant':b}]
    if isinstance(a,dict):
     result=[]
     for key in sorted(a.keys()|b.keys()):
      if key not in a or key not in b:result.append({'path':p+'/'+key,'normal':a.get(key),'mutant':b.get(key)})
      else:result+=differences(a[key],b[key],p+'/'+key)
     return result
    if isinstance(a,list):
     if len(a)!=len(b):return [{'path':p,'normal':a,'mutant':b}]
     return [d for i,(x,y) in enumerate(zip(a,b)) for d in differences(x,y,p+'/'+str(i))]
    return [] if a==b else [{'path':p,'normal':a,'mutant':b}]
   witness=differences(obj(i['fixture']+'/expected-relations-v2.json'),actual)
   expected=obj(i['fixture']+'/next-qualification/mutants/'+case+'/expected-witnesses.json')
   assert strict(witness)==strict(expected) and len(witness)==rc['reachedWitnessCount']=={'outgoing-filter-negated':322,'incoming-order-reversed':360,'world-valid-omitted':576}[case]
for n,h in r['generated'].items():assert n.endswith('.js') and sha(f[path(n)])==h
assert {n for n in f if n.startswith(path(p['stage'])+'/')}=={path(str(Path(p['stage'])/n)) for n in p['inventory']}
for n,h in p['inventory'].items():assert sha(f[path(str(Path(p['stage'])/n))])==h
for row in p['stageImportJoins']:
 assert sha(f[path(row['originalTarget'])])==sha(f[path(row['actualTarget'])])==row['SHA256']
 assert f[path(row['source'])]==f[path(row['copy'])]
assert len(r['generated'])==4
print('PASS: finite standalone JS normal192 and three complete reached controls; no backend replay/full55/performance claim')
