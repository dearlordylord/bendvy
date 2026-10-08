"""Read/hash-only detached normal JS evidence verifier; no backend execution."""
from pathlib import Path
import json,hashlib,tarfile
H=Path(__file__).resolve().parent
sha=lambda b:hashlib.sha256(b).hexdigest()
with tarfile.open(H/'evidence.tar.gz') as tar:
 members=tar.getmembers();assert all(m.isfile() for m in members);assert len({m.name for m in members})==len(members)
 objects={m.name:tar.extractfile(m).read() for m in members}
i=json.loads((H/'index.json').read_bytes());assert objects.pop('index.json')==(H/'index.json').read_bytes()
assert set(objects)=={'objects/'+r['SHA256'] for r in i['records']}
f={}
for row in i['records']:
 b=objects['objects/'+row['SHA256']];assert sha(b)==row['SHA256'] and len(b)==row['bytes'];assert row['name'] not in f;f[row['name']]=b
root=i['historicalRoot']
def name(p):return 'worktree/'+p[len(root)+1:] if p.startswith(root+'/') else 'external/'+p.lstrip('/')
def read(p):return f[name(p)]
def obj(p):return json.loads(read(p))
A=root+'/.artifacts/check55-detached-normal-js-1791466387127562283'
p=obj(A+'/plan.json');r=obj(A+'/receipt.json');q=obj(A+'/prepare-receipt.json')
assert sha(read(A+'/plan.json'))=='51d894c63fa397fac500ec5722ab34596889af03c7d38ec235d738a32a37cd88'==r['planSHA256']
assert sha(read(A+'/receipt.json'))=='15eed3b0646b538df4c16057daae6e2ff1187fd42ce711d43f2b16bbecae8eb4'
assert sha(read(A+'/prepare-receipt.json'))=='ba55f0a70d15327275ac857e990208aace8c6f79bc0852772e13af08a45835b4'
assert r['status']=='DEVELOPMENT_DETACHED_CHECK_OBSERVATION_NORMAL_JS_PASS_NOT_FULL55' and not r.get('guardFailures')
assert q['status']=='OWNED_JS_PREPARATION_PASS' and not q.get('guardFailures')
plans=[]
for b in f.values():
 try:z=json.loads(b)
 except (ValueError,UnicodeDecodeError):continue
 if isinstance(z,dict) and 'privateEnvironment' in z and 'pins' in z:plans.append(z)
for path,d in p['pins'].items():
 if name(path) in f:assert sha(read(path))==d
 else:
  e=i['excluded'][path];assert e['SHA256']==d
  if e['reason']=='private environment identity only':assert any(z['privateEnvironment']==path and z['environmentSHA256']==d for z in plans)
  elif e['reason']=='installed executable identity only':assert any(z.get('tools',{}).get('pins',{}).get(path)==d for z in plans)
  elif e['reason']=='private configuration identity only':assert Path(path).name=='.npmrc' and any(z.get('configuration',{}).get(path,{}).get('SHA256')==d for z in plans)
  else:raise AssertionError(e)
assert len(p['inventory'])==57
prefix=name(p['stage'])+'/'
assert {n[len(prefix):] for n in f if n.startswith(prefix)}==set(p['inventory'])
for n,d in p['inventory'].items():assert sha(read(p['stage']+'/'+n))==d
assert len(p['stageImportJoins'])==311
for z in p['stageImportJoins']:
 assert read(z['source'])==read(z['copy']) and sha(read(z['originalTarget']))==sha(read(z['actualTarget']))==z['SHA256']
runner=root+'/scripts/task_runner.py'
def probes(record,plan,a,folder,labels):
 assert not record.get('guardFailures') and record['probeCommandsExecuted']==len(labels)
 assert set(record['probePins'])=={a+'/'+folder+'/'+label+s for label in labels for s in ('.json','.stdout','.stderr')}
 for path,d in record['probePins'].items():assert sha(read(path))==d
 for label in labels:
  z=obj(a+'/'+folder+'/'+label+'.json');tool=label.rsplit('-',1)[-1]
  assert z['argv']==[plan['tools']['taskset'],'-c','5',plan['tools']['ldd'],plan['tools']['tools'][tool]] and z['seconds']==5 and z['exit']==0 and z['failure'] is None and z.get('exception') is None and z['runnerSHA256']==plan['pins'][runner]
probes(q,p,A,'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset')])
assert p['executionProbeLabels']==['guard-'+str(k)+'-'+n for k in range(5) for n in ('bend','node','python','taskset')]
probes(r,p,A,'execution-probes',p['executionProbeLabels'])
assert len(r['commands'])==len(p['commands'])==2
S=root+'/'+str(Path(json.loads((H/'delivery-files.json').read_text())['packagePath']).parent)
entry=p['stage']+'/'+S[len(root)+1:]+'/normal/closure/experiments/public-relations/inspector-extension-study-v1/relation-query-v1/next-qualification/check-relations-v1/all-phase-check-v2/chunked-expectations-v3/complete-io.bend'
assert '..' not in Path(entry).parts and sha(read(entry))==p['inventory'][str(Path(entry).relative_to(p['stage']))]
assert p['commands'][0]['label']=='emit-normal' and p['commands'][0]['argv']==['taskset','-c','5','bend',entry,'-o',A+'/normal.js'] and p['commands'][0]['artifact']==A+'/normal.js'
assert p['commands'][1]['label']=='js-normal' and p['commands'][1]['argv']==['taskset','-c','5','node',A+'/normal.js'] and p['commands'][1]['oracle']==S+'/normal/expected-complete.json'
assert set(r['generated'])=={A+'/normal.js'}
for got,wanted in zip(r['commands'],p['commands']):
 assert all(got[k]==wanted[k] for k in wanted) and got['status']=='QUALIFIED' and got['exit']==0 and got['failure'] is None
 assert wanted['seconds']==(30 if wanted['label']=='emit-normal' else 5) and wanted['argv'][:3]==['taskset','-c','5']
