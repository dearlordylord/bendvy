"""Portable no-child source-controls/reached-mutants evidence verifier."""
import hashlib,json,tarfile,tempfile,runpy,base64
from pathlib import Path
H=Path(__file__).resolve().parent;J=H.parent
sha=lambda b:hashlib.sha256(b).hexdigest()
def strict(x):
 if isinstance(x,dict):return ('dict',tuple((k,strict(v)) for k,v in sorted(x.items())))
 if isinstance(x,list):return ('list',tuple(map(strict,x)))
 return (type(x).__name__,x)
def read(folder):
 with tarfile.open(folder/'evidence.tar.gz') as t:
  members=t.getmembers();assert len({m.name for m in members})==len(members)
  assert all(m.isfile() and (m.name=='index.json' or m.name.startswith('objects/')) for m in members)
  raw={m.name:t.extractfile(m).read() for m in members}
 assert raw['index.json']==(folder/'index.json').read_bytes()
 index=json.loads(raw['index.json']);records={r['name']:r for r in index['records']};assert len(records)==len(index['records'])
 assert set(raw)=={'index.json'}|{'objects/'+r['SHA256'] for r in records.values()}
 for r in records.values():assert sha(raw['objects/'+r['SHA256']])==r['SHA256'] and len(raw['objects/'+r['SHA256']])==r['bytes']
 return index,{n:raw['objects/'+r['SHA256']] for n,r in records.items()}
i,files=read(H);assert sha((J/'finite-evidence-v1/evidence.tar.gz').read_bytes())==i['normalArchiveSHA256']
ni,normal=read(J/'finite-evidence-v1');assert all(files[n]==normal[n] for n in files.keys()&normal.keys());files={**normal,**files}
# Existing committed normal verifier is a prerequisite, never a backend replay.
runpy.run_path(str(J/'finite-evidence-v1/verify.py'),run_name='normal_evidence_only')
f=i['fixture'];m=i['actualMutants'];n=i['originalNative']
def get(name):return files[name]
def obj(name):return json.loads(get(name))
def absolute(path):
 prefix='/workspace/formal-proofs/bendvy-worktrees/parity-42-relations/'
 return 'worktree/'+path[len(prefix):] if path.startswith(prefix) else 'external/'+path.lstrip('/')
p=obj(m+'/plan.json');r=obj(m+'/receipt.json')
assert sha(get(m+'/plan.json'))=='05c66f420ab881d236b8ac551587fc694da4d6367b026fa870743e185b9f3f45'
assert sha(get(m+'/receipt.json'))=='269241250057cad11c2026e6bc4b542b9dd81ed53de1e4962ee4ef3b788d8fd5'
assert r['planSHA256']==sha(get(m+'/plan.json')) and r['status']=='DEVELOPMENT_THREE_RELATION192_MUTANTS_REACHED_IO_NOT_FULL55' and r.get('guardFailures',[])==[]
cases=('outgoing-filter-negated','incoming-order-reversed','world-valid-omitted');counts=(322,360,576)
assert len(p['commands'])==len(r['commands'])==3 and set(r['logs'])=={c+s for c in cases for s in ('.stdout','.stderr')}
for name,digest in r['logs'].items():assert sha(get(m+'/'+name))==digest
with tempfile.TemporaryDirectory() as tmp:
 root=Path(tmp);model=root/'next-qualification/mutants';model.mkdir(parents=True)
 for source in ('author-oracle-v2.py','expected-relations-v2.json'):(root/source).write_bytes(get(f+'/'+source))
 author=model/'author-defects.py';author.write_bytes(get(f+'/next-qualification/mutants/author-defects.py'))
 context=runpy.run_path(str(author),run_name='independent_defect_evidence_only')
 notice=get(f.rsplit('/',1)[0]+'/pinned-bend-notice.bytes')
 for index,(case,count) in enumerate(zip(cases,counts)):
  pc=p['commands'][index];rc=r['commands'][index]
  assert pc['label']==rc['label']==case and pc['argv']==rc['argv'] and pc['seconds']==rc['seconds']==5 and rc['exit']==0 and rc['failure'] is None and rc['fullDefectOracleMatched'] is True and rc['reachedWitnessCount']==count
  text=get(m+'/'+case+'.stdout').decode();actual,end=json.JSONDecoder().raw_decode(text)
  assert text[end:].encode() in (b'\n',b'\n'+notice) and get(m+'/'+case+'.stderr') in (b'',notice)
  expected=obj(f+'/next-qualification/mutants/'+case+'/expected-defect.json')
  assert strict(actual)==strict(expected)==strict(context['variants'][case])
  witnesses=context['differences'](context['normal'],actual)
  assert strict(witnesses)==strict(obj(f+'/next-qualification/mutants/'+case+'/expected-witnesses.json')) and len(witnesses)==count
  assert sum(len(phase['queries']) for schema in actual['schemas'] for phase in schema['phases'])==192
