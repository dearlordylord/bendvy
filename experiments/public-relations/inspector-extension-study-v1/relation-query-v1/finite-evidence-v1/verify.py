"""Portable no-child evidence verification; never executes Bend, TS or backend tools."""
import hashlib,json,tarfile
from pathlib import Path
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def strict(x):
 if isinstance(x,dict):return ('dict',tuple((k,strict(v)) for k,v in sorted(x.items())))
 if isinstance(x,list):return ('list',tuple(map(strict,x)))
 return (type(x).__name__,x)
with tarfile.open(H/'evidence.tar.gz') as tar:
 members=tar.getmembers();assert len({m.name for m in members})==len(members)
 assert all(m.isfile() and (m.name=='index.json' or m.name.startswith('objects/')) for m in members)
 raw={m.name:tar.extractfile(m).read() for m in members}
assert raw['index.json']==(H/'index.json').read_bytes()
i=json.loads(raw['index.json']);records={x['name']:x for x in i['records']};assert len(records)==len(i['records'])
for name,record in records.items():
 b=raw['objects/'+record['SHA256']];assert len(b)==record['bytes'] and sha(b)==record['SHA256']
assert set(raw)=={'index.json'}|{'objects/'+x['SHA256'] for x in records.values()}
def get(name):return raw['objects/'+records[name]['SHA256']]
def obj(name):return json.loads(get(name))
f=i['fixture'];b=i['actualBend'];t=i['actualTS']
p=obj(b+'/plan.json');r=obj(b+'/receipt.json');v=obj(f+'/reconciliation-v2.json');d=obj(f+'/oracle-v2-source-delta.json')
assert sha(get(b+'/plan.json'))=='be67bdcdc49377484a83d628f6a98222fe400a3719dbf24f48dfa306c038862c'
assert sha(get(b+'/receipt.json'))=='747c6c45d6a5be6bd1261e01e2efb791b86e5810321d41c2540831406b750d6c'
assert r['status']=='INCOMPLETE' and r['guardFailures']==[]
assert len(p['commands'])==len(r['commands'])==1
pc=p['commands'][0];rc=r['commands'][0]
assert pc['argv']==rc['argv'] and pc['label']==rc['label']=='boundary-io' and pc['seconds']==rc['seconds']==5
assert rc['exit']==0 and rc['failure'] is None and set(r['logs'])=={'boundary-io.stdout','boundary-io.stderr'}
for n,h in r['logs'].items():assert sha(get(b+'/'+n))==h
assert v['status']=='DERIVED_MODEL_V2_FULL192_MATCH_NOT_FULL55' and v['historicalReceiptStatus']=='INCOMPLETE'
assert v['historicalPlanSHA256']==sha(get(b+'/plan.json')) and v['historicalReceiptSHA256']==sha(get(b+'/receipt.json'))
assert v['modelDeltaSHA256']==sha(get(f+'/oracle-v2-source-delta.json')) and v['oracleV2SHA256']==sha(get(f+'/expected-relations-v2.json'))
assert v['historicalRaw']==r['logs'] and all(v[k]=={} for k in ('currentHistoricalPinDrift','currentHistoricalConfigurationDrift','currentHistoricalInstalledMembershipDrift'))
for n,h in d['sources'].items():assert sha(get(f+'/'+n))==h
# Execute only the archived independent Python model, with main writer disabled.
ns={'__name__':'independent_archived_model','__file__':'author-oracle-v2.py'}
exec(compile(get(f+'/author-oracle-v2.py'),'author-oracle-v2.py','exec'),ns)
expected={'schemas':[ns['schema']('Workshop',0),ns['schema']('Garden',100)],'scope':'finite relation Inspector development fixture; no full55 qualification'}
assert strict(expected)==strict(obj(f+'/expected-relations-v2.json'))
text=get(b+'/boundary-io.stdout').decode();actual,end=json.JSONDecoder().raw_decode(text)
notice=get(f.rsplit('/',1)[0]+'/pinned-bend-notice.bytes')
assert text[end:].encode() in (b'\n',b'\n'+notice) and get(b+'/boundary-io.stderr') in (b'',notice)
assert strict(actual)==strict(expected)
diffs=[]
def walk(a,c,path=''):
 assert type(a)==type(c)
 if isinstance(a,dict):
  assert a.keys()==c.keys()
  for k in a:walk(a[k],c[k],path+'/'+k)
 elif isinstance(a,list):
  assert len(a)==len(c)
  for n,(x,y) in enumerate(zip(a,c)):walk(x,y,path+'/'+str(n))
 elif a!=c:diffs.append([path,a,c])
