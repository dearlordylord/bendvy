"""Portable no-child verification of three complete reached Native controls."""
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
for folder,key in (('schema-native-evidence-v1','normalNativeArchiveSHA256'),('controls-evidence-v1','controlsArchiveSHA256')):
 assert sha((J/folder/'evidence.tar.gz').read_bytes())==i[key]
 if folder=='schema-native-evidence-v1':runpy.run_path(str(J/folder/'verify.py'),run_name='prerequisite_evidence_only')
prefix='/workspace/formal-proofs/bendvy-worktrees/parity-42-relations/'
def path(n):return 'worktree/'+n[len(prefix):] if n.startswith(prefix) else 'external/'+n.lstrip('/')
def obj(n):return json.loads(f[n])
CASES=('outgoing-filter-negated','incoming-order-reversed','world-valid-omitted');counts=(322,360,576)
assert set(i['actual'])==set(CASES)
plans=('2b4528c89df92397a332737263d9d097c896535d0eacf9ca568f44bbdaa412d7','3f4c4a45dc493b3e354cbf7c56519be72ffa202d1f918167a295a6842d469c68','aa7cb8556ce65e799b4cd9da33c8fdcd1e7946b8118daf223f485e3940509d5e')
for case,count,planSHA in zip(CASES,counts,plans):
 a=i['actual'][case];p=obj(a+'/plan.json');r=obj(a+'/receipt.json');q=obj(a+'/prepare-receipt.json')
 assert sha(f[a+'/plan.json'])==planSHA==r['planSHA256'] and p['case']==case
 assert r['status']=='DEVELOPMENT_MUTANT_TWO_SCHEMA_NATIVE192_REACHED_NOT_FULL55' and r.get('guardFailures',[])==[] and r['full192JoinMatched'] is True and r['reachedWitnessCount']==count
 for n,h in p['pins'].items():
  if path(n) in f:assert sha(f[path(n)])==h
  else:assert i['excluded'][n]['SHA256']==h
 assert i['excluded'][p['privateEnvironment']]['SHA256']==p['environmentSHA256']
 telemetry=p['historicalTelemetryJoin'];assert telemetry['path']=='/home/node/.bend/check.json' and telemetry['historicalSHA256']=='2701f29532eebe9f6fc5ed50c50cbfcbc33925cfe033065a86fa7bc8f9f43e5d' and telemetry['freshSHA256']=='2323ddd47baf7dd03018bcf923b6c9b4bb306f04c80bce7e21c4e5e62bc3c564'
 assert sha(f[path(telemetry['historicalBytes'])])==telemetry['historicalSHA256'] and sha(f[path(telemetry['path'])])==telemetry['freshSHA256']
 old=obj(path(telemetry['historicalBytes']));current=obj(path(telemetry['path']));assert old=={'t':1791359685386,'ver':'2.0.36','notice':''} and current=={'t':1791446087477,'ver':'2.0.36','notice':''}
 assert q['status']=='OWNED_NATIVE_PREPARATION_PASS' and q['probeCommandsExecuted']==5 and r['probeCommandsExecuted']==65
 for record,folder,labels in ((q,'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset','clang')]),(r,'execution-probes',p['executionProbeLabels'])):
  expected={a+'/'+folder+'/'+label+suffix for label in labels for suffix in ('.json','.stdout','.stderr')}
  assert set(map(path,record['probePins']))==expected=={n for n in f if n.startswith(a+'/'+folder+'/')}
  for n,h in record['probePins'].items():assert sha(f[path(n)])==h
  for label in labels:
   m=obj(a+'/'+folder+'/'+label+'.json');tool=label.rsplit('-',1)[-1]
   assert m['argv']==[p['tools']['taskset'],'-c','5',p['tools']['ldd'],p['tools']['tools'][tool]] and m['seconds']==5 and m['exit']==0 and m['failure'] is None and m.get('exception') is None and m['runnerSHA256']==p['pins'][prefix+'scripts/task_runner.py']
 assert len(p['commands'])==len(r['commands'])==6 and set(r['logs'])=={c['label']+s for c in p['commands'] for s in ('.stdout','.stderr')}
 for n,h in r['logs'].items():assert sha(f[a+'/'+n])==h
 for pc,rc in zip(p['commands'],r['commands']):
  assert all(pc[k]==rc[k] for k in ('label','argv','seconds')) and rc['exit']==0 and rc['failure'] is None
  assert rc['seconds']==(30 if rc['label'].startswith('emit-') else 120 if rc['label'].startswith('compile-') else 5)
  assert f[a+'/'+rc['label']+'.stderr']==b''
  if not rc['label'].startswith('run-'):assert f[a+'/'+rc['label']+'.stdout']==b''
 for n,h in r['generated'].items():
  if n.endswith('.c'):assert sha(f[path(n)])==h
  else:assert i['excluded'][n]['SHA256']==h
 parts=[]
 for family in ('workshop','garden'):
  rc=next(c for c in r['commands'] if c['label']=='run-'+family);b=f[a+'/run-'+family+'.stdout'];assert b.endswith(b'\n')
  actual=json.loads(b);expected=obj(path(rc['oracle']));assert strict(actual)==strict(expected) and rc['fullOracleMatched'] is True and sha(f[path(rc['oracle'])])==rc['oracleSHA256']
  assert sum(len(phase['queries']) for phase in actual['phases'])==96;parts.append(b[:-1])
 combined=b'{"schemas":['+parts[0]+b','+parts[1]+b'],"scope":"finite relation Inspector development fixture; no full55 qualification"}\n'
 assert sha(combined)==r['combinedFull192RawSHA256'] and combined==f['worktree/.artifacts/inspector-relation55-mutant-io-1791443937298190588/'+case+'.stdout']
 actual=json.loads(combined);assert strict(actual)==strict(obj(i['fixture']+'/next-qualification/mutants/'+case+'/expected-defect.json'))
 for n,h in p['inventory'].items():assert sha(f[path(str(Path(p['stage'])/n))])==h
 for row in p['stageImportJoins']:
  assert f[path(row['source'])]==f[path(row['copy'])] and sha(f[path(row['originalTarget'])])==sha(f[path(row['actualTarget'])])==row['SHA256']
 with tempfile.TemporaryDirectory() as d:
  root=Path(d);m=root/'next-qualification/mutants';m.mkdir(parents=True)
  for n in ('author-oracle-v2.py','expected-relations-v2.json'):(root/n).write_bytes(f[i['fixture']+'/'+n])
  author=m/'author-defects.py';author.write_bytes(f[i['fixture']+'/next-qualification/mutants/author-defects.py']);context=runpy.run_path(str(author),run_name='independent_expected_defect_only')
  witness=context['differences'](context['normal'],actual);assert strict(witness)==strict(obj(i['fixture']+'/next-qualification/mutants/'+case+'/expected-witnesses.json')) and len(witness)==count
print('PASS finite three reached Native192 controls; no backend/full55/performance claim')