classifications=json.loads((H/'source-pair-classifications.json').read_text())
pairs=obj(f+'/next-qualification/source-pairs.json');assert len(pairs['pairs'])==3
for pair in pairs['pairs']:
 for label,entry in pair['members'].items():
  prefix=f+'/'+pairs['directory']+'/'+label;record=obj(prefix+'/receipt.json')
  assert sha(get(prefix+'/receipt.json'))==entry['receiptSHA256'] and record['sourceGuardPass'] is True and record['localSourcePins']==record['postSourcePins']
  assert record['exit']==(0 if label.startswith('positive-') else 1)
  assert sha(get(prefix+'/stdout'))==entry['stdoutSHA256']==record['stdoutSHA256'] and sha(get(prefix+'/stderr'))==entry['stderrSHA256']==record['stderrSHA256']
  assert sha(get(f+'/next-qualification/'+label+'.bend'))==entry['sourceSHA256']
  classification=classifications[label];assert classification['sourceSHA256']==entry['sourceSHA256']
  stdout=get(prefix+'/stdout');stderr=get(prefix+'/stderr')
  assert stdout==base64.b64decode(classification['stdoutBase64']) and stderr==base64.b64decode(classification['stderrBase64'])
  if label.startswith('positive-'):
   assert stdout==b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n' and len(stdout)==58 and stderr==get(f.rsplit('/',1)[0]+'/pinned-bend-notice.bytes')
  else:
   assert stdout==b'';text=stderr.decode();assert text.startswith('SOME PROOFS FAIL\nError:\n')
   assert text.count('Error:\n')==text.count('Location:')==1
   assert '- expected : '+classification['expected']+'\n' in text and '- observed : '+classification['observed']+'\n' in text and 'Location: '+classification['location']+'\n' in text

proposal=obj(f+'/next-qualification/mutants/source-proposal.json')
for case in cases:
 prefix=f+'/next-qualification/mutants/'+case;entry=proposal['mutants'][case]
 assert sha(get(prefix+'/'+entry['changedPath']))==entry['mutatedSHA256']
 for name,digest in entry['unchangedCopyJoins'].items():assert sha(get(prefix+'/'+name))==sha(get(f+'/'+name))==digest
 proof=obj(f+'/development/mutant-source-1791443472352846772/'+case+'/receipt.json');assert proof['exit']==0 and proof['sourceGuardPass'] is True and proof['sourcePins']==proof['postSourcePins']
 for name,digest in proof['sourcePins'].items():assert sha(get(prefix+'/'+name))==digest
np=obj(n+'/plan.json');nr=obj(n+'/receipt.json')
assert sha(get(n+'/plan.json'))=='c775239fd106f8d48e4e481e347c98a7ba2aed078d744c95e15b5705e0c7159c' and sha(get(n+'/receipt.json'))=='35c94404500c35d4a4587a9eeac18cf2b092abcdbb232da8c1266775c2ca299e'
assert nr['status']=='INCOMPLETE' and nr['guardFailures']==[] and nr['probeCommandsExecuted']==15 and nr['generated']=={} and len(nr['commands'])==1
failed=nr['commands'][0];assert failed['label']=='emit-c' and failed['seconds']==30 and failed['failure']=='child deadline' and failed['argv']==np['commands'][0]['argv']
assert set(nr['logs'])=={'emit-c.stdout','emit-c.stderr'}
for name,digest in nr['logs'].items():assert sha(get(n+'/'+name))==digest and get(n+'/'+name)==b''
prep=obj(n+'/prepare-receipt.json');assert prep['status']=='OWNED_NATIVE_PREPARATION_PASS' and prep['probeCommandsExecuted']==5 and prep.get('guardFailures',[])==[]
for record,folder,labels in ((nr,'execution-probes',np['executionProbeLabels'][:15]),(prep,'prepare-probes',['prepare-'+x for x in ('bend','node','python','taskset','clang')])):
 expectedPaths={n+'/'+folder+'/'+label+suffix for label in labels for suffix in ('.json','.stdout','.stderr')}
 assert {absolute(path) for path in record['probePins']}==expectedPaths
 for path,digest in record['probePins'].items():assert sha(get(absolute(path)))==digest
 for label in labels:
  metadata=obj(n+'/'+folder+'/'+label+'.json');tool=label.rsplit('-',1)[-1]
  expectedArgv=[np['tools']['taskset'],'-c',str(np['tools']['cpu']),np['tools']['ldd'],np['tools']['tools'][tool]]
  assert metadata['argv']==expectedArgv and metadata['seconds']==5 and metadata['exit']==0 and metadata['failure'] is None
  runner='/workspace/formal-proofs/bendvy-worktrees/parity-42-relations/scripts/task_runner.py'
  assert metadata['runnerSHA256']==np['pins'][runner]

for row in np['stageImportJoins']:assert sha(get(absolute(row['source'])))==sha(get(absolute(row['copy']))) and sha(get(absolute(row['originalTarget'])))==sha(get(absolute(row['actualTarget'])))==row['SHA256']
dispositions=json.loads((H/'scalar-pin-dispositions.json').read_text())
for role,plan,path in (('mutants',p,m),('nativeTimeout',np,n)):
 disposition=dispositions[role];assert disposition['historicalPlanSHA256']==sha(get(path+'/plan.json'))
 wanted=dict(plan['pins']);wanted[plan['privateEnvironment']]=plan['environmentSHA256'];assert set(wanted)==set(disposition['pins'])
 for source,digest in wanted.items():
  value=disposition['pins'][source];assert value['SHA256']==digest
  if 'archive' in value:assert value['archive']==absolute(source) and sha(get(value['archive']))==digest
  else:assert value['excluded'] in ('private environment','tools/binary/config metadata only') and Path(source).suffix not in ('.bend','.py','.mjs','.ts')
print('PASS finite three matched source pairs and three reached whole192 IO mutants; original Native emission timeout preserved; no Native/proof/full55 claim')