walk(obj(f+'/expected-relations.json'),expected)
assert strict(diffs)==strict(d['differencesOldToV2']) and len(diffs)==24
assert all(x[0].split('/')[-1] in {'cursorBefore','cursorAfter','worldClockBefore','worldClockAfter','finalInspectorCursor','finalWorldClock'} for x in diffs)
assert sum(len(x['queries']) for s in actual['schemas'] for x in s['phases'])==192
tr=obj(t+'/receipt.json');tp=obj(t+'/plan.json')
assert sha(get(t+'/plan.json'))==p['actualTSPlanSHA256'] and sha(get(t+'/receipt.json'))==p['actualTSReceiptSHA256']==v['actualTSReceiptSHA256']
assert tr['status']=='DEVELOPMENT_ACTUAL_TS_RELATION192_PASS_NOT_FULL55' and len(tr['commands'])==1 and tr.get('guardFailures',[])==[]
tc=tr['commands'][0];assert tc['argv']==tp['command']['argv'] and tc['label']==tp['command']['label']=='ts-relations' and tc['seconds']==tp['command']['seconds']==5 and tc['exit']==0 and tc['failure'] is None and tc['fullOracleMatched'] is True
assert set(tr['logs'])=={'ts-relations.stdout','ts-relations.stderr'}
for n,h in tr['logs'].items():assert sha(get(t+'/'+n))==h
assert strict(json.loads(get(t+'/ts-relations.stdout')))==strict(obj(f+'/expected-ts-relations.json'))
assert get(t+'/ts-relations.stderr')==b''
assert obj(f+'/development/reconcile-8141-source/failure.json')['status']=='INCOMPLETE_NO_CHILD_RECONCILER'
joins=obj(f+'/source-joins.json');assert len(joins['files'])==28 and sha(get(f+'/source-joins.json'))==v['sourceJoinsSHA256']
def resolve_absolute(path):
 prefix='/workspace/formal-proofs/bendvy-worktrees/parity-42-relations/'
 return 'worktree/'+path[len(prefix):] if path.startswith(prefix) else 'external/'+path.lstrip('/')
for row in joins['files']:
 assert sha(get(f+'/'+row['copy']))==sha(get(resolve_absolute(row['source'])))==row['SHA256']
dispositions=json.loads((H/'scalar-pin-dispositions.json').read_text())
for role,plan in (('io',p),('ts',tp)):
 disposition=dispositions[role]
 assert disposition['historicalPlanSHA256']==sha(get((b if role=='io' else t)+'/plan.json'))
 wanted=dict(plan['pins']);wanted[plan['privateEnvironment']]=plan['environmentSHA256']
 assert set(wanted)==set(disposition['pins'])
 for path,digest in wanted.items():
  entry=disposition['pins'][path];assert entry['SHA256']==digest
  if 'archive' in entry:
   assert entry['archive']==resolve_absolute(path) and sha(get(entry['archive']))==digest
  else:
   assert set(entry)=={'SHA256','excluded'} and entry['excluded'] in {'private environment excluded','tool executable excluded','configuration/metadata excluded; historical SHA only'}
   assert Path(path).suffix not in ('.bend','.py','.mjs','.ts')
for directory in ('fixture-output-1791440787714716609','boundary-io-1791440788582957020'):
 record=obj(f+'/development/'+directory+'/receipt.json')
 assert record['exitCode']==0 and record['sourceGuardPass'] is True
 assert record['localSourcePins']==record['postSourcePins']
 for name,digest in record['localSourcePins'].items():assert sha(get(f+'/'+name))==digest
 for name,recorded in records.items():
  if name.startswith(f+'/development/'+directory+'/'):
   # All retained raw receipt/archive files are scalar pinned by the IO plan.
   absolute='/workspace/formal-proofs/bendvy-worktrees/parity-42-relations/'+name[len('worktree/'):]
   assert p['pins'][absolute]==recorded['SHA256']
print('PASS finite TS192 and derived Bend IO192; original acceptance INCOMPLETE preserved; no backend/full55 claim')