assert set(r['logs'])=={'emit-normal.stdout','emit-normal.stderr','js-normal.stdout','js-normal.stderr'}
for n,d in r['logs'].items():assert sha(read(A+'/'+n))==d
assert read(A+'/emit-normal.stdout')==b'' and read(A+'/js-normal.stderr')==b''
notice=b'bend 2.0.36 is available: run bend update\n'
assert sha(notice)=='57f1325a11b98d00f4bdbb487bda0cc9787e2baa240266722596845baee2e494'
assert read(A+'/emit-normal.stderr') in (b'',notice)
for path,d in r['generated'].items():assert sha(read(path))==d
raw=read(A+'/js-normal.stdout');assert len(raw)==151386 and raw.endswith(b'\n')
assert raw==read(root+'/.artifacts/check-relation55-reached-controls-js-1791462194945874132/js-normal.stdout')
value,end=json.JSONDecoder().raw_decode(raw.decode());assert raw.decode()[end:]=='\n'
def strict(z):
 if isinstance(z,dict):return ('dict',tuple((k,strict(v)) for k,v in sorted(z.items())))
 if isinstance(z,list):return ('list',tuple(map(strict,z)))
 return (type(z).__name__,z)
assert strict(value)==strict(obj(p['commands'][1]['oracle']))
assert sum(len(phase['queries']) for schema in value['schemas'] for phase in schema['phases'])==192
assert all(schema['phaseChecks']==[{'done':True}]*3 and schema['gate']['bodyMarkers']==1 for schema in value['schemas'])
F=root+'/.artifacts/check-relation55-reached-native-normal-1791464870172183905';fp=obj(F+'/plan.json');fr=obj(F+'/receipt.json');fq=obj(F+'/prepare-receipt.json')
assert sha(read(F+'/plan.json'))=='88b98c14bbaa3e1424ad54ad48fb8b7986465fd10a4d3751bf9beb7b95abfe89'
assert sha(read(F+'/receipt.json'))=='28f9fa27dcb2fa0f7eb8a9aa51b94829b8938345661a666ce03010c41188586a'
assert fr['status']=='INCOMPLETE' and fr['generated']=={} and len(fr['commands'])==1 and fr['commands'][0]['label']=='emit-workshop' and fr['commands'][0]['failure']=='child deadline' and fr['commands'][0]['exit'] is None
assert read(F+'/emit-workshop.stdout')==read(F+'/emit-workshop.stderr')==b''
probes(fq,fp,F,'prepare-probes',['prepare-'+n for n in ('bend','node','python','taskset','clang')]);probes(fr,fp,F,'execution-probes',fp['executionProbeLabels'][:15])
# Original wrapper syntax failure and repaired source feasibility remain separate.
for ns,status,exit in [('1791466043914719214','INCOMPLETE',1),('1791466119998852285','SOURCE_FEASIBLE_NOT_PROOF',0)]:
 a=root+'/.artifacts/check55-detached-source-dev-'+ns;sp=obj(a+'/plan.json');sr=obj(a+'/receipt.json');assert sr['status']==status and sr['exit']==exit and sr['failure'] is None and not sr['sourceDrift'] and sr['command']==sp['argv'] and sr['seconds']==sp['seconds']==5 and sr['planSHA256']==sha(read(a+'/plan.json'))
 for n,d in sr['rawSHA256'].items():assert sha(read(a+'/'+n+'.raw'))==d
# Selected delivery bytes are checked after historical→current relocation.
delivery=json.loads((H/'delivery-files.json').read_text());liveRoot=H
for _ in range(len(Path(delivery['packagePath']).parts)):liveRoot=liveRoot.parent
joins=obj(S+'/source-joins.json')
joined={root+'/'+row['copy']:row['deliverySHA256'] for row in joins['sources']};joined[root+'/'+joins['added']['path']]=joins['added']['SHA256']
for row in delivery['files']:
 live=liveRoot/row['path'];assert sha(live.read_bytes())==row['SHA256']
 historical=root+'/'+row['path']
 if historical in p['pins']:assert sha(read(historical))==p['pins'][historical]==row['SHA256']
 elif historical in joined:assert sha(read(historical))==joined[historical]==row['SHA256']
 elif live.suffix=='.bend':raise AssertionError('Unjoined selected Bend source:'+row['path'])
print('PASS: detached normal JS full151386B; preserved Native timeout/source histories; evidence only')
